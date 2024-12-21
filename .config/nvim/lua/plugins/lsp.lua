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

         -- Use system clangd instead of Mason one, because it does not work on Mac silicon
         lsp_config.clangd.setup({})

         -- Configure ltex-ls
         local dict_dir = vim.fn.expand("~") .. "/devops/dictionary/"
         require('ltex_extra').setup({
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
         })

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

         -- Register autocomplete with language servers
         local capabilities = require("blink.cmp").get_lsp_capabilities()
         for _, ls in ipairs(mason_cfg.get_installed_servers()) do
            lsp_config[ls].setup({
               capabilities = capabilities
            })
         end
      end
   },
}
