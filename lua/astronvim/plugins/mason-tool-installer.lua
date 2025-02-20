return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  cmd = {
    "MasonToolsInstall",
    "MasonToolsInstallSync",
    "MasonToolsUpdate",
    "MasonToolsUpdateSync",
    "MasonToolsClean",
  },
  dependencies = {
    "williamboman/mason.nvim",
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        maps.n["<Leader>pM"] = { "<Cmd>MasonToolsUpdate<CR>", desc = "Mason Update" }
      end,
    },
  },
  init = function(plugin) require("astrocore").on_load("mason.nvim", plugin.name) end,
  opts_extend = { "ensure_installed" },
  opts = {
    ensure_installed = {},
    integrations = { ["mason-lspconfig"] = false, ["mason-null-ls"] = false, ["mason-nvim-dap"] = false },
  },
  config = function(...) require "astronvim.plugins.configs.mason-tool-installer"(...) end,
}
