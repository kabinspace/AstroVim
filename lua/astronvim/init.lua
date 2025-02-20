local M = {}

M.did_init = false

M.config = require "astronvim.config"

function M.version()
  local astrocore = require "astrocore"
  local plugin = assert(astrocore.get_plugin "AstroNvim")
  local version_ok, version_str = pcall(astrocore.read_file, plugin.dir .. "/version.txt")
  if not version_ok then
    require("astrocore").notify("Unable to calculate version", vim.log.levels.ERROR)
    return
  end

  version_str = "v" .. vim.trim(version_str)

  if not plugin.version then
    version_str = version_str .. "-dev"
    if vim.fn.executable "git" == 1 then
      local git_description = astrocore.cmd({ "git", "-C", plugin.dir, "describe", "--tags" }, false)
      if git_description then
        local nightly_version = git_description and git_description:match ".*(-%d+-g%x+)\n*$"
        if nightly_version then version_str = version_str .. nightly_version end
      end
    end
  end

  return version_str
end

function M.init()
  if vim.fn.has "nvim-0.10" == 0 then
    vim.api.nvim_echo({
      { "AstroNvim requires Neovim >= 0.10.0\n", "ErrorMsg" },
      { "Press any key to exit", "MoreMsg" },
    }, true, {})
    vim.fn.getchar()
    vim.cmd.quit()
  end

  -- HACK: Hot patch for issue in Neovim v0.10.3 where vim.hl is not defined
  -- TODO: remove neodev when dropping 0.9 support
  if vim.fn.has "nvim-0.10.3" == 1 and not vim.hl then vim.hl = vim.highlight end

  if M.did_init then return end
  M.did_init = true

  local notify = require "astronvim.notify"
  notify.setup()
  notify.defer_startup()

  -- force setup during initialization
  local plugin = require("lazy.core.config").spec.plugins.AstroNvim

  local opts = require("lazy.core.plugin").values(plugin, "opts")
  if opts.pin_plugins == nil then opts.pin_plugins = plugin.version ~= nil end

  ---@diagnostic disable-next-line: cast-local-type
  opts = vim.tbl_deep_extend("force", M.config, opts)
  ---@cast opts -nil
  M.config = opts

  if not vim.g.mapleader and M.config.mapleader then vim.g.mapleader = M.config.mapleader end
  if not vim.g.maplocalleader and M.config.maplocalleader then vim.g.maplocalleader = M.config.maplocalleader end
  if M.config.icons_enabled == false then vim.g.icons_enabled = false end
end

function M.setup() end

return M
