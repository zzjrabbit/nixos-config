{ pkgs, ... }:
{
  vim.lsp.enable = true;

  vim.diagnostics = {
    enable = true;
    config = {
      severity_sort = true;
      virtual_text = {
        spacing = 2;
        source = "if_many";
        prefix = "●";
      };
    };
  };

  vim.languages = {
    bash.enable = true;
    clang.enable = true;
    json.enable = true;
    markdown.enable = true;
    nix = {
      enable = true;
      lsp.servers = [ "nixd" ];
      format = {
        enable = true;
        type = [ "nixfmt" ];
      };
    };
    python.enable = true;
    rust.enable = true;
    toml.enable = true;
    typst = {
      enable = true;
      extensions = {
        typst-preview-nvim = {
          setupOpts = {
            open_cmd = "${pkgs.surf}/bin/surf -m %s";
          };
          enable = true;
        };
      };
    };
  };
}
