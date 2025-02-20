return {
  "mfussenegger/nvim-dap",
  lazy = true,
  specs = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local get_icon = require("astroui").get_icon
        local maps = opts.mappings
        maps.n["<Leader>d"] = vim.tbl_get(opts, "_map_sections", "d")
        -- modified function keys found with `showkey -a` in the terminal to get key code
        -- run `nvim -V3log +quit` and search through the "Terminal info" in the `log` file for the correct keyname
        maps.n["<F5>"] = { function() require("dap").continue() end, desc = "Debugger: Start" }
        maps.n["<F17>"] = { function() require("dap").terminate() end, desc = "Debugger: Stop" } -- Shift+F5
        maps.n["<F21>"] = { -- Shift+F9
          function()
            vim.ui.input({ prompt = "Condition: " }, function(condition)
              if condition then require("dap").set_breakpoint(condition) end
            end)
          end,
          desc = "Debugger: Conditional Breakpoint",
        }
        maps.n["<F29>"] = { function() require("dap").restart_frame() end, desc = "Debugger: Restart" } -- Control+F5
        maps.n["<F6>"] = { function() require("dap").pause() end, desc = "Debugger: Pause" }
        maps.n["<F9>"] = { function() require("dap").toggle_breakpoint() end, desc = "Debugger: Toggle Breakpoint" }
        maps.n["<F10>"] = { function() require("dap").step_over() end, desc = "Debugger: Step Over" }
        maps.n["<F11>"] = { function() require("dap").step_into() end, desc = "Debugger: Step Into" }
        maps.n["<F23>"] = { function() require("dap").step_out() end, desc = "Debugger: Step Out" } -- Shift+F11
        maps.n["<Leader>db"] = { function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint (F9)" }
        maps.n["<Leader>dB"] = { function() require("dap").clear_breakpoints() end, desc = "Clear Breakpoints" }
        maps.n["<Leader>dc"] = { function() require("dap").continue() end, desc = "Start/Continue (F5)" }
        maps.n["<Leader>dC"] = {
          function()
            vim.ui.input({ prompt = "Condition: " }, function(condition)
              if condition then require("dap").set_breakpoint(condition) end
            end)
          end,
          desc = "Conditional Breakpoint (S-F9)",
        }
        maps.n["<Leader>di"] = { function() require("dap").step_into() end, desc = "Step Into (F11)" }
        maps.n["<Leader>do"] = { function() require("dap").step_over() end, desc = "Step Over (F10)" }
        maps.n["<Leader>dO"] = { function() require("dap").step_out() end, desc = "Step Out (S-F11)" }
        maps.n["<Leader>dq"] = { function() require("dap").close() end, desc = "Close Session" }
        maps.n["<Leader>dQ"] = { function() require("dap").terminate() end, desc = "Terminate Session (S-F5)" }
        maps.n["<Leader>dp"] = { function() require("dap").pause() end, desc = "Pause (F6)" }
        maps.n["<Leader>dr"] = { function() require("dap").restart_frame() end, desc = "Restart (C-F5)" }
        maps.n["<Leader>dR"] = { function() require("dap").repl.toggle() end, desc = "Toggle REPL" }
        maps.n["<Leader>ds"] = { function() require("dap").run_to_cursor() end, desc = "Run To Cursor" }

        if not opts.signs then opts.signs = {} end
        opts.signs.DapBreakpoint = { text = get_icon "DapBreakpoint", texthl = "DiagnosticInfo" }
        opts.signs.DapBreakpointCondition = { text = get_icon "DapBreakpointCondition", texthl = "DiagnosticInfo" }
        opts.signs.DapBreakpointRejected = { text = get_icon "DapBreakpointRejected", texthl = "DiagnosticError" }
        opts.signs.DapLogPoint = { text = get_icon "DapLogPoint", texthl = "DiagnosticInfo" }
        opts.signs.DapStopped = { text = get_icon "DapStopped", texthl = "DiagnosticWarn" }
      end,
    },
  },
  dependencies = {
    {
      "jay-babu/mason-nvim-dap.nvim",
      dependencies = { "nvim-dap", "williamboman/mason.nvim" },
      cmd = { "DapInstall", "DapUninstall" },
      opts_extend = { "ensure_installed" },
      opts = { ensure_installed = {}, handlers = {} },
      config = function(...) require "astronvim.plugins.configs.mason-nvim-dap"(...) end,
    },
    {
      "rcarriga/nvim-dap-ui",
      lazy = true,
      specs = {
        {
          "AstroNvim/astrocore",
          opts = function(_, opts)
            local maps = opts.mappings
            maps.n["<Leader>d"] = vim.tbl_get(opts, "_map_sections", "d")
            maps.v["<Leader>d"] = vim.tbl_get(opts, "_map_sections", "d")
            maps.n["<Leader>dE"] = {
              function()
                vim.ui.input({ prompt = "Expression: " }, function(expr)
                  if expr then require("dapui").eval(expr, { enter = true }) end
                end)
              end,
              desc = "Evaluate Input",
            }
            maps.n["<Leader>du"] = { function() require("dapui").toggle() end, desc = "Toggle Debugger UI" }
            maps.n["<Leader>dh"] = { function() require("dap.ui.widgets").hover() end, desc = "Debugger Hover" }
            maps.v["<Leader>dE"] = { function() require("dapui").eval() end, desc = "Evaluate Input" }
          end,
        },
      },
      dependencies = { { "nvim-neotest/nvim-nio", lazy = true } },
      opts = { floating = { border = "rounded" } },
      config = function(...) require "astronvim.plugins.configs.nvim-dap-ui"(...) end,
    },
    {
      "rcarriga/cmp-dap",
      lazy = true,
      dependencies = { "hrsh7th/nvim-cmp" },
      config = function(...) require "astronvim.plugins.configs.cmp-dap"(...) end,
    },
  },
  config = function(...) require "astronvim.plugins.configs.nvim-dap"(...) end,
}
