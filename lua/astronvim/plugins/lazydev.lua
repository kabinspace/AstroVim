return {
  "folke/lazydev.nvim",
  ft = "lua",
  cmd = "LazyDev",
  opts_extend = { "library" },
  opts = {
    library = {
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      { path = "lazy.nvim", words = { "Lazy" } },
      { path = "astrocore", words = { "AstroCore" } },
      { path = "astrolsp", words = { "AstroLSP" } },
      { path = "astroui", words = { "AstroUI" } },
      { path = "astrotheme", words = { "AstroTheme" } },
    },
  },
  specs = {
    {
      "hrsh7th/nvim-cmp",
      optional = true,
      opts = function(_, opts) table.insert(opts.sources, { name = "lazydev", group_index = 0 }) end,
    },
  },
}
