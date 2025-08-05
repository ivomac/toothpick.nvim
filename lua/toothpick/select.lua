require("toothpick.types")


---@type Toothpick.Select
local M = { block = false }


local function justify(str, len, dir)
  local padsize = len - #str
  if dir == "l" then
    return str .. string.rep(" ", padsize)
  elseif dir == "r" then
    return string.rep(" ", padsize) .. str
  elseif dir == "c" then
    local lpadsize = math.floor(padsize / 2)
    local rpadsize = math.ceil(padsize / 2)
    return string.rep(" ", lpadsize) .. str .. string.rep(" ", rpadsize)
  end
end

function M.select(items, config, on_choice)
  if M.block then return nil, nil end
  M.block = true

  if #items == 0 then
    vim.print("No items to choose from.")
    M.block = false
    return nil, nil
  end

  -- Filter items
  local fitems = {}
  if config.pipe.filter then
    for _, item in ipairs(items) do
      if config.pipe.filter(item) then
        table.insert(fitems, item)
      end
    end
  else
    fitems = items
  end

  if #fitems == 0 then
    vim.print("No items to choose from after filter.")
    M.block = false
    return nil, nil
  end

  -- Sort items
  if config.pipe.sort then
    table.sort(fitems, config.pipe.sort)
  end

  -- Transform items
  items = {}
  if config.pipe.transform then
    for _, buf in ipairs(fitems) do
      table.insert(items, config.pipe.transform(buf))
    end
  else
    items = fitems
  end

  -- get the hint character for line number
  local function get_item_hint(nline)
    return config.hints.chars:sub(nline, nline)
  end

  local function get_item_prefix(nitem)
    return string.format("%s%s", get_item_hint(((nitem - 1) % #config.hints.chars) + 1), config.hints.separator)
  end

  local hlranges = {}

  -- Add highlight ranges for the prompt
  local start_col = 0
  if config.hints.show then
    table.insert(hlranges, { group = config.hints.hl, start = 0, stop = 1 })
    start_col = 1 + #config.hints.separator
  end

  local format
  if type(config.format_item) == "table" then
    -- calculate column sizes
    local colsizes = {}
    for _, item in ipairs(items) do
      for _, col in ipairs(config.format_item.columns) do
        colsizes[col] = math.max(colsizes[col] or 0, #tostring(item[col]))
      end
    end

    -- add highlight ranges for each column
    for g, hl_group in ipairs(config.format_item.hl) do
      local stop_col = start_col + colsizes[config.format_item.columns[g]]
      table.insert(hlranges, { group = hl_group, start = start_col, stop = stop_col })
      start_col = stop_col + #config.format_item.separator
    end

    -- create formatting function
    format = function(item)
      local justified_lines = {}
      for ncol, col in ipairs(config.format_item.columns) do
        table.insert(justified_lines,
          justify(tostring(item[col]), colsizes[col], config.format_item.justify[ncol]))
      end
      local cols = table.concat(justified_lines, config.format_item.separator)
      return cols
    end
  else
    format = config.format_item
  end

  -- Lists of items
  -- Items are separated in pages of size equal to #opts.hints.chars
  local lists = {}
  local cur_list = {}
  local max_linewidth = 0

  for i, item in ipairs(items) do
    -- Start new list if current is full
    if #cur_list >= #config.hints.chars then
      table.insert(lists, cur_list)
      cur_list = {}
    end


    local line = format(item)
    if config.hints.show then
      line = string.format("%s%s", get_item_prefix(i), line)
    end

    table.insert(cur_list, line)

    max_linewidth = math.max(#line, max_linewidth)
  end
  table.insert(lists, cur_list)

  -- Create buffers
  local bufs = {}
  local hl_ns = vim.api.nvim_create_namespace(config.namespace)

  for _, list in ipairs(lists) do
    local buf = vim.api.nvim_create_buf(false, true)
    table.insert(bufs, buf)

    -- Buffer content
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, list)

    -- Buffer options
    vim.bo[buf].bufhidden = "hide"
    vim.bo[buf].modifiable = false
    vim.bo[buf].filetype = "ui-select"

    -- Add highlights
    for nline = 1, #list do
      for _, hl in ipairs(hlranges) do
        vim.hl.range(buf, hl_ns, hl.group, { nline - 1, hl.start }, { nline - 1, hl.stop })
      end
    end
  end

  -- Create float window
  local wconfig = config.win_config
  wconfig.title = wconfig.title or config.prompt or ""
  wconfig.height = math.min(#items, #config.hints.chars)
  wconfig.width = math.max(max_linewidth, #wconfig.title)

  if #lists > 1 then
    wconfig.footer = "1/" .. #lists
  end

  local win = vim.api.nvim_open_win(bufs[1], true, wconfig)

  -- Load user highlight namespace
  vim.api.nvim_win_set_hl_ns(win, hl_ns)

  -- Window options
  vim.wo[win].foldenable = false
  vim.wo[win].wrap = false
  vim.wo[win].cursorline = true
  vim.wo[win].sidescrolloff = 0

  -- Hide the cursor by setting guicursor
  -- Guicursor can't be set locally
  -- Set globally and restore on exit
  local saved_guicursor = vim.opt.guicursor
  if config.guicursor then
    vim.opt.guicursor = "n:" .. config.guicursor
  end

  -- Exit and select function
  local function select(nitem, key)
    -- Close window
    vim.api.nvim_win_close(win, true)
    for _, buffer in ipairs(bufs) do
      vim.api.nvim_buf_delete(buffer, { force = true })
    end

    -- Trigger on_choice
    if nitem then
      on_choice(items[nitem], nitem, key)
    else
      on_choice(nil, nil, key)
    end
  end

  -- Keymaps
  for nbuf, buf in ipairs(bufs) do
    local map_opts = { nowait = true, buffer = buf }

    -- Cancel
    for _, key in ipairs(config.keys.cancel) do
      vim.keymap.set("n", key, function() select(nil, key) end, map_opts)
    end

    -- Accept
    for _, key in ipairs(config.keys.accept) do
      vim.keymap.set("n", key,
        function()
          select(vim.api.nvim_win_get_cursor(win)[1] + (nbuf - 1) * wconfig.height, key)
        end,
        map_opts
      )
    end

    -- Line hint keymaps
    for nline = 1, #lists[nbuf] do
      local key = get_item_hint(nline)
      local nitem = nline + (nbuf - 1) * wconfig.height
      vim.keymap.set("n", key, function() select(nitem, key) end, map_opts)
    end

    -- Page change keymaps
    for _, target in ipairs({ { char = "h", idx = nbuf - 1 }, { char = "l", idx = nbuf + 1 } }) do
      if bufs[target.idx] then
        vim.keymap.set("n", target.char,
          function()
            vim.api.nvim_win_set_buf(win, bufs[target.idx])
            if #lists > 1 then
              vim.api.nvim_win_set_config(win, { footer = target.idx .. "/" .. #lists })
              vim.wo[win].cursorline = true
            end
          end,
          map_opts
        )
      end
    end

    -- Autocmds
    vim.api.nvim_create_autocmd("WinLeave", {
      callback = function()
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, true)
          vim.opt.guicursor = saved_guicursor
          M.block = false
        end
      end,
      buffer = buf,
      once = true,
    })

    vim.api.nvim_create_autocmd("BufDelete", {
      callback = function()
        vim.opt.guicursor = saved_guicursor
        M.block = false
      end,
      buffer = buf,
      once = true,
    })
  end

  return win, bufs
end

return M
