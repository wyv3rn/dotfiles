return {
    'nvim-treesitter/nvim-treesitter',
    build = ":TSUpdate",
    config = function()
        local treesitter = require("nvim-treesitter.configs")
        treesitter.setup {
            ensure_installed = {
                "c",
                "lua",
                "vim",
                "vimdoc",
                "query",
                "comment",
                "latex",
                "rust",
                "bash",
                "python",
                "javascript",
                "typescript" },
            highlight = {
                enable = true,
            },
            indent = {
                enable = true,
            }
        }
    end
}
