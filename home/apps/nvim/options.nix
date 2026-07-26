{ pkgs }:

{ lib, ... }: {
  vim.lineNumberMode = "number";
  vim.clipboard = {
    enable = true;
    registers = "unnamedplus";
    providers.wl-copy.enable = true;
  };
  vim.options = {
    cursorline = true;
    cursorlineopt = "both";
    # Neovim only loads project-local configuration after it has been
    # explicitly approved through its hash-based trust database (`:trust`).
    exrc = true;
    endofline = true;
    fixendofline = true;
    grepprg = "${lib.getExe pkgs.ripgrep} --vimgrep --no-heading";
    redrawtime = 100;
    shiftwidth = 4;
    tabstop = 4;
    termguicolors = true;
  };
}
