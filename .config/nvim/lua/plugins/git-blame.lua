return {
    "FabijanZulj/blame.nvim",
    config = function()
        require("blame").setup({
            virtual_style = "right_aligned",
            merge_consecutive = false,
        })
    end
}
