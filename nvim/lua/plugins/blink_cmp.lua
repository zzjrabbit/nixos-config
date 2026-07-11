return {
	'saghen/blink.cmp',
  	-- optional: provides snippets for the snippet source
  	dependencies = { 'rafamadriz/friendly-snippets' },
	build = 'cargo build --release',
  	-- use a release tag to download pre-built binaries
  	version = '1.*',
	config = function()
		require("blink.cmp").setup({
		keymap = {
			preset = "super-tab",
    	},
    	sources = {
        	default = { 'lsp', 'path', 'buffer', 'snippets' },
        	providers = {
        	},
    	},
    	-- Recommended to avoid unnecessary request
    	completion = { 
			trigger = { prefetch_on_insert = false },
			keyword = { range = "full" },
		},
	})
	
	end
}
