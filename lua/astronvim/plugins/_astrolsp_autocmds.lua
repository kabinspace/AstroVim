local function formatting_enabled(client)
  local formatting_disabled = vim.tbl_get(require("astrolsp").config, "formatting", "disabled")
  return client.supports_method "textDocument/formatting"
    and formatting_disabled ~= true
    and not vim.tbl_contains(formatting_disabled, client.name)
end

return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    commands = {
      Format = {
        cond = formatting_enabled,
        function() vim.lsp.buf.format(require("astrolsp").format_opts) end,
        desc = "Format file with LSP",
      },
    },
    autocmds = {
      lsp_codelens_refresh = {
        cond = "textDocument/codeLens",
        {
          event = { "TextChanged", "InsertLeave", "BufEnter" },
          desc = "Refresh codelens (buffer)",
          callback = function(args)
            if require("astrolsp").config.features.codelens then vim.lsp.codelens.refresh { bufnr = args.buf } end
          end,
        },
      },
      lsp_auto_signature_help = {
        cond = "textDocument/signatureHelp",
        {
          event = "TextChangedI",
          desc = "Automatically show signature help if enabled",
          callback = function(args)
            local signature_help = vim.b[args.buf].signature_help
            if signature_help == nil then signature_help = require("astrolsp").config.features.signature_help end
            if signature_help then
              local trigger = vim.b[args.buf].signature_help_triggerCharacters or {}
              local retrigger = vim.b[args.buf].signature_help_retriggerCharacters or {}
              local pos = vim.api.nvim_win_get_cursor(0)[2]
              local cur_char = vim.api.nvim_get_current_line():sub(pos, pos)
              if
                vim.g.signature_help_triggered and (cur_char:match "%s" or retrigger[cur_char])
                or trigger[cur_char]
              then
                vim.g.signature_help_triggered = true
                vim.lsp.buf.signature_help()
                return
              end
            end
            vim.g.signature_help_triggered = false
          end,
        },
        {
          event = "InsertLeave",
          desc = "Clear automatic signature help internals when leaving insert",
          callback = function() vim.g.signature_help_triggered = false end,
        },
      },
      lsp_auto_format = {
        cond = formatting_enabled,
        {
          event = "BufWritePre",
          desc = "autoformat on save",
          callback = function(_, _, bufnr)
            local astrolsp = require "astrolsp"
            local autoformat = assert(astrolsp.config.formatting.format_on_save)
            local buffer_autoformat = vim.b[bufnr].autoformat
            if buffer_autoformat == nil then buffer_autoformat = autoformat.enabled end
            if buffer_autoformat and ((not autoformat.filter) or autoformat.filter(bufnr)) then
              vim.lsp.buf.format(vim.tbl_deep_extend("force", astrolsp.format_opts, { bufnr = bufnr }))
            end
          end,
        },
      },
    },
  },
}
