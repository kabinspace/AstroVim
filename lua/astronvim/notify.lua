---AstroNvim Notify Utilities
---
---This module implements a pausable `vim.notify` in order to defer notifications on startup as well as allow for freely pausing and resuming of notifications
---
---Based on notification lazy loading in LazyVim
---https://github.com/LazyVim/LazyVim/blob/a50f92f7550fb6e9f21c0852e6cb190e6fcd50f5/lua/lazyvim/util/init.lua#L90-L125
---
---@class astronvim.notify
local M = {}

---@type table[]
local notifications = {}
local paused = false

--- Check if notifications are paused
---@return boolean # whether or not the notifications are paused
function M.is_paused() return paused end

--- Check now many notifications are pending
---@return table[] # the number of pending notifications
function M.pending() return notifications end

--- Pause notifications
function M.pause() paused = true end

--- Resume paused notifications
function M.resume()
  paused = false
  vim.schedule(function()
    vim.tbl_map(function(notif) vim.notify(vim.F.unpack_len(notif)) end, notifications)
    notifications = {}
  end)
end

--- A pausable `vim.notify` function
---@param message string|string[] Notification message
---@param level string|number Log level. See vim.log.levels
---@param opts notify.Options Notification options
function M.notify(message, level, opts)
  if M.is_paused() then
    local pos = opts and opts.replace
    if type(pos) == "table" and pos.id then pos = pos.id end
    if type(pos) ~= "number" or not notifications[pos] then pos = #notifications + 1 end
    if opts then opts.replace = nil end
    notifications[pos] = vim.F.pack_len(message, level, opts)
    return { id = pos }
  else
    return M._original(message, level, opts)
  end
end

--- Set `vim.notify` to extend it to be pause-able
---@param notify? function|notify the original notification function (defaults to `vim.notify`)
function M.setup(notify)
  if not notify then notify = vim.notify end
  assert(notify ~= M.notify, "vim.notify is already setup")
  M._original, vim.notify = notify, M.notify
end

--- Remove `astronvim.notify` utilities and restore original `vim.notify`
function M.restore()
  M.notify = M._original
  if M.is_paused() then M.resume() end
end

--- Pause notifications for a 500ms delay or until `vim.notify` changes
function M.defer_startup()
  M.pause()

  -- defer initially for 500ms or until `vim.notify` changes
  local timer, checker = vim.uv.new_timer(), vim.uv.new_check()

  local function replay()
    timer:stop()
    checker:stop()
    M.resume()
  end

  -- wait till vim.notify has been replaced
  checker:start(function()
    if vim.notify ~= M.notify then replay() end
  end)
  -- or if it took more than 500ms, then something went wrong
  timer:start(500, 0, replay)
end

return M
