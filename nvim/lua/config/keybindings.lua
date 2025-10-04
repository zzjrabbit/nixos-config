vim.keymap.set('n', '<leader>e', ':lua MiniFiles.open()<CR>', opt)

vim.keymap.set('n', '<leader>ff', ':Telescope find_files<CR>', opt)
vim.keymap.set('n', '<leader>fs', ':Telescope live_grep<CR>', opt)
vim.keymap.set('n', '<leader>wr', ':SessionRestore<CR>', opt)
vim.keymap.set('n', '<leader>t', ':ToggleTerm<CR>', opt)

vim.keymap.set('n', '<C-h>', ':wincmd h<CR>', opts)
vim.keymap.set('n', '<C-j>', ':wincmd j<CR>', opts)
vim.keymap.set('n', '<C-k>', ':wincmd k<CR>', opts)
vim.keymap.set('n', '<C-l>', ':wincmd l<CR>', opts)

-- vim.keymap.set('n', '<leader>xx', ':Trouble diagnostics toggle<CR>', opts)

function _G.set_terminal_keymaps()
  local opts = {buffer = 0}
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd('autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()')

