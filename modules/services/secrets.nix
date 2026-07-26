{ inputs, lib, pkgs, userName, ... }:
let
  secretDirectory = ../../secrets;
  secretDirectoryEntries = builtins.readDir secretDirectory;
  secretFileNames = builtins.filter
    (fileName:
      secretDirectoryEntries.${fileName} == "regular"
      && builtins.match "^[a-z][a-z0-9_]*[.]yaml$" fileName != null)
    (builtins.attrNames secretDirectoryEntries);
  invalidSecretFileNames = builtins.filter
    (fileName:
      secretDirectoryEntries.${fileName} == "regular"
      && lib.hasSuffix ".yaml" fileName
      && builtins.match "^[a-z][a-z0-9_]*[.]yaml$" fileName == null)
    (builtins.attrNames secretDirectoryEntries);
  secretNames = map (lib.removeSuffix ".yaml") secretFileNames;

  sopsSecret = pkgs.writeShellApplication {
    name = "sops-secret";
    runtimeInputs = with pkgs; [
      coreutils
      git
      jq
      sops
    ];
    text = builtins.readFile ../../scripts/sops-secret.sh;
  };

  sopsAgeKeyFile = "/persist/home/${userName}/.config/sops/age/keys.txt";
  checkSopsAgeKey = pkgs.writeShellScript "check-sops-age-key" ''
    set -eu

    key=${sopsAgeKeyFile}
    if [ ! -f "$key" ]; then
      echo "Missing SOPS Age identity: $key" >&2
      exit 1
    fi

    mode="$(${pkgs.coreutils}/bin/stat -c %a "$key")"
    owner="$(${pkgs.coreutils}/bin/stat -c %U "$key")"
    if [ "$mode" != "600" ] || { [ "$owner" != "root" ] && [ "$owner" != "${userName}" ]; }; then
      echo "SOPS Age identity must be mode 0600 and owned by root or ${userName}" >&2
      exit 1
    fi
  '';
in {
  imports = [ inputs.sops-nix.nixosModules.sops ];

  assertions = [{
    assertion = invalidSecretFileNames == [ ];
    message = "Secret filenames must match secrets/[a-z][a-z0-9_]*.yaml: "
      + lib.concatStringsSep ", " invalidSecretFileNames;
  }];

  sops = {
    useSystemdActivation = true;
    age = {
      keyFile = sopsAgeKeyFile;
      sshKeyPaths = [ ];
    };
    secrets = lib.genAttrs secretNames (name: {
      sopsFile = secretDirectory + "/${name}.yaml";
      owner = userName;
      group = "users";
      mode = "0400";
    });
  };

  systemd.services = lib.mkIf (secretNames != [ ]) {
    sops-install-secrets.serviceConfig.ExecStartPre = checkSopsAgeKey;
  };

  environment.systemPackages = [ sopsSecret ];
}
