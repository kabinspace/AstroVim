return function(_, opts)
  local is_available = require("astrocore").is_available
  if is_available "mason-tool-installer.nvim" then opts.ensure_installed = nil end
  if is_available "astrolsp" then require("astrolsp.mason-lspconfig").register_servers() end
  require("mason-lspconfig").setup(opts)
end
