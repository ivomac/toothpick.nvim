
## toothpick.nvim

Replace `vim.ui.select`, `vim.ui.input`, and `vim.notify` with floating windows.

### Select

`vim.ui.select` is extended:
- 1-char line hints for quick selection.
- Lines can also be navigated with `j`, `k` and selected with `Enter`.
- Window size limited to number of hint chars. Navigate pages with `h`, `l`.
- Automatic tabular formatting of items is optionally available.
- Convenient pipeline functions `filter`, `sort`, `transform` can be defined.
- Example of custom buffer picker:

<img width="460" height="162" alt="2025-08-06_17-19-57" src="https://github.com/user-attachments/assets/529bccf1-c3d7-4ea7-80df-985fbc9562b3" />

### Input

Single-line floating window for user input (`vim.ui.input`).
- Normal buffer starting in insert mode. Normal/Visual modes still accessible.
- Used with operations such as LSP renaming:

<img width="460" height="162" alt="2025-08-06_17-20-22" src="https://github.com/user-attachments/assets/8c04caa9-063c-4cc4-9892-f24d85ad0ac8" />

### Notify

Show `vim.notify` messages briefly in a top-right window.
- Customize duration and highlight per message level.

<img width="452" height="162" alt="2025-08-06_17-21-04" src="https://github.com/user-attachments/assets/4a8c5780-3648-438a-8b82-a34926180c1d" />

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

### Last Used Buffer Select

```lua
-- format time in "3h42m10s" format
local function format_time(time)
  local seconds = time % 60
  local minutes = math.floor((time % 3600) / 60)
  local hours = math.floor(time / 3600)
  if hours == 0 and minutes == 0 then
    return string.format("%ds", seconds)
  elseif hours == 0 then
    return string.format("%dm", minutes)
  else
    return string.format("%dh%02d", hours, minutes)
  end
end

local opts = {
  prompt = " LUB ",
  format_item = {
    separator = " ",
    -- columns are keys of items or of transform() output, if transform not nil (this case)
    columns = { "filename", "shortpath", "lastused" },
    justify = { "r", "l", "r" },
    hl = { "Normal", "Comment", "Character" },
  },
  pipe = {
    filter = function(buf)
      -- exclude visible buffers
      return buf.hidden == 1
    end,
    sort = function(buf1, buf2)
      -- sort by lastused timestamp
      return (buf1.lastused or 0) > (buf2.lastused or 0)
    end,
    transform = function(buf)
      local relpath = vim.fn.fnamemodify(buf.name, ":p:~:.")

      return {
        bufnr = buf.bufnr,
        -- get filename as "parent/name"
        filename = string.format(
          "%s/%s",
          vim.fn.fnamemodify(relpath, ":h:t"),
          vim.fn.fnamemodify(relpath, ":t")
        ),
        -- get remainder of path in short form
        shortpath = vim.fn.pathshorten(vim.fn.fnamemodify(relpath, ":h:h"), 3),
        -- get human-readable time since lastused
        lastused = format_time(math.floor(os.time() - buf.lastused))
      }
    end,
  },
  keys = {
    -- we can add extra keys for custom actions
    accept = { "<CR>", "r" },
  }
}

local function on_choice(buf, _, key)
  if not buf then return end

  if key == "r" then
    -- delete buffer
    vim.api.nvim_buf_delete(buf.bufnr, {})

    -- reopen menu
    vim.ui.select(vim.fn.getbufinfo({ buflisted = 1 }), opts, on_choice)
  else
    -- open buffer
    vim.api.nvim_set_current_buf(buf.bufnr)
  end
end

local function last_used_buffer_select()
  vim.ui.select(vim.fn.getbufinfo({ buflisted = 1 }), opts, on_choice)
end


return {
  "ivomac/toothpick.nvim",
  opts = {
    select = {},
    input = {},
    notify = {}
  },
  cmd = { "Notifications" },
  keys = {
    {
      mode = { "n" },
      "<leader>l",
      last_used_buffer_select,
      silent = true,
      noremap = true,
      desc = "List buffers by order of access",
    },
  },
}
```

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

