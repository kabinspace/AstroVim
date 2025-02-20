return {
  "nvim-neo-tree/neo-tree.nvim",
  specs = {
    { "nvim-lua/plenary.nvim", lazy = true },
    { "MunifTanjim/nui.nvim", lazy = true },
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        maps.n["<Leader>e"] = { "<Cmd>Neotree toggle<CR>", desc = "Toggle Explorer" }
        maps.n["<Leader>o"] = {
          function()
            if vim.bo.filetype == "neo-tree" then
              vim.cmd.wincmd "p"
            else
              vim.cmd.Neotree "focus"
            end
          end,
          desc = "Toggle Explorer Focus",
        }
        opts.autocmds.neotree_start = {
          {
            event = "BufEnter",
            desc = "Open Neo-Tree on startup with directory",
            callback = function()
              if package.loaded["neo-tree"] then
                return true
              else
                local stats = vim.uv.fs_stat(vim.api.nvim_buf_get_name(0))
                if stats and stats.type == "directory" then
                  require("lazy").load { plugins = { "neo-tree.nvim" } }
                  return true
                end
              end
            end,
          },
        }
        opts.autocmds.neotree_refresh = {
          {
            event = "TermClose",
            pattern = "*lazygit*",
            desc = "Refresh Neo-Tree sources when closing lazygit",
            callback = function()
              local manager_avail, manager = pcall(require, "neo-tree.sources.manager")
              if manager_avail then
                for _, source in ipairs { "filesystem", "git_status", "document_symbols" } do
                  local module = "neo-tree.sources." .. source
                  if package.loaded[module] then manager.refresh(require(module).name) end
                end
              end
            end,
          },
        }
      end,
    },
  },
  cmd = "Neotree",
  opts_extend = { "sources" },
  opts = function(_, opts)
    local astro, get_icon = require "astrocore", require("astroui").get_icon
    local git_available = vim.fn.executable "git" == 1
    local sources = {
      { source = "filesystem", display_name = get_icon("FolderClosed", 1, true) .. "File" },
      { source = "buffers", display_name = get_icon("DefaultFile", 1, true) .. "Bufs" },
      { source = "diagnostics", display_name = get_icon("Diagnostic", 1, true) .. "Diagnostic" },
    }
    if git_available then
      table.insert(sources, 3, { source = "git_status", display_name = get_icon("Git", 1, true) .. "Git" })
    end
    opts = astro.extend_tbl(opts, {
      enable_git_status = git_available,
      auto_clean_after_session_restore = true,
      close_if_last_window = true,
      sources = { "filesystem", "buffers", git_available and "git_status" or nil },
      source_selector = {
        winbar = true,
        content_layout = "center",
        sources = sources,
      },
      default_component_configs = {
        indent = {
          padding = 0,
          expander_collapsed = get_icon "FoldClosed",
          expander_expanded = get_icon "FoldOpened",
        },
        icon = {
          folder_closed = get_icon "FolderClosed",
          folder_open = get_icon "FolderOpen",
          folder_empty = get_icon "FolderEmpty",
          folder_empty_open = get_icon "FolderEmpty",
          default = get_icon "DefaultFile",
        },
        modified = { symbol = get_icon "FileModified" },
        git_status = {
          symbols = {
            added = get_icon "GitAdd",
            deleted = get_icon "GitDelete",
            modified = get_icon "GitChange",
            renamed = get_icon "GitRenamed",
            untracked = get_icon "GitUntracked",
            ignored = get_icon "GitIgnored",
            unstaged = get_icon "GitUnstaged",
            staged = get_icon "GitStaged",
            conflict = get_icon "GitConflict",
          },
        },
      },
      commands = {
        system_open = function(state) vim.ui.open(state.tree:get_node():get_id()) end,
        parent_or_close = function(state)
          local node = state.tree:get_node()
          if node:has_children() and node:is_expanded() then
            state.commands.toggle_node(state)
          else
            require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
          end
        end,
        child_or_open = function(state)
          local node = state.tree:get_node()
          if node:has_children() then
            if not node:is_expanded() then -- if unexpanded, expand
              state.commands.toggle_node(state)
            else -- if expanded and has children, seleect the next child
              if node.type == "file" then
                state.commands.open(state)
              else
                require("neo-tree.ui.renderer").focus_node(state, node:get_child_ids()[1])
              end
            end
          else -- if has no children
            state.commands.open(state)
          end
        end,
        copy_selector = function(state)
          local node = state.tree:get_node()
          local filepath = node:get_id()
          local filename = node.name
          local modify = vim.fn.fnamemodify

          local vals = {
            ["BASENAME"] = modify(filename, ":r"),
            ["EXTENSION"] = modify(filename, ":e"),
            ["FILENAME"] = filename,
            ["PATH (CWD)"] = modify(filepath, ":."),
            ["PATH (HOME)"] = modify(filepath, ":~"),
            ["PATH"] = filepath,
            ["URI"] = vim.uri_from_fname(filepath),
          }

          local options = vim.tbl_filter(function(val) return vals[val] ~= "" end, vim.tbl_keys(vals))
          if vim.tbl_isempty(options) then
            astro.notify("No values to copy", vim.log.levels.WARN)
            return
          end
          table.sort(options)
          vim.ui.select(options, {
            prompt = "Choose to copy to clipboard:",
            format_item = function(item) return ("%s: %s"):format(item, vals[item]) end,
          }, function(choice)
            local result = vals[choice]
            if result then
              astro.notify(("Copied: `%s`"):format(result))
              vim.fn.setreg("+", result)
            end
          end)
        end,
      },
      window = {
        width = 30,
        mappings = {
          ["<S-CR>"] = "system_open",
          ["<Space>"] = false,
          ["[b"] = "prev_source",
          ["]b"] = "next_source",
          O = "system_open",
          Y = "copy_selector",
          h = "parent_or_close",
          l = "child_or_open",
        },
        fuzzy_finder_mappings = { -- define keymaps for filter popup window in fuzzy_finder_mode
          ["<C-J>"] = "move_cursor_down",
          ["<C-K>"] = "move_cursor_up",
        },
      },
      filesystem = {
        follow_current_file = { enabled = true },
        filtered_items = { hide_gitignored = git_available },
        hijack_netrw_behavior = "open_current",
        use_libuv_file_watcher = vim.fn.has "win32" ~= 1,
      },
    })

    if not opts.event_handlers then opts.event_handlers = {} end
    table.insert(opts.event_handlers, {
      event = "neo_tree_buffer_enter",
      handler = function(_)
        vim.opt_local.signcolumn = "auto"
        vim.opt_local.foldcolumn = "0"
      end,
    })
    return opts
  end,
}
