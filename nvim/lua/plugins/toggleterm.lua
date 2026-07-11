return {
	"akinsho/toggleterm.nvim",
	version = "*",
	lazy = false,
	config = function() 
		require("toggleterm").setup(
			{
				direction = "float",			
				float_opts = {
					border = "curved",
                },
				shell = vim.o.shell,
			}
		)
	end
}
