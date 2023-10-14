require 'nvim-treesitter.configs'.setup {
    ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "comment", "rust", "bash", "python", "javascript",
        "typescript" },
    highlight = {
        enable = true,
    },
    indent = {
        enable = true,
    }
}
