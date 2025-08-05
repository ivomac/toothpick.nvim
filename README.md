
## toothpick.nvim

Replace `vim.ui.select`, `vim.ui.input`, and `vim.notify` with floating windows.

### Select

`vim.ui.select` is extended:
- 1-char line hints for quick selection.
- Lines can also be navigated with `j`, `k` and selected with `Enter`.
- Window size limited to number of hint chars. Navigate pages with `h`, `l`.
- Automatic tabular formatting of items is optionally available.
- Convenient pipeline functions `filter`, `sort`, `transform` can be defined.

### Input

Single-line floating window for user input (`vim.ui.input`).
- Normal buffer starting in insert mode. Normal/Visual modes still accessible.
- Used with operations such as LSP renaming.

### Notify

Show `vim.notify` messages briefly in a top-right window.
- Customize duration and highlight per message level.

## Installation

### Lazy

```lua
{
  "ivomac/toothpick.nvim",
  opts = {
    select = {},
    input = {},
    notify = {}
  },
  cmd = { "Notifications" },
}
```

### Default Config

```lua
{
  select = {
    ---@field enable boolean Whether to enable the select module
    enable = true,
    ---@field prompt string Prompt will be used as window title
    prompt = "",
    ---@field namespace string Highlight namespace for vim.api.nvim_create_namespace
    namespace = "ToothpickSelect",
    keys = {
      ---@field accept string[] Keys to accept selection: will call on_choice(item, idx, key)
      accept = { "<CR>" },
      ---@field cancel string[] Keys to cancel selection: will call on_choice(nil, nil, key)
      cancel = { "<Esc>", "q" },
    },
    hints = {
      ---@field show boolean Whether to show hints
      show = true,
      ---@field chars string Letters used for line selection
      chars = "asdf",
      ---@field hl string Hint char highlight group
      hl = "MoreMsg",
      ---@field separator string string between hints and items
      separator = " ",
    },
    ---@field win_config table Window config for vim.api.nvim_open_win
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
    ---@field guicursor string Temporary vim.opt.guicursor used inside window. Set to nil to not hide the cursor
    guicursor = "ToothpickHiddenCursor",
    pipe = {
      ---@field filter nil|fun(a: any): boolean Filter function to preselect items (kept on true)
      filter = nil,
      ---@field sort nil|fun(a: any, b: any): boolean Sort function to sort input table
      sort = nil,
      ---@field transform nil|fun(a: any): any Transform each item to sort input table
      transform = nil,
    },
    ---@field format_item Toothpick.Select.Config.FormatTable|fun(a: any): string Format item function (A table is accepted for table formatting)
    format_item = tostring,
  },
  input = {
    ---@field enable boolean Whether to enable the input module
    enable = true,
    ---@field extend_margin number Margin for extending width
    extend_margin = 3,
    ---@field extend_width number Width to extend by
    extend_width = 10,
    ---@field win_config table Window config for vim.api.nvim_open_win
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
    ---@field enable boolean Whether to enable the notify module
    enable = true,
    ---@field levels Toothpick.Notify.Config.Levels Notification levels configuration with duration and highlight groups
    levels = {
      ---@field duration integer Duration in ms
      ---@field hl string Highlight group for notification message
      ERROR = { duration = 5000, hl = "DiagnosticError" },
      WARN  = { duration = 5000, hl = "DiagnosticWarn" },
      INFO  = { duration = 4000, hl = "DiagnosticInfo" },
      DEBUG = { duration = 3000, hl = "DiagnosticHint" },
      TRACE = { duration = 3000, hl = "DiagnosticOk" },
      OFF   = { duration = 2000, hl = "Comment" },
    },
    ---@field max Toothpick.Notify.Config.Max Maximum size constraints for notification window
    max = {
      ---@field absolute integer Number of columns/lines
      ---@field relative number Number relative to screen size
      width = {
        absolute = 60,
        relative = 0.38,
      },
      height = {
        absolute = 20,
        relative = 0.3,
      },
    },
    ---@field win_config table Window config for vim.api.nvim_open_win
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
```

### Per-Call Config

The `opts` given to `require("toothpick").setup(opts)` will set the default options for the three menus.

`opts.select` and `opts.input` above can be passed to `vim.ui.select` and `vim.ui.input`, which accept an `opts` argument, to use different options per-call.

## Usage Examples

## Similar plugins

### Select

- [ibhagwan/fzf-lua](https://github.com/ibhagwan/fzf-lua)
- [folke/snacks.nvim (picker)](https://github.com/folke/snacks.nvim/blob/main/docs/picker.md)
- [echasnovski/mini.nvim (mini-pick)](https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-pick.md)
- [nvim-telescope/telescope-ui-select.nvim](https://github.com/nvim-telescope/telescope-ui-select.nvim)


#### Buffer Select

- [otavioschwanck/arrow.nvim](https://github.com/otavioschwanck/arrow.nvim)
- [ThePrimeagen/harpoon](https://github.com/ThePrimeagen/harpoon)
- [toppair/reach.nvim](https://github.com/toppair/reach.nvim)
- [jackMort/tide.nvim](https://github.com/jackMort/tide.nvim)
- [EgZvor/vim-ostroga](https://github.com/EgZvor/vim-ostroga)

### Input

- [doums/suit.nvim](https://github.com/doums/suit.nvim)

### Notify

- [rcarriga/nvim-notify](https://github.com/rcarriga/nvim-notify)

