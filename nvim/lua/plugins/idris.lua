return {
    "ShinKage/idris2-nvim",
    dependencies = {
        "neovim/nvim-lspconfig",
        "MunifTanjim/nui.nvim",
    },
    config = function()
        require('idris2').setup({})
    end
}

