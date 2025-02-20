return {
  "echasnovski/mini.icons",
  lazy = true,
  init = function()
    package.preload["nvim-web-devicons"] = function()
      require("mini.icons").mock_nvim_web_devicons()
      return package.loaded["nvim-web-devicons"]
    end
  end,
  opts = {},
  specs = {
    {
      "nvim-neo-tree/neo-tree.nvim",
      optional = true,
      opts = {
        default_component_configs = {
          icon = {
            provider = function(icon, node)
              local text, hl
              local mini_icons = require "mini.icons"
              if node.type == "file" then
                text, hl = mini_icons.get("file", node.name)
              elseif node.type == "directory" then
                text, hl = mini_icons.get("directory", node.name)
                if node:is_expanded() then text = nil end
              end

              if text then icon.text = text end
              if hl then icon.highlight = hl end
            end,
          },
          kind_icon = {
            provider = function(icon, node)
              icon.text, icon.highlight = require("mini.icons").get("lsp", node.extra.kind.name)
            end,
          },
        },
      },
    },
  },
}
