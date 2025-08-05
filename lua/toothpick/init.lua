require("toothpick.types")

local M = {}

---@param user_config Toothpick.Config
function M.setup(user_config)
  ---@type Toothpick.Config
  local config = {
    select = {
      enable = true,
      prompt = "",
      namespace = "ToothpickSelect",
      keys = {
        accept = { "<CR>" },
        cancel = { "<Esc>", "q" },
      },
      hints = {
        show = true,
        chars = "asdf",
        hl = "MoreMsg",
        separator = " ",
      },
      win_config = {
        relative = "cursor",
        row = 1,
        col = 1,
        width = 5,
        style = "minimal",
        border = "rounded",
        title_pos = "left",
        footer = "",
        footer_pos = "center",
      },
      guicursor = "ToothpickHiddenCursor",
      pipe = {
        filter = nil,
        sort = nil,
        transform = nil,
      },
      format_item = tostring,
    },
    input = {
      enable = true,
      extend_margin = 3,
      extend_width = 10,
      win_config = {
        relative = "cursor",
        row = 1,
        col = 1,
        width = 10,
        height = 1,
        style = "minimal",
        border = "rounded",
        title_pos = "center",
      }
    },
    notify = {
      enable = true,
      levels = {
        ERROR = { duration = 5000, hl = "DiagnosticError" },
        WARN  = { duration = 5000, hl = "DiagnosticWarn" },
        INFO  = { duration = 4000, hl = "DiagnosticInfo" },
        DEBUG = { duration = 3000, hl = "DiagnosticHint" },
        TRACE = { duration = 3000, hl = "DiagnosticOk" },
        OFF   = { duration = 2000, hl = "Comment" },
      },
      max = {
        width = {
          absolute = 60,
          relative = 0.38,
        },
        height = {
          absolute = 20,
          relative = 0.3,
        },
      },
      win_config = {
        noautocmd = true,
        focusable = false,
        zindex = 50,
        title = "",
        style = "minimal",
        border = { "╭", "─", "─", " ", "─", "─", "╰", "│" },
        relative = "editor",
        anchor = "NE",
        col = 99999,
        row = 1,
      },
    },
  }

  if user_config then
    config = vim.tbl_deep_extend("force", config, user_config)
  end

  if config.select.enable then
    vim.ui.select = function(items, opts, on_choice)
      opts = vim.tbl_deep_extend("force", vim.deepcopy(config.select, true), opts or {})
      vim.api.nvim_set_hl(0, opts.guicursor, { reverse = true, blend = 100 })
      require("toothpick.select").select(items, opts, on_choice)
    end
  end

  if config.input.enable then
    vim.ui.input = function(opts, on_confirm)
      opts = vim.tbl_deep_extend("force", vim.deepcopy(config.input, true), opts or {})
      require("toothpick.input").input(opts, on_confirm)
    end
  end

  if config.notify.enable then
    vim.notify = vim.schedule_wrap(
      function(msg, level)
        local notify = require("toothpick.notify")
        notify.opts = config.notify
        notify.notify(msg, level)
      end
    )
  end
end

return M
