{ ... }:
{
  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets."dpsk_api_key" = {
      sopsFile = ../../secrets/dpsk_api_key.yaml;
    };
    secrets."e_flow" = { 
      sopsFile = ../../secrets/e_flow.yaml;
    };
  };
}

