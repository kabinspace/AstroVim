return function(_, opts)
  if require("astrocore").is_available "mason-tool-installer.nvim" then opts.ensure_installed = nil end
  require("mason-nvim-dap").setup(opts)
end
