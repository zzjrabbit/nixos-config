{ inputs, pkgs, ... }:
let
  agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  home.packages = with agents; [
    claude-code
    codex
    gemini-cli
    opencode
  ];

  # home.file.".codex/config.toml".text = ''
  #   model_reasoning_effort = "high"
  #   model_provider = "e-flowcode"
  #   model = "gpt-5.5"
  #  
  #   [model_providers.e-flowcode]
  #   name = "e-flowcode"
  #   base_url = "https://e-flowcode.cc/v1"
  #   env_key = "E_FLOW_API_KEY"
  # '';
}
