return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    commands = {
      AstroVersion = {
        function()
          local version = require("astronvim").version()
          if version then require("astrocore").notify(("Version: *%s*"):format(version)) end
        end,
        desc = "Check AstroNvim Version",
      },
      AstroReload = { function() require("astrocore").reload() end, desc = "Reload AstroNvim (Experimental)" },
      AstroUpdate = { function() require("astrocore").update_packages() end, desc = "Update Lazy and Mason" },
      AstroRename = {
        function(opts) require("astrocore").rename_file { to = opts.fargs[1], overwrite = opts.bang } end,
        desc = "Rename the current file, optionally new filename argument",
        bang = true,
        nargs = "?",
        complete = "file",
      },
    },
    autocmds = {
      auto_quit = {
        {
          event = "BufEnter",
          desc = "Quit AstroNvim if more than one window is open and only sidebar windows are list",
          callback = function()
            local wins = vim.api.nvim_tabpage_list_wins(0)
            -- Both neo-tree and aerial will auto-quit if there is only a single window left
            if #wins <= 1 then return end
            local sidebar_fts = { aerial = true, ["neo-tree"] = true }
            for _, winid in ipairs(wins) do
              if vim.api.nvim_win_is_valid(winid) then
                local bufnr = vim.api.nvim_win_get_buf(winid)
                local filetype = vim.bo[bufnr].filetype
                -- If any visible windows are not sidebars, early return
                if not sidebar_fts[filetype] then
                  return
                -- If the visible window is a sidebar
                else
                  -- only count filetypes once, so remove a found sidebar from the detection
                  sidebar_fts[filetype] = nil
                end
              end
            end
            if #vim.api.nvim_list_tabpages() > 1 then
              vim.cmd.tabclose()
            else
              vim.cmd.qall()
            end
          end,
        },
      },
      bufferline = {
        {
          event = { "BufAdd", "BufEnter", "TabNewEntered" },
          desc = "Update buffers when adding new buffers",
          callback = function(args)
            local buf_utils = require "astrocore.buffer"
            if not vim.t.bufs then vim.t.bufs = {} end
            if not buf_utils.is_valid(args.buf) then return end
            if args.buf ~= buf_utils.current_buf then
              buf_utils.last_buf = buf_utils.is_valid(buf_utils.current_buf) and buf_utils.current_buf or nil
              buf_utils.current_buf = args.buf
            end
            local bufs = vim.t.bufs
            if not vim.tbl_contains(bufs, args.buf) then
              table.insert(bufs, args.buf)
              vim.t.bufs = bufs
            end
            vim.t.bufs = vim.tbl_filter(buf_utils.is_valid, vim.t.bufs)
            require("astrocore").event "BufsUpdated"
          end,
        },
        {
          event = { "BufDelete", "TermClose" },
          desc = "Update buffers when deleting buffers",
          callback = function(args)
            local removed
            for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
              local bufs = vim.t[tab].bufs
              if bufs then
                for i, bufnr in ipairs(bufs) do
                  if bufnr == args.buf then
                    removed = true
                    table.remove(bufs, i)
                    vim.t[tab].bufs = bufs
                    break
                  end
                end
              end
            end
            vim.t.bufs = vim.tbl_filter(require("astrocore.buffer").is_valid, vim.t.bufs)
            if removed then require("astrocore").event "BufsUpdated" end
            vim.cmd.redrawtabline()
          end,
        },
      },
      checktime = {
        {
          event = { "FocusGained", "TermClose", "TermLeave" },
          desc = "Check if buffers changed on editor focus",
          command = "checktime",
        },
      },
      create_dir = {
        {
          event = "BufWritePre",
          desc = "Automatically create parent directories if they don't exist when saving a file",
          callback = function(args)
            local file = args.match
            if not require("astrocore.buffer").is_valid(args.buf) or file:match "^%w+:[\\/][\\/]" then return end
            vim.fn.mkdir(vim.fn.fnamemodify(vim.uv.fs_realpath(file) or file, ":p:h"), "p")
          end,
        },
      },
      editorconfig_filetype = {
        {
          event = "FileType",
          desc = "Ensure editorconfig settings take highest precedence",
          callback = function(args)
            if vim.F.if_nil(vim.b.editorconfig, vim.g.editorconfig) then
              local editorconfig_avail, editorconfig = pcall(require, "editorconfig")
              if editorconfig_avail then editorconfig.config(args.buf) end
            end
          end,
        },
      },
      file_user_events = {
        {
          event = { "BufReadPost", "BufNewFile", "BufWritePost" },
          desc = "AstroNvim user events for file detection (AstroFile and AstroGitFile)",
          callback = function(args)
            if vim.b[args.buf].astrofile_checked then return end
            vim.b[args.buf].astrofile_checked = true
            vim.schedule(function()
              if not vim.api.nvim_buf_is_valid(args.buf) then return end
              local astro = require "astrocore"
              local current_file = vim.api.nvim_buf_get_name(args.buf)
              if vim.g.vscode or not (current_file == "" or vim.bo[args.buf].buftype == "nofile") then
                local skip_augroups = {}
                for _, autocmd in ipairs(vim.api.nvim_get_autocmds { event = args.event }) do
                  if autocmd.group_name then skip_augroups[autocmd.group_name] = true end
                end
                skip_augroups["filetypedetect"] = false -- don't skip filetypedetect events
                astro.event "File"
                local folder = vim.fn.fnamemodify(current_file, ":p:h")
                if vim.fn.has "win32" == 1 then folder = ('"%s"'):format(folder) end
                if vim.fn.executable "git" == 1 then
                  if astro.cmd({ "git", "-C", folder, "rev-parse" }, false) or astro.file_worktree() then
                    astro.event "GitFile"
                    pcall(vim.api.nvim_del_augroup_by_name, "file_user_events")
                  end
                else
                  pcall(vim.api.nvim_del_augroup_by_name, "file_user_events")
                end
                vim.schedule(function()
                  if require("astrocore.buffer").is_valid(args.buf) then
                    for _, autocmd in ipairs(vim.api.nvim_get_autocmds { event = args.event }) do
                      if autocmd.group_name and not skip_augroups[autocmd.group_name] then
                        vim.api.nvim_exec_autocmds(
                          args.event,
                          { group = autocmd.group_name, buffer = args.buf, data = args.data }
                        )
                        skip_augroups[autocmd.group_name] = true
                      end
                    end
                  end
                end)
              end
            end)
          end,
        },
      },
      highlightyank = {
        {
          event = "TextYankPost",
          desc = "Highlight yanked text",
          pattern = "*",
          callback = function() (vim.hl or vim.highlight).on_yank() end,
        },
      },
      large_buf_settings = {
        {
          event = "User",
          desc = "Disable certain functionality on very large files",
          pattern = "AstroLargeBuf",
          callback = function(args)
            vim.opt_local.list = false -- disable list chars
            vim.b[args.buf].autoformat = false -- disable autoformat on save
            vim.b[args.buf].cmp_enabled = false -- disable completion
          end,
        },
      },
      q_close_windows = {
        {
          event = "BufWinEnter",
          desc = "Make q close help, man, quickfix, dap floats",
          callback = function(args)
            -- Add cache for buffers that have already had mappings created
            if not vim.g.q_close_windows then vim.g.q_close_windows = {} end
            -- If the buffer has been checked already, skip
            if vim.g.q_close_windows[args.buf] then return end
            -- Mark the buffer as checked
            vim.g.q_close_windows[args.buf] = true
            -- Check to see if `q` is already mapped to the buffer (avoids overwriting)
            for _, map in ipairs(vim.api.nvim_buf_get_keymap(args.buf, "n")) do
              if map.lhs == "q" then return end
            end
            -- If there is no q mapping already and the buftype is a non-real file, create one
            if vim.tbl_contains({ "help", "nofile", "quickfix" }, vim.bo[args.buf].buftype) then
              vim.keymap.set("n", "q", "<Cmd>close<CR>", {
                desc = "Close window",
                buffer = args.buf,
                silent = true,
                nowait = true,
              })
            end
          end,
        },
        {
          event = "BufDelete",
          desc = "Clean up q_close_windows cache",
          callback = function(args)
            if vim.g.q_close_windows then vim.g.q_close_windows[args.buf] = nil end
          end,
        },
      },
      restore_cursor = {
        {
          event = "BufReadPost",
          desc = "Restore last cursor position when opening a file",
          callback = function(args)
            local buf = args.buf
            if vim.b[buf].last_loc_restored or vim.tbl_contains({ "gitcommit" }, vim.bo[buf].filetype) then return end
            vim.b[buf].last_loc_restored = true
            local mark = vim.api.nvim_buf_get_mark(buf, '"')
            if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(buf) then
              pcall(vim.api.nvim_win_set_cursor, 0, mark)
            end
          end,
        },
      },
      -- TODO: remove autocommand when dropping support for Neovim v0.10
      terminal_settings = vim.fn.has "nvim-0.11" ~= 1 and {
        {
          event = "TermOpen",
          desc = "Disable line number/fold column/sign column for terminals",
          callback = function()
            vim.opt_local.number = false
            vim.opt_local.relativenumber = false
            vim.opt_local.foldcolumn = "0"
            vim.opt_local.signcolumn = "no"
          end,
        },
      } or false,
      unlist_quickfix = {
        {
          event = "FileType",
          desc = "Unlist quickfix buffers",
          pattern = "qf",
          callback = function() vim.opt_local.buflisted = false end,
        },
      },
    },
    on_keys = {
      auto_hlsearch = {
        function(char)
          if vim.fn.mode() == "n" then
            local new_hlsearch = vim.tbl_contains({ "<CR>", "n", "N", "*", "#", "?", "/" }, vim.fn.keytrans(char))
            if vim.opt.hlsearch:get() ~= new_hlsearch then vim.opt.hlsearch = new_hlsearch end
          end
        end,
      },
    },
  },
}
