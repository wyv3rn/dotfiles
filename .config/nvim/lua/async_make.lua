-- (Modified) source: https://phelipetls.github.io/posts/async-make-in-nvim-with-lua/

local M = {}

function M.make(cmd, opts)
   opts = opts or {}
   local autosave = opts.autosave or true
   if autosave then
      vim.cmd("update")
   end

   print("Running " .. cmd .. " in background")
   local lines = { "" }
   local errorformat = vim.o.errorformat

   local function on_event(job_id, data, event)
      if event == "stdout" or event == "stderr" then
         if data then
            vim.list_extend(lines, data)
         end
      end

      if event == "exit" then
         if data == 0 then
            print("Running '" .. cmd .. "' was successful")
         else
            print("Running '" .. cmd .. "' returned exit code = " .. data)
         end
         vim.fn.setqflist({}, " ", {
            title = cmd .. " | Job ID = " .. job_id,
            lines = lines,
            efm = errorformat
         })
      end
   end

   vim.fn.jobstart(
      cmd,
      {
         on_stderr = on_event,
         on_stdout = on_event,
         on_exit = on_event,
         stdout_buffered = true,
         stderr_buffered = true,
      }
   )
end

return M
