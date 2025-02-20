return {
  "AstroNvim/astrolsp",
  ---@param opts AstroLSPOpts
  opts = function(_, opts)
    ---@type AstroLSPMappings
    local maps = require("astrocore").empty_map_table()
    maps.n["<Leader>l"] = { desc = require("astroui").get_icon("ActiveLSP", 1, true) .. "Language Tools" }
    maps.v["<Leader>l"] = { desc = require("astroui").get_icon("ActiveLSP", 1, true) .. "Language Tools" }

    maps.n["<Leader>la"] =
      { function() vim.lsp.buf.code_action() end, desc = "LSP code action", cond = "textDocument/codeAction" }
    maps.x["<Leader>la"] =
      { function() vim.lsp.buf.code_action() end, desc = "LSP code action", cond = "textDocument/codeAction" }
    maps.n["<Leader>lA"] = {
      function() vim.lsp.buf.code_action { context = { only = { "source" }, diagnostics = {} } } end,
      desc = "LSP source action",
      cond = "textDocument/codeAction",
    }

    maps.n["<Leader>ll"] =
      { function() vim.lsp.codelens.refresh() end, desc = "LSP CodeLens refresh", cond = "textDocument/codeLens" }
    maps.n["<Leader>lL"] =
      { function() vim.lsp.codelens.run() end, desc = "LSP CodeLens run", cond = "textDocument/codeLens" }
    maps.n["<Leader>uL"] = {
      function() require("astrolsp.toggles").codelens() end,
      desc = "Toggle CodeLens",
      cond = "textDocument/codeLens",
    }

    maps.n["gD"] = {
      function() vim.lsp.buf.declaration() end,
      desc = "Declaration of current symbol",
      cond = "textDocument/declaration",
    }
    maps.n["gd"] = {
      function() vim.lsp.buf.definition() end,
      desc = "Show the definition of current symbol",
      cond = "textDocument/definition",
    }

    local function formatting_checker(method)
      method = "textDocument/" .. (method or "formatting")
      return function(client)
        local disabled = opts.formatting.disabled
        return client.supports_method(method) and disabled ~= true and not vim.tbl_contains(disabled, client.name)
      end
    end
    local formatting_enabled = formatting_checker()
    maps.n["<Leader>lf"] = {
      function() vim.lsp.buf.format(require("astrolsp").format_opts) end,
      desc = "Format buffer",
      cond = formatting_enabled,
    }
    maps.v["<Leader>lf"] = {
      function() vim.lsp.buf.format(require("astrolsp").format_opts) end,
      desc = "Format buffer",
      cond = formatting_checker "rangeFormatting",
    }
    maps.n["<Leader>uf"] = {
      function() require("astrolsp.toggles").buffer_autoformat() end,
      desc = "Toggle autoformatting (buffer)",
      cond = formatting_enabled,
    }
    maps.n["<Leader>uF"] = {
      function() require("astrolsp.toggles").autoformat() end,
      desc = "Toggle autoformatting (global)",
      cond = formatting_enabled,
    }

    maps.n["<Leader>u?"] = {
      function() require("astrolsp.toggles").signature_help() end,
      desc = "Toggle automatic signature help",
      cond = "textDocument/signatureHelp",
    }

    maps.n["<Leader>uh"] = {
      function() require("astrolsp.toggles").buffer_inlay_hints() end,
      desc = "Toggle LSP inlay hints (buffer)",
      cond = vim.lsp.inlay_hint and "textDocument/inlayHint" or false,
    }
    maps.n["<Leader>uH"] = {
      function() require("astrolsp.toggles").inlay_hints() end,
      desc = "Toggle LSP inlay hints (global)",
      cond = vim.lsp.inlay_hint and "textDocument/inlayHint" or false,
    }

    maps.n["<Leader>lR"] =
      { function() vim.lsp.buf.references() end, desc = "Search references", cond = "textDocument/references" }

    maps.n["<Leader>lr"] =
      { function() vim.lsp.buf.rename() end, desc = "Rename current symbol", cond = "textDocument/rename" }

    maps.n["<Leader>lh"] =
      { function() vim.lsp.buf.signature_help() end, desc = "Signature help", cond = "textDocument/signatureHelp" }
    maps.n["gK"] =
      { function() vim.lsp.buf.signature_help() end, desc = "Signature help", cond = "textDocument/signatureHelp" }

    maps.n["gy"] = {
      function() vim.lsp.buf.type_definition() end,
      desc = "Definition of current type",
      cond = "textDocument/typeDefinition",
    }

    maps.n["<Leader>lG"] =
      { function() vim.lsp.buf.workspace_symbol() end, desc = "Search workspace symbols", cond = "workspace/symbol" }

    maps.n["<Leader>uY"] = {
      function() require("astrolsp.toggles").buffer_semantic_tokens() end,
      desc = "Toggle LSP semantic highlight (buffer)",
      cond = function(client)
        return client.supports_method "textDocument/semanticTokens/full" and vim.lsp.semantic_tokens
      end,
    }
    opts.mappings = require("astrocore").extend_tbl(opts.mappings, maps)
  end,
}
