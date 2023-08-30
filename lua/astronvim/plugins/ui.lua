local excluded_buftypes = {
  "nofile",
  "prompt",
  "terminal",
  "quickfix",
}
local excluded_filetypes = {
  "NvimTree",
  "Trouble",
  "aerial",
  "alpha",
  "checkhealth",
  "dashboard",
  "help",
  "help",
  "lazy",
  "lspinfo",
  "man",
  "neo-tree",
  "neogitstatus",
  "startify",
}

return {
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
    enabled = vim.g.icons_enabled ~= false,
    opts = function()
      return {
        override = {
          default_icon = { icon = require("astroui").get_icon "DefaultFile" },
          deb = { icon = "", name = "Deb" },
          lock = { icon = "󰌾", name = "Lock" },
          mp3 = { icon = "󰎆", name = "Mp3" },
          mp4 = { icon = "", name = "Mp4" },
          out = { icon = "", name = "Out" },
          ["robots.txt"] = { icon = "󰚩", name = "Robots" },
          ttf = { icon = "", name = "TrueTypeFont" },
          rpm = { icon = "", name = "Rpm" },
          woff = { icon = "", name = "WebOpenFontFormat" },
          woff2 = { icon = "", name = "WebOpenFontFormat2" },
          xz = { icon = "", name = "Xz" },
          zip = { icon = "", name = "Zip" },
        },
      }
    end,
  },
  {
    "onsails/lspkind.nvim",
    lazy = true,
    opts = {
      mode = "symbol",
      symbol_map = {
        Array = "󰅪",
        Boolean = "⊨",
        Class = "󰌗",
        Constructor = "",
        Key = "󰌆",
        Namespace = "󰅪",
        Null = "NULL",
        Number = "#",
        Object = "󰀚",
        Package = "󰏗",
        Property = "",
        Reference = "",
        Snippet = "",
        String = "󰀬",
        TypeParameter = "󰊄",
        Unit = "",
      },
      menu = {},
    },
    enabled = vim.g.icons_enabled ~= false,
    config = function(...) require "astronvim.plugins.configs.lspkind"(...) end,
  },
  {
    "rcarriga/nvim-notify",
    lazy = true,
    init = function() require("astrocore").load_plugin_with_func("nvim-notify", vim, "notify") end,
    opts = {
      on_open = function(win)
        vim.api.nvim_win_set_config(win, { zindex = 175 })
        if not require("astrocore").config.features.notifications then vim.api.nvim_win_close(win, true) end
        if not package.loaded["nvim-treesitter"] then pcall(require, "nvim-treesitter") end
        vim.wo[win].conceallevel = 3
        local buf = vim.api.nvim_win_get_buf(win)
        if not pcall(vim.treesitter.start, buf, "markdown") then vim.bo[buf].syntax = "markdown" end
        vim.wo[win].spell = false
      end,
    },
    config = function(...) require "astronvim.plugins.configs.notify"(...) end,
  },
  {
    "stevearc/dressing.nvim",
    lazy = true,
    init = function() require("astrocore").load_plugin_with_func("dressing.nvim", vim.ui, { "input", "select" }) end,
    opts = {
      input = { default_prompt = "➤ " },
      select = { backend = { "telescope", "builtin" } },
    },
  },
  {
    "NvChad/nvim-colorizer.lua",
    event = "User AstroFile",
    cmd = { "ColorizerToggle", "ColorizerAttachToBuffer", "ColorizerDetachFromBuffer", "ColorizerReloadAllBuffers" },
    opts = { user_default_options = { names = false } },
  },
  {
    "echasnovski/mini.indentscope",
    event = "User AstroFile",
    dependencies = {
      {
        "lukas-reineke/indent-blankline.nvim",
        opts = {
          buftype_exclude = excluded_buftypes,
          filetype_exclude = excluded_filetypes,
          context_patterns = {
            "class",
            "return",
            "function",
            "method",
            "^if",
            "^while",
            "jsx_element",
            "^for",
            "^object",
            "^table",
            "block",
            "arguments",
            "if_statement",
            "else_clause",
            "jsx_element",
            "jsx_self_closing_element",
            "try_statement",
            "catch_clause",
            "import_statement",
            "operation_type",
          },
          show_trailing_blankline_indent = false,
          use_treesitter = true,
          char = "▏",
          context_char = "▏",
        },
      },
    },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "*",
        callback = function()
          if
            vim.tbl_contains(excluded_filetypes, vim.bo["filetype"])
            or vim.tbl_contains(excluded_buftypes, vim.bo["buftype"])
          then
            vim.b.miniindentscope_disable = true
          end
        end,
      })
    end,
    opts = function()
      local success, wk = pcall(require, "which-key")
      if success then
        local textobjects = {
          ["ii"] = [[inside indent scope]],
          ["ai"] = [[around indent scope]],
        }
        wk.register(textobjects, { mode = { "x", "o" } })
      end

      local indentscope = require "mini.indentscope"
      vim.defer_fn(function() indentscope.draw() end, 0)
      return {
        draw = {
          delay = 0,
          animation = indentscope.gen_animation.none(),
        },
        mappings = {
          object_scope = "ii",
          object_scope_with_border = "ai",
          goto_top = "[i",
          goto_bottom = "]i",
        },
        symbol = "▏",
        options = { try_as_border = true },
      }
    end,
  },
}
