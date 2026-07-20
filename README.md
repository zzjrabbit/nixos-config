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

System-level sops-nix performs decryption as root. The resulting API key files
are mode `0400` and owned by `raca:users`; Home Manager never reads the SSH host
private key or the Age identity directly.
