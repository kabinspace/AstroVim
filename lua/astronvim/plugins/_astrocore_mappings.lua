return {
  "AstroNvim/astrocore",
  ---@param opts AstroCoreOpts
  opts = function(_, opts)
    local astro = require "astrocore"
    local get_icon = require("astroui").get_icon
    -- initialize internally use mapping section titles
    opts._map_sections = {
      f = { desc = get_icon("Search", 1, true) .. "Find" },
      p = { desc = get_icon("Package", 1, true) .. "Packages" },
      l = { desc = get_icon("ActiveLSP", 1, true) .. "Language Tools" },
      u = { desc = get_icon("Window", 1, true) .. "UI/UX" },
      b = { desc = get_icon("Tab", 1, true) .. "Buffers" },
      bs = { desc = get_icon("Sort", 1, true) .. "Sort Buffers" },
      d = { desc = get_icon("Debugger", 1, true) .. "Debugger" },
      g = { desc = get_icon("Git", 1, true) .. "Git" },
      S = { desc = get_icon("Session", 1, true) .. "Session" },
      t = { desc = get_icon("Terminal", 1, true) .. "Terminal" },
      x = { desc = get_icon("List", 1, true) .. "Quickfix/Lists" },
    }

    -- initialize mappings table
    local maps = astro.empty_map_table()
    local sections = assert(opts._map_sections)

    -- Normal --
    -- Standard Operations
    maps.n["j"] = { "v:count == 0 ? 'gj' : 'j'", expr = true, silent = true, desc = "Move cursor down" }
    maps.x["j"] = maps.n["j"]
    maps.n["k"] = { "v:count == 0 ? 'gk' : 'k'", expr = true, silent = true, desc = "Move cursor up" }
    maps.x["k"] = maps.n["k"]
    maps.n["<Leader>w"] = { "<Cmd>w<CR>", desc = "Save" }
    maps.n["<Leader>q"] = { "<Cmd>confirm q<CR>", desc = "Quit Window" }
    maps.n["<Leader>Q"] = { "<Cmd>confirm qall<CR>", desc = "Exit AstroNvim" }
    maps.n["<Leader>n"] = { "<Cmd>enew<CR>", desc = "New File" }
    maps.n["<C-S>"] = { "<Cmd>silent! update! | redraw<CR>", desc = "Force write" }
    maps.x["<C-S>"] = maps.i["<C-s>"]
    maps.n["<C-Q>"] = { "<Cmd>q!<CR>", desc = "Force quit" }
    maps.n["|"] = { "<Cmd>vsplit<CR>", desc = "Vertical Split" }
    maps.n["\\"] = { "<Cmd>split<CR>", desc = "Horizontal Split" }
    maps.n["<Leader>/"] = { "gcc", remap = true, desc = "Toggle comment line" }
    maps.x["<Leader>/"] = { "gc", remap = true, desc = "Toggle comment" }

    maps.n["<Leader>R"] = { function() require("astrocore").rename_file() end, desc = "Rename file" }

    -- Neovim Default LSP Mappings
    if vim.fn.has "nvim-0.11" ~= 1 then
      maps.n["gra"] = { function() vim.lsp.buf.code_action() end, desc = "vim.lsp.buf.code_action()" }
      maps.x["gra"] = { function() vim.lsp.buf.code_action() end, desc = "vim.lsp.buf.code_action()" }
      maps.n["grn"] = { function() vim.lsp.buf.rename() end, desc = "vim.lsp.buf.rename()" }
      maps.n["grr"] = { function() vim.lsp.buf.references() end, desc = "vim.lsp.buf.references()" }
      maps.n["gri"] = { function() vim.lsp.buf.implementation() end, desc = "vim.lsp.buf.implementation()" }
      maps.n["gO"] = { function() vim.lsp.buf.document_symbol() end, desc = "vim.lsp.buf.document_symbol()" }
      maps.i["<C-S>"] = { function() vim.lsp.buf.signature_help() end, desc = "vim.lsp.buf.signature_help()" }
      maps.s["<C-S>"] = { function() vim.lsp.buf.signature_help() end, desc = "vim.lsp.buf.signature_help()" }
    end

    -- Plugin Manager
    maps.n["<Leader>p"] = vim.tbl_get(sections, "p")
    maps.n["<Leader>pi"] = { function() require("lazy").install() end, desc = "Plugins Install" }
    maps.n["<Leader>ps"] = { function() require("lazy").home() end, desc = "Plugins Status" }
    maps.n["<Leader>pS"] = { function() require("lazy").sync() end, desc = "Plugins Sync" }
    maps.n["<Leader>pu"] = { function() require("lazy").check() end, desc = "Plugins Check Updates" }
    maps.n["<Leader>pU"] = { function() require("lazy").update() end, desc = "Plugins Update" }
    maps.n["<Leader>pa"] = { function() require("astrocore").update_packages() end, desc = "Update Lazy and Mason" }

    -- Manage Buffers
    maps.n["<Leader>c"] = { function() require("astrocore.buffer").close() end, desc = "Close buffer" }
    maps.n["<Leader>C"] = { function() require("astrocore.buffer").close(0, true) end, desc = "Force close buffer" }
    maps.n["]b"] = {
      function() require("astrocore.buffer").nav(vim.v.count1) end,
      desc = "Next buffer",
    }
    maps.n["[b"] = {
      function() require("astrocore.buffer").nav(-vim.v.count1) end,
      desc = "Previous buffer",
    }
    maps.n[">b"] = {
      function() require("astrocore.buffer").move(vim.v.count1) end,
      desc = "Move buffer tab right",
    }
    maps.n["<b"] = {
      function() require("astrocore.buffer").move(-vim.v.count1) end,
      desc = "Move buffer tab left",
    }

    maps.n["<Leader>b"] = vim.tbl_get(sections, "b")
    maps.n["<Leader>bc"] =
      { function() require("astrocore.buffer").close_all(true) end, desc = "Close all buffers except current" }
    maps.n["<Leader>bC"] = { function() require("astrocore.buffer").close_all() end, desc = "Close all buffers" }
    maps.n["<Leader>bl"] =
      { function() require("astrocore.buffer").close_left() end, desc = "Close all buffers to the left" }
    maps.n["<Leader>bp"] = { function() require("astrocore.buffer").prev() end, desc = "Previous buffer" }
    maps.n["<Leader>br"] =
      { function() require("astrocore.buffer").close_right() end, desc = "Close all buffers to the right" }
    maps.n["<Leader>bs"] = vim.tbl_get(sections, "bs")
    maps.n["<Leader>bse"] = { function() require("astrocore.buffer").sort "extension" end, desc = "By extension" }
    maps.n["<Leader>bsr"] = { function() require("astrocore.buffer").sort "unique_path" end, desc = "By relative path" }
    maps.n["<Leader>bsp"] = { function() require("astrocore.buffer").sort "full_path" end, desc = "By full path" }
    maps.n["<Leader>bsi"] = { function() require("astrocore.buffer").sort "bufnr" end, desc = "By buffer number" }
    maps.n["<Leader>bsm"] = { function() require("astrocore.buffer").sort "modified" end, desc = "By modification" }

    maps.n["<Leader>l"] = vim.tbl_get(sections, "l")
    maps.n["<Leader>ld"] = { function() vim.diagnostic.open_float() end, desc = "Hover diagnostics" }
    local function diagnostic_goto(dir, severity)
      local go = vim.diagnostic["goto_" .. (dir and "next" or "prev")]
      if type(severity) == "string" then severity = vim.diagnostic.severity[severity] end
      return function() go { severity = severity } end
    end
    -- TODO: Remove mapping after dropping support for Neovim v0.10, it's automatic
    if vim.fn.has "nvim-0.11" == 0 then
      maps.n["[d"] = { diagnostic_goto(false), desc = "Previous diagnostic" }
      maps.n["]d"] = { diagnostic_goto(true), desc = "Next diagnostic" }
    end
    maps.n["[e"] = { diagnostic_goto(false, "ERROR"), desc = "Previous error" }
    maps.n["]e"] = { diagnostic_goto(true, "ERROR"), desc = "Next error" }
    maps.n["[w"] = { diagnostic_goto(false, "WARN"), desc = "Previous warning" }
    maps.n["]w"] = { diagnostic_goto(true, "WARN"), desc = "Next warning" }
    maps.n["gl"] = { function() vim.diagnostic.open_float() end, desc = "Hover diagnostics" }

    -- Navigate tabs
    maps.n["]t"] = { function() vim.cmd.tabnext() end, desc = "Next tab" }
    maps.n["[t"] = { function() vim.cmd.tabprevious() end, desc = "Previous tab" }

    -- Split navigation
    maps.n["<C-H>"] = { "<C-w>h", desc = "Move to left split" }
    maps.n["<C-J>"] = { "<C-w>j", desc = "Move to below split" }
    maps.n["<C-K>"] = { "<C-w>k", desc = "Move to above split" }
    maps.n["<C-L>"] = { "<C-w>l", desc = "Move to right split" }
    maps.n["<C-Up>"] = { "<Cmd>resize -2<CR>", desc = "Resize split up" }
    maps.n["<C-Down>"] = { "<Cmd>resize +2<CR>", desc = "Resize split down" }
    maps.n["<C-Left>"] = { "<Cmd>vertical resize -2<CR>", desc = "Resize split left" }
    maps.n["<C-Right>"] = { "<Cmd>vertical resize +2<CR>", desc = "Resize split right" }

    -- List management
    maps.n["<Leader>x"] = vim.tbl_get(sections, "x")
    maps.n["<Leader>xq"] = { "<Cmd>copen<CR>", desc = "Quickfix List" }
    maps.n["<Leader>xl"] = { "<Cmd>lopen<CR>", desc = "Location List" }
    if vim.fn.has "nvim-0.11" == 0 then
      maps.n["]q"] = { vim.cmd.cnext, desc = "Next quickfix" }
      maps.n["[q"] = { vim.cmd.cprev, desc = "Previous quickfix" }
      maps.n["]Q"] = { vim.cmd.clast, desc = "End quickfix" }
      maps.n["[Q"] = { vim.cmd.cfirst, desc = "Beginning quickfix" }

      maps.n["]l"] = { vim.cmd.lnext, desc = "Next loclist" }
      maps.n["[l"] = { vim.cmd.lprev, desc = "Previous loclist" }
      maps.n["]L"] = { vim.cmd.llast, desc = "End loclist" }
      maps.n["[L"] = { vim.cmd.lfirst, desc = "Beginning loclist" }
    end

    -- Stay in indent mode
    maps.v["<S-Tab>"] = { "<gv", desc = "Unindent line" }
    maps.v["<Tab>"] = { ">gv", desc = "Indent line" }

    -- Improved Terminal Navigation
    local function term_nav(dir)
      return function()
        if vim.api.nvim_win_get_config(0).zindex then
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-" .. dir .. ">", true, false, true), "n", false)
        else
          vim.cmd.wincmd(dir)
        end
      end
    end
    maps.t["<C-H>"] = { term_nav "h", desc = "Terminal left window navigation" }
    maps.t["<C-J>"] = { term_nav "j", desc = "Terminal down window navigation" }
    maps.t["<C-K>"] = { term_nav "k", desc = "Terminal up window navigation" }
    maps.t["<C-L>"] = { term_nav "l", desc = "Terminal right window navigation" }

    maps.n["<Leader>u"] = vim.tbl_get(sections, "u")
    -- Custom menu for modification of the user experience
    maps.n["<Leader>uA"] = { function() require("astrocore.toggles").autochdir() end, desc = "Toggle rooter autochdir" }
    maps.n["<Leader>ub"] = { function() require("astrocore.toggles").background() end, desc = "Toggle background" }
    maps.n["<Leader>ud"] = { function() require("astrocore.toggles").diagnostics() end, desc = "Toggle diagnostics" }
    maps.n["<Leader>ug"] = { function() require("astrocore.toggles").signcolumn() end, desc = "Toggle signcolumn" }
    maps.n["<Leader>u>"] = { function() require("astrocore.toggles").foldcolumn() end, desc = "Toggle foldcolumn" }
    maps.n["<Leader>ui"] = { function() require("astrocore.toggles").indent() end, desc = "Change indent setting" }
    maps.n["<Leader>ul"] = { function() require("astrocore.toggles").statusline() end, desc = "Toggle statusline" }
    maps.n["<Leader>un"] = { function() require("astrocore.toggles").number() end, desc = "Change line numbering" }
    maps.n["<Leader>uN"] =
      { function() require("astrocore.toggles").notifications() end, desc = "Toggle Notifications" }
    maps.n["<Leader>up"] = { function() require("astrocore.toggles").paste() end, desc = "Toggle paste mode" }
    maps.n["<Leader>us"] = { function() require("astrocore.toggles").spell() end, desc = "Toggle spellcheck" }
    maps.n["<Leader>uS"] = { function() require("astrocore.toggles").conceal() end, desc = "Toggle conceal" }
    maps.n["<Leader>ut"] = { function() require("astrocore.toggles").tabline() end, desc = "Toggle tabline" }
    maps.n["<Leader>uu"] = { function() require("astrocore.toggles").url_match() end, desc = "Toggle URL highlight" }
    maps.n["<Leader>uw"] = { function() require("astrocore.toggles").wrap() end, desc = "Toggle wrap" }
    maps.n["<Leader>uy"] =
      { function() require("astrocore.toggles").buffer_syntax() end, desc = "Toggle syntax highlight" }

    opts.mappings = maps
  end,
}
