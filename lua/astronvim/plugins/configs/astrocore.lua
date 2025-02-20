return function(_, opts)
  local astrocore = require "astrocore"
  astrocore.setup(opts)

  ---HACK: consider moving `colorscheme` setting to AstroCore to fix dependency cycle
  local colorscheme = require("astroui").config.colorscheme
  if colorscheme and not pcall(vim.cmd.colorscheme, colorscheme) then
    astrocore.notify(("Error setting up colorscheme: `%s`"):format(colorscheme), vim.log.levels.ERROR)
  end
end
