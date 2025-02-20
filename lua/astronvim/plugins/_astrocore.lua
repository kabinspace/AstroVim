local astronvim = require "astronvim"
astronvim.init()

return {
  { "folke/lazy.nvim", dir = vim.env.LAZY },
  {
    "AstroNvim/AstroNvim",
    build = function()
      if astronvim.config.pin_plugins and astronvim.config.update_notification ~= false then
        local astrocore_avail, astrocore = pcall(require, "astrocore")
        if astrocore_avail then
          vim.schedule(
            function()
              astrocore.notify(
                "Pinned versions of core plugins may have been updated\nRun `:Lazy update` again to get these updates.",
                vim.log.levels.WARN
              )
            end
          )
        end
      end
    end,
    priority = 10000,
    lazy = false,
  },
  { import = "astronvim.lazy_snapshot", cond = astronvim.config.pin_plugins },
  {
    "AstroNvim/astrocore",
    dependencies = { "AstroNvim/astroui" },
    lazy = false,
    priority = 10000,
    opts = function(_, opts)
      local get_icon = require("astroui").get_icon
      return require("astrocore").extend_tbl(opts, {
        features = {
          large_buf = { notify = true, size = 1.5 * 1024 * 1024, lines = 100000, line_length = 1000 }, -- set global limits for large files
          autopairs = true, -- enable autopairs at start
          cmp = true, -- enable completion at start
          diagnostics_mode = 3, -- enable diagnostics by default
          highlighturl = true, -- highlight URLs by default
          notifications = true, -- disable notifications
        },
        diagnostics = {
          virtual_text = true,
          signs = {
            text = {
              [vim.diagnostic.severity.ERROR] = get_icon "DiagnosticError",
              [vim.diagnostic.severity.HINT] = get_icon "DiagnosticHint",
              [vim.diagnostic.severity.WARN] = get_icon "DiagnosticWarn",
              [vim.diagnostic.severity.INFO] = get_icon "DiagnosticInfo",
            },
          },
          update_in_insert = false,
          underline = true,
          severity_sort = true,
          float = {
            focused = false,
            style = "minimal",
            border = "rounded",
            source = true,
            header = "",
            prefix = "",
          },
          -- TODO: remove check when dropping support for neovim v0.10
          jump = vim.fn.has "nvim-0.11" == 1 and { float = true } or nil,
        },
        rooter = {
          enabled = true,
          detector = { "lsp", { ".git", "_darcs", ".hg", ".bzr", ".svn" }, { "lua", "MakeFile", "package.json" } },
          ignore = {
            servers = {},
            dirs = {},
          },
          autochdir = false,
          scope = "global",
          notify = false,
        },
        sessions = {
          autosave = { last = true, cwd = true },
          ignore = {
            dirs = {},
            filetypes = { "gitcommit", "gitrebase" },
            buftypes = {},
          },
        },
      } --[[@as AstroCoreOpts]])
    end,
    config = function(...) require "astronvim.plugins.configs.astrocore"(...) end,
  },
}
