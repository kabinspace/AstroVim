return function(_, opts)
  local mason_tool_installer = require "mason-tool-installer"
  mason_tool_installer.setup(opts)
  if opts.run_on_start ~= false then mason_tool_installer.run_on_start() end
end
