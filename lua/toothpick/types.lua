---@meta

---@class Toothpick.Select.Config.Hints
---@field show boolean Whether to show hints
---@field chars string Letters used for line selection
---@field hl string Hint char highlight group
---@field separator string string between hints and items

---@class Toothpick.Select.Config.Keys
---@field accept string[] Keys to accept selection: will call on_choice(item, idx, key)
---@field cancel string[] Keys to cancel selection: will call on_choice(nil, nil, key)

---@class Toothpick.Select.Config.Pipe
---@field filter nil|fun(a: any): boolean Filter function to preselect items (kept on true)
---@field sort nil|fun(a: any, b: any): boolean Sort function to sort input table
---@field transform nil|fun(a: any): any Transform each item to sort input table

---@alias key string|integer
---@alias justify_char "l"|"r"|"c"

---@class Toothpick.Select.Config.FormatTable
---@field separator string string used to separate columns
---@field columns key[] keys of input to use as columns
---@field justify justify_char[] justification per column: "l", "r", "c"
---@field hl string[] highlight groups per column

---@class Toothpick.Select.Config
---@field enable boolean Whether to enable the select module
---@field prompt string Prompt will be used as window title
---@field namespace string Highlight namespace for vim.api.nvim_create_namespace
---@field hints Toothpick.Select.Config.Hints Hints configuration
---@field win_config table Window config for vim.api.nvim_open_win
---@field guicursor string Temporary vim.opt.guicursor used inside window. Set to nil to not hide the cursor
---@field pipe Toothpick.Select.Config.Pipe
---@field format_item Toothpick.Select.Config.FormatTable|fun(a: any): string Format item function (A table is accepted for table formatting)
---@field keys Toothpick.Select.Config.Keys Keys to bind

---@class Toothpick.Select
---@field block boolean Whether selection is currently blocked
---@field select? fun(items: any[], config: Toothpick.Select.Config, on_choice: fun(item: any|nil, idx: integer|nil, key: string)): integer|nil, integer[]|nil

---@class Toothpick.Input.Config
---@field enable boolean Whether to enable the input module
---@field prompt? string Text of the prompt
---@field default? string Default reply to the input
---@field extend_margin? number Margin for extending width
---@field extend_width? number Width to extend by
---@field win_config? table Window config for vim.api.nvim_open_win

---@class Toothpick.Input
---@field block boolean Whether input is currently blocked
---@field input? fun(opts: Toothpick.Input.Config, on_confirm: fun(input: string|nil)): integer|nil, integer|nil

---@class Toothpick.Notify.Config.Max.Dim
---@field absolute integer Number of columns/lines
---@field relative number Number relative to screen size

---@class Toothpick.Notify.Config.Max
---@field width Toothpick.Notify.Config.Max.Dim
---@field height Toothpick.Notify.Config.Max.Dim

---@class Toothpick.Notify.Config.Level
---@field duration integer Duration in ms
---@field hl string Highlight group for notification message

---@class Toothpick.Notify.Config.Levels
---@field ERROR Toothpick.Notify.Config.Level
---@field WARN Toothpick.Notify.Config.Level
---@field INFO Toothpick.Notify.Config.Level
---@field DEBUG Toothpick.Notify.Config.Level
---@field TRACE Toothpick.Notify.Config.Level
---@field OFF Toothpick.Notify.Config.Level

---@class Toothpick.Notify.Config Input UI config
---@field enable boolean Whether to enable the notify module
---@field levels Toothpick.Notify.Config.Levels Notification levels configuration with duration and highlight groups
---@field max Toothpick.Notify.Config.Max Maximum size constraints for notifications
---@field win_config? table Window config for vim.api.nvim_open_win

---@class Toothpick.Config
---@field select Toothpick.Select.Config Select UI config
---@field input Toothpick.Input.Config Input UI config
---@field notify Toothpick.Notify.Config Notify UI config

return {}
