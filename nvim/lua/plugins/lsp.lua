return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "L3MON4D3/LuaSnip",
    "j-hui/fidget.nvim",
  },
  config = function()
	require("fidget").setup({})
    require("mason").setup({
		PATH = "append",
	})

    require('mason-lspconfig').setup({
      ensure_installed = {
        "lua_ls",
        "rust_analyzer",
      },
    })
  end
}

