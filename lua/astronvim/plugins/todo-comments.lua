return {
  "folke/todo-comments.nvim",
  dependencies = { { "folke/snacks.nvim", optional = true } },
  cmd = { "TodoTrouble", "TodoTelescope", "TodoLocList", "TodoQuickFix" },
  event = "User AstroFile",
  specs = {
    { "nvim-lua/plenary.nvim", lazy = true },
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        if require("astrocore").is_available "telescope.nvim" then
          maps.n["<Leader>fT"] = { "<Cmd>TodoTelescope<CR>", desc = "Find TODOs" }
        elseif require("astrocore").is_available "snacks.nvim" then
          maps.n["<Leader>fT"] = {
            function()
              if not package.loaded["todo-comments"] then -- make sure to load todo-comments
                require("lazy").load { plugins = { "todo-comments.nvim" } }
              end
              require("snacks").picker.todo_comments()
            end,
            desc = "Find TODOs",
          }
        end
        maps.n["]T"] = { function() require("todo-comments").jump_next() end, desc = "Next TODO comment" }
        maps.n["[T"] = { function() require("todo-comments").jump_prev() end, desc = "Previous TODO comment" }
      end,
    },
  },
  opts = {},
}
