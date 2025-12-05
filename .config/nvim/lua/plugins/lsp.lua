return {
   {
      "neovim/nvim-lspconfig",
      dependencies = {
         { "barreiroleo/ltex_extra.nvim" },
         { "stevearc/conform.nvim" },
      },
      config = function()
         local lsps = {
            "bashls",
            "clangd",
            "ltex_plus",
            "lua_ls",
            "marksman",
            "pyright",
            "rust_analyzer",
            "texlab",
            "elmls",
            "hls",
            "tinymist"
         }

         -- Configure ltex-ls-plus to use ltex_extra
         local ltex_bin = vim.fn.expand("~") .. "/.local/bin/lsps/ltex-ls-plus-18.6.1/bin/ltex-ls-plus"
         local dict_dir = vim.fn.expand("~") .. "/devops/dictionary/"
         vim.lsp.config["ltex_plus"] = {
            cmd = { ltex_bin },
            filetypes = {
               "markdown",
               "latex",
            },
            on_attach = function(_, _)
               require("ltex_extra").setup({
                  path = dict_dir,
                  load_langs = { "en-US", "de-DE" },
               })
            end,
            settings = {
               ltex = {
                  -- See full lust of options here: https://valentjn.github.io/ltex/settings.html
                  checkFrequency = "save",
                  sentenceCacheSize = 4096,
               }
            },
         }

         -- Configure rust-analyzer to use clippy
         vim.lsp.config["rust_analyzer"] = {
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
         }

         -- Configure texlab to not line break
         vim.lsp.config["texlab"] = {
            settings = {
               texlab = {
                  formatterLineLength = 1024,
               }
            }
         }

         -- Enable all
         for _, lsp in ipairs(lsps) do
            vim.lsp.enable(lsp)
         end

         local function lang_by_ext(filename)
            local ext_to_lang = {
               py = "python",
               rs = "rust",
               md = "markdown",
               typ = "typst",
            }
            local _, _, ext = filename:find(".*%.(%w+)$")
            if ext_to_lang[ext] then
               return ext_to_lang[ext]
            else
               return ext
            end
         end

         local function enable_autowrite(buf)
            vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave" }, {
               buffer = buf,
               callback = function()
                  vim.cmd "silent write"
               end,
            })
         end

         -- Function to enable autocompletion on almost every key stroke for a buffer
         local function enable_autocompl(buf, keys, lang)
            local exclude = { ' ', '(', ')', '[', ']', '"', "'", '{', '}', '!', ",", ";", "=", "<", ">" }
            if lang == "python" then
               table.insert(exclude, ":")
            end

            vim.api.nvim_create_autocmd("InsertCharPre", {
               buffer = buf,
               callback = function()
                  if vim.fn.pumvisible() == 1 or vim.fn.state('m') == 'm' then
                     return
                  end
                  local char = vim.v.char
                  if not vim.list_contains(exclude, char) then
                     local key = vim.keycode(keys)
                     vim.api.nvim_feedkeys(key, 'm', false)
                  end
               end
            })
         end

         local function prefer_keyword_compl(lang)
            return lang == "markdown" or lang == "tex"
         end

         -- Enable autocompletion for buffers on LspAttach
         vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("my.lsp", {}),
            callback = function(args)
               local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
               local compl_keys = "<C-x><C-n>"
               local fallback_keys = "<C-x><C-o>"
               local lang = lang_by_ext(args.file)
               if client:supports_method("textDocument/completion") then
                  vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = false })
                  if not prefer_keyword_compl(lang) then
                     compl_keys, fallback_keys = fallback_keys, compl_keys
                  end
               end
               enable_autocompl(args.buf, compl_keys, lang)
               vim.keymap.set('i', '<C-g>', fallback_keys)
               if lang == "typst" then
                  enable_autowrite(args.buf)
               end
            end
         })

         -- More formatters via conform.nvim
         require("conform").setup({
            default_format_opts = {
               lsp_format = "prefer",
            },
            formatters_by_ft = {
               python = { "black" },
               elm = { "elm_format" },
            }
         })

         -- Hammerspoon support
         if vim.fn.executable("hs") == 1 then
            local hs_version = vim.fn.system("hs -c _VERSION"):gsub("[\n\r]", "")
            local hs_path = vim.split(vim.fn.system("hs -c package.path"):gsub("[\n\r]", ""), ";")
            vim.lsp.config["lua_ls"] = {
               settings = {
                  Lua = {
                     runtime = {
                        version = hs_version,
                        path = hs_path,
                     },
                     diagnostics = { globals = { "hs" } },
                     workspace = {
                        library = {
                           string.format("%s/.hammerspoon/Spoons/EmmyLua.spoon/annotations", os.getenv "HOME"),
                        },
                     },
                  },
               },
            }
         end -- of hammerspoon support
      end
   },
}
