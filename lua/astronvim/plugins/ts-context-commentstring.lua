return {
  "JoosepAlviste/nvim-ts-context-commentstring",
  lazy = true,
  init = function()
    -- HACK: add workaround for native comments: https://github.com/JoosepAlviste/nvim-ts-context-commentstring/issues/109
    vim.schedule(function()
      local get_option = vim.filetype.get_option
      local context_commentstring
      vim.filetype.get_option = function(filetype, option)
        if option ~= "commentstring" then return get_option(filetype, option) end
        if context_commentstring == nil then
          local ts_context_avail, ts_context = pcall(require, "ts_context_commentstring.internal")
          context_commentstring = ts_context_avail and ts_context
        end
        return context_commentstring and context_commentstring.calculate_commentstring() or get_option(filetype, option)
      end
    end)
  end,
  opts = { enable_autocmd = false },
}
