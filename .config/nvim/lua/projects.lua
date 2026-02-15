local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values

local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local M = {}

local history_file = vim.fn.stdpath("data") .. "projects.json"
local history = {}

vim.api.nvim_create_autocmd("DirChanged", {
   callback = function()
      table.insert(history, 1, vim.v.event.cwd)
   end
})

M.telescope_projects = function(opts)
   opts = opts or {}
   pickers.new(opts, {
      prompt_title = "Projects",
      finder = finders.new_table {
         results = history
      },
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
         actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            if selection ~= nil then
               vim.cmd("cd " .. selection[1])
            end
         end)
         return true
      end,
   }):find()
end

return M
