return {
  "AstroNvim/astrolsp",
  lazy = true,
  ---@type AstroLSPOpts
  opts = {
    features = {
      codelens = true,
      inlay_hints = false,
      semantic_tokens = true,
    },
    capabilities = vim.lsp.protocol.make_client_capabilities(),
    ---@diagnostic disable-next-line: missing-fields
    config = {},
    defaults = {
      hover = {
        border = "rounded",
        silent = true,
      },
      signature_help = {
        border = "rounded",
        silent = true,
        focusable = false,
      },
    },
    file_operations = {
      timeout = 10000,
      operations = {
        didCreate = true,
        didDelete = true,
        didRename = true,
        willCreate = true,
        willDelete = true,
        willRename = true,
      },
    },
    flags = {},
    formatting = { format_on_save = { enabled = true }, disabled = {} },
    handlers = { function(server, server_opts) require("lspconfig")[server].setup(server_opts) end },
    servers = {},
    on_attach = nil,
  },
  specs = {
    {
      "AstroNvim/astrocore",
      ---@type AstroCoreOpts
      opts = {
        autocmds = {
          astrolsp_createfiles_events = {
            {
              event = "BufWritePre",
              desc = "trigger willCreateFiles before writing a new file",
              callback = function(args)
                local filename = require("astrocore.buffer").is_valid(args.buf)
                  and vim.fn.expand("#" .. args.buf .. ":p")
                if filename and not vim.uv.fs_stat(filename) then
                  vim.b[args.buf].new_file = filename
                  require("astrolsp.file_operations").willCreateFiles(filename)
                end
              end,
            },
            {
              event = "BufWritePost",
              desc = "trigger didCreateFiles after writing a new file",
              callback = function(args)
                local filename = vim.b[args.buf].new_file
                if filename then
                  vim.b[args.buf].new_file = false
                  require("astrolsp.file_operations").didCreateFiles(filename)
                end
              end,
            },
          },
        },
      },
    },
    {
      "nvim-neo-tree/neo-tree.nvim",
      optional = true,
      opts = function(_, opts)
        local events = require "neo-tree.events"
        if not opts.event_handlers then opts.event_handlers = {} end
        local move_args = function(args) return { from = args.source, to = args.destination } end
        local operations = {
          willCreateFiles = { events = { events.BEFORE_FILE_ADD } },
          didCreateFiles = { events = { events.FILE_ADDED } },
          willDeleteFiles = { events = { events.BEFORE_FILE_DELETE } },
          didDeleteFiles = { events = { events.FILE_DELETED } },
          willRenameFiles = { events = { events.BEFORE_FILE_MOVE, events.BEFORE_FILE_RENAME }, args = move_args },
          didRenameFiles = { events = { events.FILE_MOVED, events.FILE_RENAMED }, args = move_args },
        }
        for operation, config in pairs(operations) do
          for _, event in ipairs(config.events) do
            table.insert(opts.event_handlers, {
              event = event,
              id = "astrolsp_" .. operation,
              handler = function(args)
                require("astrolsp.file_operations")[operation](config.args and config.args(args) or args)
              end,
            })
          end
        end
      end,
    },
  },
}
