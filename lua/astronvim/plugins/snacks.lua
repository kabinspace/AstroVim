return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 1000,
  opts = function(_, opts)
    local get_icon = require("astroui").get_icon
    local buf_utils = require "astrocore.buffer"

    opts.dashboard = {
      preset = {
        keys = {
          { key = "n", action = "<Leader>n", icon = get_icon("FileNew", 0, true), desc = "New File  " },
          { key = "f", action = "<Leader>ff", icon = get_icon("Search", 0, true), desc = "Find File  " },
          { key = "o", action = "<Leader>fo", icon = get_icon("DefaultFile", 0, true), desc = "Recents  " },
          { key = "w", action = "<Leader>fw", icon = get_icon("WordFile", 0, true), desc = "Find Word  " },
          { key = "'", action = "<Leader>f'", icon = get_icon("Bookmarks", 0, true), desc = "Bookmarks  " },
          { key = "s", action = "<Leader>Sl", icon = get_icon("Refresh", 0, true), desc = "Last Session  " },
        },
        header = table.concat({
          " █████  ███████ ████████ ██████   ██████ ",
          "██   ██ ██         ██    ██   ██ ██    ██",
          "███████ ███████    ██    ██████  ██    ██",
          "██   ██      ██    ██    ██   ██ ██    ██",
          "██   ██ ███████    ██    ██   ██  ██████ ",
          "",
          "███    ██ ██    ██ ██ ███    ███",
          "████   ██ ██    ██ ██ ████  ████",
          "██ ██  ██ ██    ██ ██ ██ ████ ██",
          "██  ██ ██  ██  ██  ██ ██  ██  ██",
          "██   ████   ████   ██ ██      ██",
        }, "\n"),
      },
      sections = {
        { section = "header", padding = 5 },
        { section = "keys", gap = 1, padding = 3 },
        { section = "startup" },
      },
    }

    -- configure `vim.ui.input`
    opts.input = {}

    -- configure notifier
    opts.notifier = {}
    opts.notifier.icons = {
      DEBUG = get_icon "Debugger",
      ERROR = get_icon "DiagnosticError",
      INFO = get_icon "DiagnosticInfo",
      TRACE = get_icon "DiagnosticHint",
      WARN = get_icon "DiagnosticWarn",
    }

    -- configure picker and `vim.ui.select`
    opts.picker = { ui_select = true }

    opts.indent = {
      indent = {
        char = "▏",
      },
      filter = function(bufnr)
        return buf_utils.is_valid(bufnr)
          and not buf_utils.is_large(bufnr)
          and vim.g.snacks_indent ~= false
          and vim.b[bufnr].snacks_indent ~= false
      end,
      animate = { enabled = false },
    }

    opts.scope = {
      filter = function(bufnr) return buf_utils.is_valid(bufnr) and not buf_utils.is_large(bufnr) end,
    }

    opts.zen = {
      toggles = { dim = false, diagnostics = false, inlay_hints = false },
      on_open = function(win)
        -- disable snacks indent
        vim.b[win.buf].snacks_indent_old = vim.b[win.buf].snacks_indent
        vim.b[win.buf].snacks_indent = false
      end,
      on_close = function(win)
        -- restore snacks indent setting
        vim.b[win.buf].snacks_indent = vim.b[win.buf].snacks_indent_old
      end,
      win = {
        width = function() return math.min(120, math.floor(vim.o.columns * 0.75)) end,
        height = 0.9,
        backdrop = {
          transparent = false,
          win = { wo = { winhighlight = "Normal:Normal" } },
        },
        wo = {
          number = false,
          relativenumber = false,
          signcolumn = "no",
          foldcolumn = "0",
          winbar = "",
          list = false,
          showbreak = "NONE",
        },
      },
    }
  end,
  specs = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings

        -- Snacks.dashboard mappins
        maps.n["<Leader>h"] = {
          function()
            if vim.bo.filetype == "snacks_dashboard" then
              require("astrocore.buffer").close()
            else
              require("snacks").dashboard()
            end
          end,
          desc = "Home Screen",
        }

        -- Snacks.indent mappings
        maps.n["<Leader>u|"] =
          { function() require("snacks").toggle.indent():toggle() end, desc = "Toggle indent guides" }

        -- Snacks.notifier mappings
        maps.n["<Leader>uD"] = { function() require("snacks.notifier").hide() end, desc = "Dismiss notifications" }

        -- Snacks.picker and Snacks.gitbrowse mappings
        maps.n["<Leader>f"] = vim.tbl_get(opts, "_map_sections", "f")
        if vim.fn.executable "git" == 1 then
          maps.n["<Leader>g"] = vim.tbl_get(opts, "_map_sections", "g")
          maps.n["<Leader>gb"] = { function() require("snacks").picker.git_branches() end, desc = "Git branches" }
          maps.n["<Leader>gc"] = {
            function() require("snacks").picker.git_log() end,
            desc = "Git commits (repository)",
          }
          maps.n["<Leader>gC"] = {
            function() require("snacks").picker.git_log { current_file = true, follow = true } end,
            desc = "Git commits (current file)",
          }
          maps.n["<Leader>gt"] = { function() require("snacks").picker.git_status() end, desc = "Git status" }
          maps.n["<Leader>gT"] = { function() require("snacks").picker.git_stash() end, desc = "Git stash" }
          maps.n["<Leader>go"] = { function() require("snacks").gitbrowse() end, desc = "Git browse (open)" }
          maps.x["<Leader>go"] = { function() require("snacks").gitbrowse() end, desc = "Git browse (open)" }
        end
        maps.n["<Leader>f<CR>"] = { function() require("snacks").picker.resume() end, desc = "Resume previous search" }
        maps.n["<Leader>f'"] = { function() require("snacks").picker.marks() end, desc = "Find marks" }
        maps.n["<Leader>fl"] = {
          function() require("snacks").picker.lines() end,
          desc = "Find lines",
        }
        maps.n["<Leader>fa"] = {
          function() require("snacks").picker.files { dirs = { vim.fn.stdpath "config" }, desc = "Config Files" } end,
          desc = "Find AstroNvim config files",
        }
        maps.n["<Leader>fb"] = { function() require("snacks").picker.buffers() end, desc = "Find buffers" }
        maps.n["<Leader>fc"] = { function() require("snacks").picker.grep_word() end, desc = "Find word under cursor" }
        maps.n["<Leader>fC"] = { function() require("snacks").picker.commands() end, desc = "Find commands" }
        maps.n["<Leader>ff"] = {
          function()
            require("snacks").picker.files {
              hidden = vim.tbl_get((vim.uv or vim.loop).fs_stat ".git" or {}, "type") == "directory",
            }
          end,
          desc = "Find files",
        }
        maps.n["<Leader>fF"] = {
          function() require("snacks").picker.files { hidden = true, ignored = true } end,
          desc = "Find all files",
        }
        maps.n["<Leader>fg"] = { function() require("snacks").picker.git_files() end, desc = "Find git files" }
        maps.n["<Leader>fh"] = { function() require("snacks").picker.help() end, desc = "Find help" }
        maps.n["<Leader>fk"] = { function() require("snacks").picker.keymaps() end, desc = "Find keymaps" }
        maps.n["<Leader>fm"] = { function() require("snacks").picker.man() end, desc = "Find man" }
        maps.n["<Leader>fn"] = { function() require("snacks").picker.notifications() end, desc = "Find notifications" }
        maps.n["<Leader>fo"] = { function() require("snacks").picker.recent() end, desc = "Find old files" }
        maps.n["<Leader>fO"] =
          { function() require("snacks").picker.recent { filter = { cwd = true } } end, desc = "Find old files (cwd)" }
        maps.n["<Leader>fp"] = { function() require("snacks").picker.projects() end, desc = "Find projects" }
        maps.n["<Leader>fr"] = { function() require("snacks").picker.registers() end, desc = "Find registers" }
        maps.n["<Leader>fs"] = { function() require("snacks").picker.smart() end, desc = "Find buffers/recent/files" }
        maps.n["<Leader>ft"] = { function() require("snacks").picker.colorschemes() end, desc = "Find themes" }
        if vim.fn.executable "rg" == 1 then
          maps.n["<Leader>fw"] = { function() require("snacks").picker.grep() end, desc = "Find words" }
          maps.n["<Leader>fW"] = {
            function() require("snacks").picker.grep { hidden = true, ignored = true } end,
            desc = "Find words in all files",
          }
        end
        maps.n["<Leader>lD"] = { function() require("snacks").picker.diagnostics() end, desc = "Search diagnostics" }
        maps.n["<Leader>ls"] = {
          function()
            local aerial_avail, aerial = pcall(require, "aerial")
            if aerial_avail and aerial.snacks_picker then
              aerial.snacks_picker()
            else
              require("snacks").picker.lsp_symbols()
            end
          end,
          desc = "Search symbols",
        }

        -- Snacks.zen mappings
        maps.n["<Leader>uZ"] = { function() require("snacks").toggle.zen():toggle() end, desc = "Toggle zen mode" }
      end,
    },
    {
      "nvim-neo-tree/neo-tree.nvim",
      optional = true,
      opts = {
        commands = {
          find_in_dir = function(state)
            local node = state.tree:get_node()
            local path = node.type == "file" and node:get_parent_id() or node:get_id()
            require("snacks").picker.files { cwd = path }
          end,
        },
        window = { mappings = { F = "find_in_dir" } },
      },
    },
  },
}
