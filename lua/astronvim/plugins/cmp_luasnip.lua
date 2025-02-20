local function has_words_before()
  local line, col = (unpack or table.unpack)(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
end
local function is_visible(cmp) return cmp.core.view:visible() or vim.fn.pumvisible() == 1 end

return {
  {
    "hrsh7th/nvim-cmp",
    specs = {
      {
        "AstroNvim/astrolsp",
        optional = true,
        opts = function(_, opts)
          local astrocore = require "astrocore"
          if astrocore.is_available "cmp-nvim-lsp" then
            opts.capabilities = astrocore.extend_tbl(opts.capabilities, {
              textDocument = {
                completion = {
                  completionItem = {
                    documentationFormat = { "markdown", "plaintext" },
                    snippetSupport = true,
                    preselectSupport = true,
                    insertReplaceSupport = true,
                    labelDetailsSupport = true,
                    deprecatedSupport = true,
                    commitCharactersSupport = true,
                    tagSupport = { valueSet = { 1 } },
                    resolveSupport = { properties = { "documentation", "detail", "additionalTextEdits" } },
                  },
                },
              },
            })
          end
        end,
      },
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          local maps = opts.mappings
          maps.n["<Leader>uc"] =
            { function() require("astrocore.toggles").buffer_cmp() end, desc = "Toggle autocompletion (buffer)" }
          maps.n["<Leader>uC"] =
            { function() require("astrocore.toggles").cmp() end, desc = "Toggle autocompletion (global)" }
        end,
      },
    },
    dependencies = {
      { "hrsh7th/cmp-buffer", lazy = true },
      { "hrsh7th/cmp-path", lazy = true },
      { "hrsh7th/cmp-nvim-lsp", lazy = true },
    },
    event = "InsertEnter",
    opts_extend = { "sources" },
    opts = function(_, opts)
      local cmp, astro = require "cmp", require "astrocore"

      local sources = {}
      for source_plugin, source in pairs {
        ["cmp-buffer"] = { name = "buffer", priority = 500, group_index = 2 },
        ["cmp-nvim-lsp"] = { name = "nvim_lsp", priority = 1000 },
        ["cmp-path"] = { name = "path", priority = 250 },
      } do
        if astro.is_available(source_plugin) then table.insert(sources, source) end
      end

      local function get_icon_provider()
        local _, mini_icons = pcall(require, "mini.icons")
        if _G.MiniIcons then
          return function(kind) return mini_icons.get("lsp", kind or "") end
        end
        local lspkind_avail, lspkind = pcall(require, "lspkind")
        if lspkind_avail then
          return function(kind) return lspkind.symbolic(kind, { mode = "symbol" }) end
        end
      end
      local icon_provider = get_icon_provider()

      local function format(entry, item)
        local highlight_colors_avail, highlight_colors = pcall(require, "nvim-highlight-colors")
        local color_item = highlight_colors_avail and highlight_colors.format(entry, { kind = item.kind })
        if icon_provider then
          local icon = icon_provider(item.kind)
          if icon then item.kind = icon end
        end
        if color_item and color_item.abbr and color_item.abbr_hl_group then
          item.kind, item.kind_hl_group = color_item.abbr, color_item.abbr_hl_group
        end
        return item
      end

      return astro.extend_tbl(opts, {
        enabled = function()
          -- Disable completion when recording macros
          if vim.fn.reg_recording() ~= "" or vim.fn.reg_executing() ~= "" then return false end
          -- Disable completion for prompt windows that are not `nvim-dap` prompts
          local dap_prompt = astro.is_available "cmp-dap" -- add interoperability with cmp-dap
            and vim.tbl_contains({ "dap-repl", "dapui_watches", "dapui_hover" }, vim.bo[0].filetype)
          if vim.bo[0].buftype == "prompt" and not dap_prompt then return false end
          -- Disable completion when disabled in AstroNvim
          return vim.F.if_nil(vim.b.cmp_enabled, astro.config.features.cmp)
        end,
        preselect = cmp.PreselectMode.None,
        formatting = { fields = { "kind", "abbr", "menu" }, format = format },
        confirm_opts = {
          behavior = cmp.ConfirmBehavior.Replace,
          select = false,
        },
        window = {
          completion = cmp.config.window.bordered {
            col_offset = -2,
            side_padding = 0,
            border = "rounded",
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
          },
          documentation = cmp.config.window.bordered {
            border = "rounded",
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
          },
        },
        mapping = {
          ["<Up>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Select },
          ["<Down>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Select },
          ["<C-P>"] = cmp.mapping(function()
            if is_visible(cmp) then
              cmp.select_prev_item()
            else
              cmp.complete()
            end
          end),
          ["<C-N>"] = cmp.mapping(function()
            if is_visible(cmp) then
              cmp.select_next_item()
            else
              cmp.complete()
            end
          end),
          ["<C-K>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
          ["<C-J>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
          ["<C-U>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
          ["<C-D>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
          ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
          ["<C-Y>"] = cmp.config.disable,
          ["<C-E>"] = cmp.mapping(cmp.mapping.abort(), { "i", "c" }),
          ["<CR>"] = cmp.mapping(cmp.mapping.confirm { select = false }, { "i", "c" }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if is_visible(cmp) then
              cmp.select_next_item()
            elseif vim.api.nvim_get_mode().mode ~= "c" and vim.snippet and vim.snippet.active { direction = 1 } then
              vim.schedule(function() vim.snippet.jump(1) end)
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if is_visible(cmp) then
              cmp.select_prev_item()
            elseif vim.api.nvim_get_mode().mode ~= "c" and vim.snippet and vim.snippet.active { direction = -1 } then
              vim.schedule(function() vim.snippet.jump(-1) end)
            else
              fallback()
            end
          end, { "i", "s" }),
        },
        sources = sources,
      })
    end,
    config = function(...) require "astronvim.plugins.configs.cmp"(...) end,
  },
  {
    "L3MON4D3/LuaSnip",
    lazy = true,
    build = vim.fn.has "win32" == 0
        and "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build\n'; make install_jsregexp"
      or nil,
    specs = {
      {
        "hrsh7th/nvim-cmp",
        optional = true,
        dependencies = { { "saadparwaiz1/cmp_luasnip", lazy = true } },
        opts = function(_, opts)
          local luasnip, cmp = require "luasnip", require "cmp"

          if not opts.snippet then opts.snippet = {} end
          opts.snippet.expand = function(args) luasnip.lsp_expand(args.body) end

          if not opts.sources then opts.sources = {} end
          table.insert(opts.sources, { name = "luasnip", priority = 750 })

          if not opts.mappings then opts.mappings = {} end
          opts.mapping["<Tab>"] = cmp.mapping(function(fallback)
            if is_visible(cmp) then
              cmp.select_next_item()
            elseif vim.api.nvim_get_mode().mode ~= "c" and luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" })
          opts.mapping["<S-Tab>"] = cmp.mapping(function(fallback)
            if is_visible(cmp) then
              cmp.select_prev_item()
            elseif vim.api.nvim_get_mode().mode ~= "c" and luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" })
        end,
      },
    },
    dependencies = { { "rafamadriz/friendly-snippets", lazy = true } },
    opts = {
      history = true,
      delete_check_events = "TextChanged",
      region_check_events = "CursorMoved",
    },
    config = function(...) require "astronvim.plugins.configs.luasnip"(...) end,
  },
}
