return {
  "astroui",
  opts = function(_, opts)
    local function pattern_match(str, pattern_list)
      for _, pattern in ipairs(pattern_list) do
        if str:find(pattern) then return true end
      end
      return false
    end

    local sign_handlers = {}
    -- gitsigns handlers
    local gitsigns = function(_)
      local gitsigns_avail, gitsigns = pcall(require, "gitsigns")
      if gitsigns_avail then vim.schedule(gitsigns.preview_hunk) end
    end
    for _, sign in ipairs { "Topdelete", "Untracked", "Add", "Changedelete", "Delete" } do
      local name = "GitSigns" .. sign
      if not sign_handlers[name] then sign_handlers[name] = gitsigns end
    end
    -- diagnostic handlers
    local diagnostics = function(args)
      if args.mods:find "c" then
        vim.schedule(vim.lsp.buf.code_action)
      else
        vim.schedule(vim.diagnostic.open_float)
      end
    end
    for _, sign in ipairs { "Error", "Hint", "Info", "Warn" } do
      local name = "DiagnosticSign" .. sign
      if not sign_handlers[name] then sign_handlers[name] = diagnostics end
    end
    -- DAP handlers
    local dap_breakpoint = function(_)
      local dap_avail, dap = pcall(require, "dap")
      if dap_avail then vim.schedule(dap.toggle_breakpoint) end
    end
    for _, sign in ipairs { "", "Rejected", "Condition" } do
      local name = "DapBreakpoint" .. sign
      if not sign_handlers[name] then sign_handlers[name] = dap_breakpoint end
    end

    opts.status = {
      fallback_colors = {
        none = "NONE",
        fg = "#abb2bf",
        bg = "#1e222a",
        dark_bg = "#2c323c",
        blue = "#61afef",
        green = "#98c379",
        grey = "#5c6370",
        bright_grey = "#777d86",
        dark_grey = "#5c5c5c",
        orange = "#ff9640",
        purple = "#c678dd",
        bright_purple = "#a9a1e1",
        red = "#e06c75",
        bright_red = "#ec5f67",
        white = "#c9c9c9",
        yellow = "#e5c07b",
        bright_yellow = "#ebae34",
      },
      modes = {
        ["n"] = { "NORMAL", "normal" },
        ["no"] = { "OP", "normal" },
        ["nov"] = { "OP", "normal" },
        ["noV"] = { "OP", "normal" },
        ["no"] = { "OP", "normal" },
        ["niI"] = { "NORMAL", "normal" },
        ["niR"] = { "NORMAL", "normal" },
        ["niV"] = { "NORMAL", "normal" },
        ["i"] = { "INSERT", "insert" },
        ["ic"] = { "INSERT", "insert" },
        ["ix"] = { "INSERT", "insert" },
        ["t"] = { "TERM", "terminal" },
        ["nt"] = { "TERM", "terminal" },
        ["v"] = { "VISUAL", "visual" },
        ["vs"] = { "VISUAL", "visual" },
        ["V"] = { "LINES", "visual" },
        ["Vs"] = { "LINES", "visual" },
        [""] = { "BLOCK", "visual" },
        ["s"] = { "BLOCK", "visual" },
        ["R"] = { "REPLACE", "replace" },
        ["Rc"] = { "REPLACE", "replace" },
        ["Rx"] = { "REPLACE", "replace" },
        ["Rv"] = { "V-REPLACE", "replace" },
        ["s"] = { "SELECT", "visual" },
        ["S"] = { "SELECT", "visual" },
        [""] = { "BLOCK", "visual" },
        ["c"] = { "COMMAND", "command" },
        ["cv"] = { "COMMAND", "command" },
        ["ce"] = { "COMMAND", "command" },
        ["r"] = { "PROMPT", "inactive" },
        ["rm"] = { "MORE", "inactive" },
        ["r?"] = { "CONFIRM", "inactive" },
        ["!"] = { "SHELL", "inactive" },
        ["null"] = { "null", "inactive" },
      },
      separators = {
        none = { "", "" },
        left = { "", "  " },
        right = { "  ", "" },
        center = { "  ", "  " },
        tab = { "", " " },
        breadcrumbs = "  ",
        path = "  ",
      },
      attributes = {
        buffer_active = { bold = true, italic = true },
        buffer_picker = { bold = true },
        macro_recording = { bold = true },
        git_branch = { bold = true },
        git_diff = { bold = true },
      },
      icon_highlights = {
        file_icon = {
          tabline = function(self) return self.is_active or self.is_visible end,
          statusline = true,
        },
      },
      buf_matchers = {
        filetype = function(pattern_list, bufnr) return pattern_match(vim.bo[bufnr or 0].filetype, pattern_list) end,
        buftype = function(pattern_list, bufnr) return pattern_match(vim.bo[bufnr or 0].buftype, pattern_list) end,
        bufname = function(pattern_list, bufnr)
          return pattern_match(vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr or 0), ":t"), pattern_list)
        end,
      },
      sign_handlers = sign_handlers,
      setup_colors = function()
        local C = require("astroui").config.status.fallback_colors
        local get_hlgroup = require("astrocore.utils").get_hlgroup
        local lualine_mode = require("astroui.status.hl").lualine_mode
        local function resolve_lualine(orig, ...) return (not orig or orig == "NONE") and lualine_mode(...) or orig end

        local Normal = get_hlgroup("Normal", { fg = C.fg, bg = C.bg })
        local Comment = get_hlgroup("Comment", { fg = C.bright_grey, bg = C.bg })
        local Error = get_hlgroup("Error", { fg = C.red, bg = C.bg })
        local StatusLine = get_hlgroup("StatusLine", { fg = C.fg, bg = C.dark_bg })
        local TabLine = get_hlgroup("TabLine", { fg = C.grey, bg = C.none })
        local TabLineFill = get_hlgroup("TabLineFill", { fg = C.fg, bg = C.dark_bg })
        local TabLineSel = get_hlgroup("TabLineSel", { fg = C.fg, bg = C.none })
        local WinBar = get_hlgroup("WinBar", { fg = C.bright_grey, bg = C.bg })
        local WinBarNC = get_hlgroup("WinBarNC", { fg = C.grey, bg = C.bg })
        local Conditional = get_hlgroup("Conditional", { fg = C.bright_purple, bg = C.dark_bg })
        local String = get_hlgroup("String", { fg = C.green, bg = C.dark_bg })
        local TypeDef = get_hlgroup("TypeDef", { fg = C.yellow, bg = C.dark_bg })
        local GitSignsAdd = get_hlgroup("GitSignsAdd", { fg = C.green, bg = C.dark_bg })
        local GitSignsChange = get_hlgroup("GitSignsChange", { fg = C.orange, bg = C.dark_bg })
        local GitSignsDelete = get_hlgroup("GitSignsDelete", { fg = C.bright_red, bg = C.dark_bg })
        local DiagnosticError = get_hlgroup("DiagnosticError", { fg = C.bright_red, bg = C.dark_bg })
        local DiagnosticWarn = get_hlgroup("DiagnosticWarn", { fg = C.orange, bg = C.dark_bg })
        local DiagnosticInfo = get_hlgroup("DiagnosticInfo", { fg = C.white, bg = C.dark_bg })
        local DiagnosticHint = get_hlgroup("DiagnosticHint", { fg = C.bright_yellow, bg = C.dark_bg })
        local HeirlineInactive =
          resolve_lualine(get_hlgroup("HeirlineInactive", { bg = nil }).bg, "inactive", C.dark_grey)
        local HeirlineNormal = resolve_lualine(get_hlgroup("HeirlineNormal", { bg = nil }).bg, "normal", C.blue)
        local HeirlineInsert = resolve_lualine(get_hlgroup("HeirlineInsert", { bg = nil }).bg, "insert", C.green)
        local HeirlineVisual = resolve_lualine(get_hlgroup("HeirlineVisual", { bg = nil }).bg, "visual", C.purple)
        local HeirlineReplace =
          resolve_lualine(get_hlgroup("HeirlineReplace", { bg = nil }).bg, "replace", C.bright_red)
        local HeirlineCommand =
          resolve_lualine(get_hlgroup("HeirlineCommand", { bg = nil }).bg, "command", C.bright_yellow)
        local HeirlineTerminal =
          resolve_lualine(get_hlgroup("HeirlineTerminal", { bg = nil }).bg, "insert", HeirlineInsert)

        return {
          close_fg = Error.fg,
          fg = StatusLine.fg,
          bg = StatusLine.bg,
          section_fg = StatusLine.fg,
          section_bg = StatusLine.bg,
          git_branch_fg = Conditional.fg,
          mode_fg = StatusLine.bg,
          treesitter_fg = String.fg,
          scrollbar = TypeDef.fg,
          git_added = GitSignsAdd.fg,
          git_changed = GitSignsChange.fg,
          git_removed = GitSignsDelete.fg,
          diag_ERROR = DiagnosticError.fg,
          diag_WARN = DiagnosticWarn.fg,
          diag_INFO = DiagnosticInfo.fg,
          diag_HINT = DiagnosticHint.fg,
          winbar_fg = WinBar.fg,
          winbar_bg = WinBar.bg,
          winbarnc_fg = WinBarNC.fg,
          winbarnc_bg = WinBarNC.bg,
          tabline_bg = TabLineFill.bg,
          tabline_fg = TabLineFill.bg,
          buffer_fg = Comment.fg,
          buffer_path_fg = WinBarNC.fg,
          buffer_close_fg = Comment.fg,
          buffer_bg = TabLineFill.bg,
          buffer_active_fg = Normal.fg,
          buffer_active_path_fg = WinBarNC.fg,
          buffer_active_close_fg = Error.fg,
          buffer_active_bg = Normal.bg,
          buffer_visible_fg = Normal.fg,
          buffer_visible_path_fg = WinBarNC.fg,
          buffer_visible_close_fg = Error.fg,
          buffer_visible_bg = Normal.bg,
          buffer_overflow_fg = Comment.fg,
          buffer_overflow_bg = TabLineFill.bg,
          buffer_picker_fg = Error.fg,
          tab_close_fg = Error.fg,
          tab_close_bg = TabLineFill.bg,
          tab_fg = TabLine.fg,
          tab_bg = TabLine.bg,
          tab_active_fg = TabLineSel.fg,
          tab_active_bg = TabLineSel.bg,
          inactive = HeirlineInactive,
          normal = HeirlineNormal,
          insert = HeirlineInsert,
          visual = HeirlineVisual,
          replace = HeirlineReplace,
          command = HeirlineCommand,
          terminal = HeirlineTerminal,
        }
      end,
    }
  end,
}
