return {
   {
      'VonHeikemen/lsp-zero.nvim',
      branch = 'v3.x',
      dependencies = {
         { 'williamboman/mason.nvim' },
         { 'williamboman/mason-lspconfig.nvim' },
         { 'neovim/nvim-lspconfig' },
         { 'barreiroleo/ltex_extra.nvim' },
         { 'saghen/blink.cmp' }
      },
      config = function()
         local lsp_zero = require('lsp-zero')
         lsp_zero.extend_lspconfig()
         local lsp_config = require('lspconfig')

         -- Default: Install lsp servers with Mason
         require('mason').setup({})

         local mason_cfg = require("mason-lspconfig")
         mason_cfg.setup({
            handlers = {
               lsp_zero.default_setup,
            },
         })

         -- Register autocomplete with all installed language servers
         local complete_caps = require("blink.cmp").get_lsp_capabilities()
         for _, ls in ipairs(mason_cfg.get_installed_servers()) do
            lsp_config[ls].setup({
               capabilities = complete_caps
            })
         end

         -- Use system clangd instead of Mason one, because it does not work on Mac silicon
         lsp_config.clangd.setup({
            capabilities = complete_caps,
         })

         -- Configure ltex-ls
         local dict_dir = vim.fn.expand("~") .. "/devops/dictionary/"
         require('ltex_extra').setup({
            path = dict_dir,
            load_langs = { "en-US", "de-DE" },
            server_opts = {
               capabilities = complete_caps,
               settings = {
                  ltex = {
                     -- Example, see full lust of options here: https://valentjn.github.io/ltex/settings.html
                     -- dictionary = { ["de-DE"] = { "korrekt" } }
                  }
               }
            }
         })

         -- Use system version of rust-analyzer and configure it to use clippy
         lsp_config.rust_analyzer.setup({
            capabilities = complete_caps,
            settings = {
               ["rust-analyzer"] = {
                  cargo = {
                     allFeatures = true,
                  },
                  check = {
                     command = "clippy",
                  }
               }
            }
         })

         -- Configure texlab
         lsp_config.texlab.setup({
            settings = {
               texlab = {
                  formatterLineLength = 1024,
               }
            }
         })

         -- Hammerspoon support
         if vim.fn.executable('hs') == 1 then
            local hs_version = vim.fn.system('hs -c _VERSION'):gsub('[\n\r]', '')
            local hs_path = vim.split(vim.fn.system('hs -c package.path'):gsub('[\n\r]', ''), ';')
            lsp_config.lua_ls.setup({
               capabilities = complete_caps,
               settings = {
                  Lua = {
                     runtime = {
                        version = hs_version,
                        path = hs_path,
                     },
                     diagnostics = { globals = { 'hs' } },
                     workspace = {
                        library = {
                           string.format('%s/.hammerspoon/Spoons/EmmyLua.spoon/annotations', os.getenv 'HOME'),
                        },
                     },
                  },
               },
            })
         end
      end
   },
}
