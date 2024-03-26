-- Source for the preamble: See repo down below.

-- Creates an autocmd group for comment specifications
vim.api.nvim_create_augroup("comment", { clear = true })

-- Creates an autocmd that runs on BufEnter and BufFilePost
-- We use the `BufFilePost` trigger so that we can comment after changing file extensions
-- Without needing to repoen the buffer
vim.api.nvim_create_autocmd({"BufEnter", "BufFilePost"}, {
    group = "comment",
    pattern = {"*.c", "*.h", "*.cpp", "*.hpp"},
    callback = function()
        vim.api.nvim_buf_set_option(0, "commentstring", "// %s")
    end
})

return {
    "terrortylor/nvim-comment",
    config = function()
        require("nvim_comment").setup({
            create_mappings = false,
        })
    end
}
