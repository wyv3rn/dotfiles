local telescope = require("telescope.builtin")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values

local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {}

local builder = function(action)
   return function(opts)
      opts = opts or {}
      pickers.new(opts, {
         prompt_title = "Oneshot project file",
         finder = finders.new_oneshot_job({ "find-projects" }, opts),
         sorter = conf.generic_sorter(opts),
         attach_mappings = function(prompt_bufnr, _)
            actions.select_default:replace(function()
               actions.close(prompt_bufnr)
               local selection = action_state.get_selected_entry()
               if selection ~= nil then
                  action(selection[1])
               end
            end)
            return true
         end,
      }):find()
   end
end

local switcher = function(arg)
   vim.cmd("cd " .. arg)
   vim.cmd("e .")
end

local oneshotter = function(arg)
   telescope.find_files({ cwd = arg })
end

M.switch = builder(switcher)
M.oneshot_file = builder(oneshotter)

return M
