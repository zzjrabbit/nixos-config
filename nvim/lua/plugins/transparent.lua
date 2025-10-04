return {
    "xiyaowong/transparent.nvim",
	config = function() 
		require("transparent").setup({
			
			groups = {
    			'Normal', 'NormalNC', "NormalFloat", "TelescopeNormal", 'Comment', 'Constant', 'Special', 'Identifier',
	    		'Statement', 'PreProc', 'Type', 'Underlined', 'Todo', 'String', 'Function',
    			'Conditional', 'Repeat', 'Operator', 'Structure', 'LineNr', 'NonText',
    			'SignColumn', 'CursorLine', 'CursorLineNr', 'StatusLine', 'StatusLineNC',
    			'EndOfBuffer',
  			},
		})
	end
}
