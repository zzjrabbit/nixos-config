-- Enable highlight on search
vim.o.hlsearch = true

-- Use swapfiles
vim.o.swapfile = true

-- Save undo history
vim.o.undolevels = 1000

-- Decrease redraw time
vim.o.redrawtime = 100

-- Configure the number of spaces a tab is counting for
vim.o.tabstop = 4

-- Number of spaces for a step of indent
vim.o.shiftwidth = 4

-- Use ripgrep as grep tool
vim.o.grepprg = "rg --vimgrep --no-heading"
vim.o.grepformat = "%f:%l:%c:%m,%f:%l:%m"

vim.g.mapleader = " "

vim.o.number = true

vim.o.winblend = 0

vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		vim.cmd("TransparentEnable")
	end,
})

local severity = vim.diagnostic.severity

vim.diagnostic.float_diagnostic = {
	enable = false,
	updatetime = 250,
}

vim.diagnostic.config({
	virtual_text = true,
	float = {
		source = "always",
	},
	signcolumn = true,
	signs = {
		text = {
			[severity.ERROR] = "󰅙 ",
			[severity.WARN] = " ",
			[severity.INFO] = "󰋼 ",
			[severity.HINT] = "󰌵 ",
		}
	},
	update_in_insert = true,
})

local symbols = { Error = "󰅙", Info = "󰋼", Hint = "󰌵", Warn = "" }

for name, icon in pairs(symbols) do
	local hl = "DiagnosticSign" .. name
	vim.fn.sign_define(hl, { text = icon, numhl = hl, texthl = hl })
end

vim.lsp.inlay_hint.enable(true)
