local plugin = {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons"
	},
	event = "VeryLazy"
}

plugin.config = function()
	require("lualine").setup({
		options = {
			theme = "auto",
			globalstatus = true,
		}
	})
end

return plugin
