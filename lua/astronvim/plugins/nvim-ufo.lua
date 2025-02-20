-- TODO: Remove when dropping support for Neovim v0.10
return {
  "kevinhwang91/nvim-ufo",
  event = { "User AstroFile", "InsertEnter" },
  enabled = vim.fn.has "nvim-0.11" ~= 1,
  specs = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        maps.n["zR"] = { function() require("ufo").openAllFolds() end, desc = "Open all folds" }
        maps.n["zM"] = { function() require("ufo").closeAllFolds() end, desc = "Close all folds" }
        maps.n["zr"] = { function() require("ufo").openFoldsExceptKinds() end, desc = "Fold less" }
        maps.n["zm"] = { function() require("ufo").closeFoldsWith() end, desc = "Fold more" }
        maps.n["zp"] = { function() require("ufo").peekFoldedLinesUnderCursor() end, desc = "Peek fold" }

        local opt = opts.options.opt
        opt.foldcolumn = "1"
        opt.foldexpr = "0"
        opt.foldenable = true
        opt.foldlevel = 99
        opt.foldlevelstart = 99
      end,
    },
    {
      "AstroNvim/astrolsp",
      optional = true,
      opts = function(_, opts)
        local astrocore = require "astrocore"
        if astrocore.is_available "nvim-ufo" then
          opts.capabilities = astrocore.extend_tbl(opts.capabilities, {
            textDocument = { foldingRange = { dynamicRegistration = false, lineFoldingOnly = true } },
          })
        end
      end,
    },
  },
  dependencies = { { "kevinhwang91/promise-async", lazy = true } },
  opts = {
    preview = {
      mappings = {
        scrollB = "<C-B>",
        scrollF = "<C-F>",
        scrollU = "<C-U>",
        scrollD = "<C-D>",
      },
    },
    provider_selector = function(_, filetype, buftype)
      local function handleFallbackException(bufnr, err, providerName)
        if type(err) == "string" and err:match "UfoFallbackException" then
          return require("ufo").getFolds(bufnr, providerName)
        else
          return require("promise").reject(err)
        end
      end

      return (filetype == "" or buftype == "nofile") and "indent" -- only use indent until a file is opened
        or function(bufnr)
          return require("ufo")
            .getFolds(bufnr, "lsp")
            :catch(function(err) return handleFallbackException(bufnr, err, "treesitter") end)
            :catch(function(err) return handleFallbackException(bufnr, err, "indent") end)
        end
    end,
  },
}
