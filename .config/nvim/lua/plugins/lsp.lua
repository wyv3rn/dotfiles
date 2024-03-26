return {
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        dependencies = {
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },
            { 'neovim/nvim-lspconfig' },
            { 'hrsh7th/nvim-cmp' },
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'L3MON4D3/LuaSnip' },
            { 'barreiroleo/ltex_extra.nvim' },
        },
        config = function()
            local lsp_zero = require('lsp-zero')
            lsp_zero.extend_lspconfig()
            local lsp_config = require('lspconfig')

            -- Default: Install lsp servers with Mason
            require('mason').setup({})
            require('mason-lspconfig').setup({
                handlers = {
                    lsp_zero.default_setup,
                },
            })

            -- Use system clangd instead of Mason one, because it does not work on Mac silicon
            lsp_config.clangd.setup{}

            -- Configure autocomplete
            vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
            local luasnip = require("luasnip")
            local cmp = require("cmp")
            local select_opts = { behavior = cmp.SelectBehavior.Insert }
            local confirm_opts = { select = true }

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end
                },
                sources = {
                    { name = 'path' },
                    { name = 'nvim_lsp', keyword_length = 1 },
                    { name = 'buffer',   keyword_length = 3 },
                    { name = 'luasnip',  keyword_length = 2 },
                },
                window = {
                    documentation = cmp.config.window.bordered()
                },
                formatting = {
                    fields = { 'menu', 'abbr', 'kind' },
                },
                mapping = {
                    ['<Up>'] = cmp.mapping.select_prev_item(select_opts),
                    ['<Down>'] = cmp.mapping.select_next_item(select_opts),

                    ['<C-p>'] = cmp.mapping.select_prev_item(select_opts),
                    ['<C-n>'] = cmp.mapping.select_next_item(select_opts),

                    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-d>'] = cmp.mapping.scroll_docs(4),

                    ['<C-g>'] = cmp.mapping.abort(),
                    ['<C-c>'] = cmp.mapping.abort(),
                    ['<CR>'] = cmp.mapping.confirm(confirm_opts),

                    ['<C-f>'] = cmp.mapping(function(fallback)
                        if luasnip.jumpable(1) then
                            luasnip.jump(1)
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),

                    ['<C-b>'] = cmp.mapping(function(fallback)
                        if luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),

                    ['<C-space>'] = cmp.mapping(function()
                        local entries = cmp.get_entries()
                        if #entries > 0 and (#entries == 1 or entries[1].exact) then
                            cmp.confirm(confirm_opts)
                        elseif cmp.visible() then
                            cmp.select_next_item(select_opts)
                        else
                            cmp.complete()
                        end
                    end, { 'i', 's' }),

                    ['<Tab>'] = cmp.mapping(function(fallback)
                        local col = vim.fn.col('.') - 1
                        local entries = cmp.get_entries()
                        if #entries > 0 and (#entries == 1 or entries[1].exact) then
                            cmp.confirm(confirm_opts)
                        elseif cmp.visible() then
                            cmp.select_next_item(select_opts)
                        elseif col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
                            fallback()
                        else
                            cmp.complete()
                        end
                    end, { 'i', 's' }),
                },
            })

            -- Configure ltex-ls
            local dict_dir = vim.fn.expand("~") .. "/devops/dictionary/"
            require('ltex_extra').setup {
                path = dict_dir,
                load_langs = { "en-US", "de-DE" },
                server_opts = {
                    settings = {
                        ltex = {
                            -- Example, see full lust of options here: https://valentjn.github.io/ltex/settings.html
                            -- dictionary = { ["de-DE"] = { "korrekt" } }
                        }
                    }
                }
            }

            -- Use system version of rust-analyzer and configure it to use clippy
            lsp_config.rust_analyzer.setup({
                settings = {
                    ["rust-analyzer"] = {
                        check = {
                            command = "clippy",
                        }
                    }
                }
            })
        end
    },
}
