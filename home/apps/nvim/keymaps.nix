{
  vim.keymaps = [
    {
      mode = "n";
      key = "<F1>";
      action = "function() Snacks.picker.commands() end";
      lua = true;
      desc = "Commands";
    }
    {
      mode = "n";
      key = "<leader>,";
      action = "function() Snacks.picker.buffers() end";
      lua = true;
      desc = "Buffers";
    }
    {
      mode = "n";
      key = "<leader>e";
      action = "function() Snacks.explorer() end";
      lua = true;
      desc = "Explorer";
    }
    {
      mode = "n";
      key = "<leader>ff";
      action = "function() Snacks.picker.files() end";
      lua = true;
      desc = "Find files";
    }
    {
      mode = "n";
      key = "<leader>fs";
      action = "function() Snacks.picker.grep() end";
      lua = true;
      desc = "Grep";
    }
    {
      mode = "n";
      key = "<leader>t";
      action = "function() Snacks.terminal() end";
      lua = true;
      desc = "Toggle Nushell terminal";
    }
    {
      mode = "n";
      key = "<leader><Tab>n";
      action = "<cmd>tabnew<cr>";
      desc = "New tab";
    }
    {
      mode = "n";
      key = "<leader><Tab>h";
      action = "<cmd>tabprevious<cr>";
      desc = "Previous tab";
    }
    {
      mode = "n";
      key = "<leader><Tab>l";
      action = "<cmd>tabnext<cr>";
      desc = "Next tab";
    }
    {
      mode = "n";
      key = "<leader><Tab>c";
      action = "<cmd>tabclose<cr>";
      desc = "Close tab";
    }
    {
      mode = "n";
      key = "<leader><Tab>o";
      action = "<cmd>tabonly<cr>";
      desc = "Close other tabs";
    }
    {
      mode = "n";
      key = "<C-h>";
      action = "<cmd>wincmd h<cr>";
      desc = "Focus left window";
    }
    {
      mode = "n";
      key = "<C-j>";
      action = "<cmd>wincmd j<cr>";
      desc = "Focus lower window";
    }
    {
      mode = "n";
      key = "<C-k>";
      action = "<cmd>wincmd k<cr>";
      desc = "Focus upper window";
    }
    {
      mode = "n";
      key = "<C-l>";
      action = "<cmd>wincmd l<cr>";
      desc = "Focus right window";
    }
    {
      mode = "n";
      key = "]g";
      action = "function() vim.diagnostic.jump({ count = 1 }) end";
      lua = true;
      desc = "Next diagnostic";
    }
    {
      mode = "n";
      key = "[g";
      action = "function() vim.diagnostic.jump({ count = -1 }) end";
      lua = true;
      desc = "Previous diagnostic";
    }
    {
      mode = "n";
      key = "<leader>gs";
      action = "<cmd>DiffviewOpen<cr>";
      desc = "Git changes";
    }
    {
      mode = "n";
      key = "<leader>cf";
      action = "function() require(\"conform\").format({ async = true }) end";
      lua = true;
      desc = "Format";
    }
    {
      mode = "n";
      key = "<leader>lr";
      action = "<cmd>LeanRestartFile<cr>";
      desc = "Restart Lean file";
    }
    {
      mode = "n";
      key = "<leader>p";
      action = "<cmd>TypstPreview<cr>";
      desc = "Preview Typst file";
    }
  ];
}
