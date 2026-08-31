# UEFIer's NixOS Configuration

## Layout

```text
flake.nix          Inputs and one mkHost call per machine
lib/mkHost.nix     mkHost { name, user ? "raca", extraModules ? [] }
hosts/<name>/      Per-machine facts only:
  default.nix        imports + my.* feature toggles
  hardware.nix       kernel modules, microcode, zram
  disks.nix          fileSystems and UUIDs
modules/           Shared NixOS modules, imported wholesale via modules/default.nix
  core/              always-on: boot, nix, locale, fonts, users, home-manager, packages
  desktop/           graphical stack, gated by my.desktop.enable
  hardware/          my.hardware.magicbook.enable, my.hardware.nvidia.enable
  services/          persist, secrets, snapper, proxy, misc services
home/              Home Manager configuration (apps/, desktop/, system/)
```

Hosts opt into features through the `my.*` options; everything under
`modules/core` and `modules/services` applies to every host (proxy and snapper
default on and can be disabled per host).

## SOPS bootstrap and recovery

SOPS uses the dedicated Age identity at:

```text
/persist/home/raca/.config/sops/age/keys.txt
```

The private identity is deliberately not stored in Git or the Nix store. Keep
an encrypted offline backup of this file. A clean installation must restore it
after mounting the persistent filesystems and before activating the system:

```sh
sudo install -d -m 0700 /persist/home/raca/.config/sops/age
sudo install -o root -g root -m 0600 /path/from/offline-backup/keys.txt \
  /persist/home/raca/.config/sops/age/keys.txt
```

The `admin` recipient in `.sops.yaml` must match this identity. Public Age
recipients are safe to commit; private identities are not. Before rebuilding,
verify that the key is a valid Age identity without printing it:

```sh
awk '/^AGE-SECRET-KEY-/{found=1} END{exit !found}' \
  /persist/home/raca/.config/sops/age/keys.txt
```

System-level sops-nix performs decryption as root. The resulting secret files
are mode `0400` and owned by `raca:users`; Home Manager never reads the SSH host
private key or the Age identity directly.

## Managing secrets

Secret files are the source of truth. Every `secrets/<name>.yaml` file is
automatically registered as the sops-nix secret `<name>`, so adding or removing
a secret does not require editing a Nix file. At login, each available secret
is also exported using its uppercase name (`example_token` becomes
`EXAMPLE_TOKEN`). The existing `e_flow` secret keeps its compatibility name
`E_FLOW_API_KEY`. Names must match `[a-z][a-z0-9_]*`.

After activating this configuration, use the installed helper:

```sh
# Prompts twice without echoing the value.
sops-secret add example_token

# Suitable for multiline values such as certificates.
sops-secret add example_certificate --from-file ./certificate.pem

sops-secret edit example_token
sops-secret list
sops-secret remove example_token
```

The helper encrypts new values before they reach a repository file and stages
the encrypted addition, update, or deletion in Git. A rebuild/activation is
still required before the runtime secret files and shell exports change.

## Troubleshooting

### blink.cmp update stalls during Cargo vendor verification

`blink.cmp` includes the Rust-based `blink-fuzzy-lib`, so a Nixpkgs update may
build `blink-fuzzy-lib-*-vendor-staging` before compiling the plugin. The
`vendor-staging` derivation downloads Cargo dependencies from hosts such as
`index.crates.io` and `static.crates.io`; the following `vendor` derivation
mainly verifies and assembles those dependencies offline.

If this step times out even though Throne is running in TUN mode, check IPv6
first. This configuration enables system IPv6, while Throne may have its
separate **VPN IPv6** option disabled. Cargo hosts publish AAAA records, so their
traffic can then use the physical interface instead of an IPv4-only TUN.

1. Enable **VPN IPv6** in Throne's TUN/VPN settings.
2. Fully stop and restart TUN (or restart ThroneCore).
3. Verify that Throne installed IPv6 policy routing in addition to the main
   route:

   ```sh
   ip -6 rule
   ip -6 route show table all
   ```

4. Retry the build with logs enabled:

   ```sh
   nix build .#nixosConfigurations.laptop.config.system.build.toplevel -L
   ```

`programs.throne.tunMode.enable = true` only grants ThroneCore the capabilities
needed to create a TUN device; it does not declaratively enable global routing
or IPv6 interception. Those settings remain controlled by Throne itself.

If IPv6 TUN is active and `vendor-staging` still cannot download dependencies,
check whether `nix-daemon.service` has explicit `HTTP_PROXY`/`HTTPS_PROXY`
settings. Adding a daemon proxy is a fallback rather than the first fix because
the daemon starts before the user-session Throne process and downloads will
fail whenever the local proxy is not running.
