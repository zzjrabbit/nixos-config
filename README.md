# UEFIer's NixOS Configuration

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
