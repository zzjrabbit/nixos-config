{ ... }:

{
  # Configure impermanence
  environment.persistence."/persist" = {
    hideMounts = true;

    # System directories that need to persist
    directories = [
      # System configuration and state
      "/etc/NetworkManager/system-connections"

      # System logs and state
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/regreet"
      "/var/lib/systemd/coredump"
      "/var/lib/bluetooth"
    ];

    # Individual files that need to persist
    files = [
      # Machine ID
      "/etc/machine-id"

      # SSH host keys
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
  };
}