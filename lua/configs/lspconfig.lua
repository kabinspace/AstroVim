local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then return end
vim.g.diagnostics_enabled = true
vim.diagnostic.config(astronvim.lsp.diagnostics[vim.g.diagnostics_enabled and "on" or "off"])
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
vim.tbl_map(astronvim.lsp.setup, astronvim.user_plugin_opts "lsp.servers")
