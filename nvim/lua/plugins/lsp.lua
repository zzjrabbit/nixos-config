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

	vim.lsp.config('hls', {
    	cmd = { "haskell-language-server-wrapper", "--lsp" },
    	on_attach = on_attach,
    	capabilities = capabilities,
	})
	vim.lsp.enable('hls')


    vim.filetype.add({ extension = { lig = 'ligare' } })
    vim.api.nvim_create_autocmd('FileType', {
        pattern = 'ligare',
        callback = function(args)
            vim.lsp.start({
                name = 'ligare',
                cmd = { '/home/raca/code/ligare/target/release/ligls', '--stdio' },
                root_dir = vim.fs.root(args.buf, { 'ligare.toml' }),
            })
        end,
    })

    require('mason-lspconfig').setup({
      ensure_installed = {
        "rust_analyzer",
      },
	  automatic_installation = {
        exclude = { "hls" }
      },
	  on_init = function(client, _)
        local original_handler = client.handlers["window/showMessage"]
        client.handlers["window/showMessage"] = function(err, method, result)
			if result and result.message and result.message:find("restart file") then
				return
			end
			if original_handler then
				original_handler(err, method, result)
			end
	  	end
	  end,
    })
  end
}

