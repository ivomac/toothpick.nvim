local M = { queue = {}, log = {}, next = 1 }

function M.refresh_now()
  local width = M.opts.win_config.title and #M.opts.win_config.title or 1
  local height = 0

  local max_width = math.min(
    M.opts.max.width.absolute,
    math.ceil(M.opts.max.width.relative * (vim.o.columns - 2))
  )
  local max_height = math.min(
    M.opts.max.height.absolute,
    math.ceil(M.opts.max.height.relative * (vim.o.lines - vim.o.cmdheight - 4))
  )

  local buflines, highlights = {}, {}
  for _, notification in pairs(M.queue) do
    for _, line in ipairs(notification.lines) do
      table.insert(buflines, line)

      height = height + math.ceil((#line + 1) / max_width)
      width = math.max(width, #line)
    end

    table.insert(
      highlights,
      {
        group = notification.hl,
        start = #buflines - #notification.lines,
        finish = #buflines,
      }
    )
  end

  if #buflines == 0 then
    if M.win and vim.api.nvim_win_is_valid(M.win) then
      vim.api.nvim_win_close(M.win, true)
    end
    M.refresh_scheduled = false
    return
  end

  -- Window
  local win_config = M.opts.win_config
  win_config.width = math.min(width, max_width)
  win_config.height = math.min(height, max_height)

  if M.win and vim.api.nvim_win_is_valid(M.win) then
    vim.api.nvim_win_set_config(M.win,
      {
        width = win_config.width,
        height = win_config.height,
      }
    )
  else
    M.buf = vim.api.nvim_create_buf(false, true)
    vim.bo[M.buf].buftype = "nofile"
    vim.bo[M.buf].bufhidden = "wipe"
    vim.bo[M.buf].swapfile = false
    vim.bo[M.buf].filetype = "ui-notify"

    M.win = vim.api.nvim_open_win(M.buf, false, win_config)
    vim.wo[M.win].foldenable = false
    vim.wo[M.win].foldmethod = "manual"
    vim.wo[M.win].wrap = true
    vim.wo[M.win].linebreak = false
  end

  vim.api.nvim_buf_set_lines(M.buf, 0, -1, true, {})
  vim.api.nvim_buf_set_lines(M.buf, 0, -1, true, buflines)

  -- Highlights
  local ns = vim.api.nvim_create_namespace("NOTIFY_HL")
  vim.api.nvim_buf_clear_namespace(M.buf, ns, 0, -1)
  for _, hl in ipairs(highlights) do
    vim.hl.range(M.buf, ns, hl.group, { hl.start, 0 }, { hl.finish, -1 })
  end

  vim.cmd("redraw")

  M.refresh_scheduled = false
end

function M.refresh()
  if not M.refresh_scheduled then
    M.refresh_scheduled = true
    vim.schedule(M.refresh_now)
  end
end

vim.api.nvim_create_user_command("Notifications",
  function(_)
    for k, notification in pairs(M.log) do
      vim.print(k .. ":")
      for _, line in ipairs(notification.lines) do
        vim.print(line)
      end
    end
  end, { force = true }
)

local itol = {}
for k, v in pairs(vim.log.levels) do
  itol[v] = k
end

function M.notify(msg, lvl)
  lvl = lvl or vim.log.levels.INFO

  local lvl_opts = M.opts.levels[itol[lvl]] or M.opts.levels.INFO

  if lvl_opts.duration <= 0 then
    return
  end

  local notification = {
    lines = vim.split(msg, "\n", { trimempty = true }),
    hl = lvl_opts.hl or "Normal",
  }

  local key = M.next
  M.log[key] = notification
  M.queue[key] = notification
  M.next = M.next + 1
  M.refresh()

  vim.defer_fn(
    function()
      M.queue[key] = nil
      M.refresh()
    end,
    lvl_opts.duration + 10
  )
end

return M
