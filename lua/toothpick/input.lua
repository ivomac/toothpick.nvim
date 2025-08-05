require("toothpick.types")

---@type Toothpick.Input
local M = {block = false}

function M.input(opts, on_confirm)
  if M.block then
    return nil, nil
  end
  M.block = true

  opts.win_config.title = opts.win_config.title or opts.prompt or ""

  -- Create buffer

  local buf = vim.api.nvim_create_buf(false, true)

  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "ui-input"

  -- Set initial width and text content

  opts.win_config.width = math.max(opts.win_config.width, #opts.win_config.title + 2)
  if opts.default then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { opts.default })
    opts.win_config.width = math.max(opts.win_config.width, #opts.default + opts.extend_width)
  end

  -- Create float window

  local win = vim.api.nvim_open_win(buf, true, opts.win_config)

  vim.wo[win].foldenable = false
  vim.wo[win].wrap = false
  vim.wo[win].cursorline = false
  vim.wo[win].sidescrolloff = 0

  -- Start in insert mode

  vim.cmd("startinsert!")

  -- Mappings

  local function get_input()
    return vim.api.nvim_buf_get_lines(buf, 0, 1, true)[1]
  end

  local function accept(content)
    vim.api.nvim_win_close(win, true)
    vim.cmd("stopinsert")
    on_confirm(content)
  end

  local map_opts = { nowait = true, buffer = buf }

  -- Exit with Esc on normal, Accept on Enter

  vim.keymap.set("n", "<Esc>", function() accept(nil) end, map_opts)
  vim.keymap.set({ "n", "i" }, "<CR>", function() accept(get_input()) end, map_opts)

  -- Autocmds

  local augroup = vim.api.nvim_create_augroup("UIInput", { clear = true })

  -- Autocmd to extend width as we type if needed

  vim.api.nvim_create_autocmd({ "InsertCharPre" },
    {
      group = augroup,
      buffer = buf,
      callback = function()
        local line = get_input()
        if #line + opts.extend_margin > opts.win_config.width then
          opts.win_config.width = #line + opts.extend_width
          vim.api.nvim_win_set_config(win, { width = opts.win_config.width })
        end
      end
    }
  )

  -- Autocmd to remove block on exit

  vim.api.nvim_create_autocmd({ "WinClosed", "BufDelete" },
    {
      group = augroup,
      buffer = buf,
      once = true,
      callback = function()
        M.block = false
      end
    }
  )

  return win, buf
end

return M
