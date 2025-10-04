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
			}
		)
	end
}
