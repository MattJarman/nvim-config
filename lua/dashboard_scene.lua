local M = {}

local shade_lightness = { 0.2, 0.28, 0.38, 0.52, 0.7 }
local saturation_scale = 0.75
local keep_out_margin = { rows = 1, cols = 3 }

local ns = vim.api.nvim_create_namespace("dashboard_scene")

local function noise(x, y, seed)
  local s = math.sin(x * 12.9898 + y * 78.233 + seed * 37.719) * 43758.5453
  return s - math.floor(s)
end

local Canvas = {}
Canvas.__index = Canvas

function Canvas.new(width, height)
  return setmetatable({ width = width, height = height, pixels = {} }, Canvas)
end

function Canvas:set(x, y, level)
  x, y = math.floor(x + 0.5), math.floor(y + 0.5)
  if x >= 1 and x <= self.width and y >= 1 and y <= self.height then
    self.pixels[(y - 1) * self.width + x] = level
  end
end

function Canvas:get(x, y)
  return self.pixels[(y - 1) * self.width + x] or 0
end

local function draw_stars(canvas, horizon)
  for y = 1, horizon do
    for x = 1, canvas.width do
      local n = noise(x, y, 1)
      if n < 0.006 then
        canvas:set(x, y, n < 0.002 and 3 or 2)
      end
    end
  end
  for i = 1, math.floor(canvas.width * horizon / 800) do
    local x = math.floor(noise(i, 1, 2) * canvas.width) + 1
    local y = math.floor(noise(i, 1, 3) * horizon) + 1
    local arm = noise(i, 1, 4) < 0.3 and 2 or 1
    for d = -arm, arm do
      canvas:set(x + d, y, 3)
      canvas:set(x, y + d, 3)
    end
    canvas:set(x, y, 4)
  end
end

local function draw_moon(canvas, cx, cy, radius)
  for y = math.floor(cy - radius), math.ceil(cy + radius) do
    for x = math.floor(cx - radius), math.ceil(cx + radius) do
      local dx, dy = x - cx, y - cy
      if dx * dx + dy * dy <= radius * radius then
        local light = (-dx - dy * 0.5) / radius
        local level = light > 0.35 and 3 or 2
        if light > -0.15 and light <= 0.35 and (x + y) % 2 == 0 then
          level = 3
        end
        if noise(math.floor(x / 2), math.floor(y / 2), 5) < 0.22 then
          level = level - 1
        end
        canvas:set(x, y, level)
      end
    end
  end
end

local cloud_puffs = {
  { 0, 0, 1 },
  { 0.7, -0.45, 0.7 },
  { -1.3, 0.3, 0.8 },
  { 1.5, 0.25, 0.85 },
  { -2.5, 0.55, 0.55 },
  { 2.7, 0.5, 0.6 },
}

local function draw_cloud(canvas, cx, cy, size)
  local function inside(x, y)
    if y > cy + size * 0.85 then
      return false
    end
    for _, puff in ipairs(cloud_puffs) do
      local dx = (x - (cx + puff[1] * size)) / (puff[3] * size * 1.15)
      local dy = (y - (cy + puff[2] * size)) / (puff[3] * size)
      if dx * dx + dy * dy <= 1 then
        return true
      end
    end
    return false
  end
  for y = math.floor(cy - size * 1.3), math.ceil(cy + size) do
    for x = math.floor(cx - size * 3.8), math.ceil(cx + size * 3.8) do
      if inside(x, y) then
        canvas:set(x, y, (inside(x, y - 1) and inside(x - 1, y)) and 1 or 2)
      end
    end
  end
end

local function wave_top(x, layer)
  local chop = 1 - 2 * math.abs(math.sin(x * layer.freq + layer.phase))
  local swell = 0.65 * chop + 0.35 * math.sin(x * layer.freq * 0.37 + layer.phase * 3)
  return layer.base - layer.height * swell, swell
end

local function draw_wave(canvas, layer, seed)
  for x = 1, canvas.width do
    local top, swell = wave_top(x, layer)
    for y = math.max(1, math.ceil(top)), canvas.height do
      local depth = y - top
      local level = layer.level
      if depth < 1 then
        level = swell > 0.45 and layer.crest or layer.level + 1
      elseif depth < 2.5 and swell > 0.3 and noise(x, y, seed) < 0.55 then
        level = layer.crest - 1
      elseif math.floor(depth) % 4 == 2 and noise(x, y, seed + 1) < 0.35 then
        level = layer.level + 1
      end
      canvas:set(x, y, level)
    end
  end
end

function M.paint(width, height, content_bottom)
  local canvas = Canvas.new(width, height)
  local horizon = math.min(height - 4, math.max(math.floor(height * 0.68), content_bottom + 3))
  local sea = height - horizon
  draw_stars(canvas, horizon)
  draw_moon(canvas, width * 0.84, height * 0.2, math.max(4, height * 0.1))
  draw_cloud(canvas, width * 0.06, horizon * 0.6, math.max(3, height * 0.06))
  draw_cloud(canvas, width * 0.95, horizon * 0.48, math.max(3, height * 0.07))
  draw_wave(canvas, { base = horizon, height = sea * 0.07, freq = 0.16, phase = 0.4, level = 1, crest = 3 }, 11)
  draw_wave(canvas, { base = horizon + sea * 0.3, height = sea * 0.08, freq = 0.13, phase = 2.1, level = 2, crest = 4 }, 13)
  draw_wave(canvas, { base = horizon + sea * 0.55, height = sea * 0.08, freq = 0.19, phase = 1.3, level = 2, crest = 4 }, 17)
  draw_wave(canvas, { base = horizon + sea * 0.8, height = sea * 0.07, freq = 0.15, phase = 4.2, level = 3, crest = 5 }, 19)
  return canvas
end

local function hue_and_saturation(hex)
  local r, g, b = tonumber(hex:sub(2, 3), 16) / 255, tonumber(hex:sub(4, 5), 16) / 255, tonumber(hex:sub(6, 7), 16) / 255
  local max, min = math.max(r, g, b), math.min(r, g, b)
  local delta = max - min
  if delta == 0 then
    return 0, 0
  end
  local lightness = (max + min) / 2
  local saturation = delta / (1 - math.abs(2 * lightness - 1))
  local hue
  if max == r then
    hue = ((g - b) / delta) % 6
  elseif max == g then
    hue = (b - r) / delta + 2
  else
    hue = (r - g) / delta + 4
  end
  return hue * 60, saturation
end

local function hsl_to_hex(hue, saturation, lightness)
  local chroma = (1 - math.abs(2 * lightness - 1)) * saturation
  local x = chroma * (1 - math.abs((hue / 60) % 2 - 1))
  local sector = math.floor(hue / 60) % 6
  local rgb = ({
    [0] = { chroma, x, 0 },
    { x, chroma, 0 },
    { 0, chroma, x },
    { 0, x, chroma },
    { x, 0, chroma },
    { chroma, 0, x },
  })[sector]
  local m = lightness - chroma / 2
  return ("#%02x%02x%02x"):format(
    math.floor((rgb[1] + m) * 255 + 0.5),
    math.floor((rgb[2] + m) * 255 + 0.5),
    math.floor((rgb[3] + m) * 255 + 0.5)
  )
end

local function cell_group(top, bottom)
  return ("DashboardScene%d%d"):format(top, bottom)
end

function M.set_highlights()
  local hue, saturation = hue_and_saturation(Snacks.util.color({ "Function", "Special" }))
  local colors = {}
  for level, lightness in ipairs(shade_lightness) do
    colors[level] = hsl_to_hex(hue, saturation * saturation_scale, lightness)
  end
  for top = 0, #colors do
    for bottom = 0, #colors do
      vim.api.nvim_set_hl(0, cell_group(top, bottom), {
        fg = colors[top] or colors[bottom],
        bg = top > 0 and colors[bottom] or nil,
      })
    end
  end
end

local function cell(top, bottom)
  if top == 0 then
    return "▄", cell_group(0, bottom)
  end
  return "▀", cell_group(top, bottom)
end

local function content_box(lines)
  local box
  for row, line in ipairs(lines) do
    local col = 0
    for _, char in ipairs(vim.fn.split(line, [[\zs]])) do
      col = col + 1
      if char ~= " " then
        box = box or { top = row, bottom = row, left = col, right = col }
        box.top, box.bottom = math.min(box.top, row), math.max(box.bottom, row)
        box.left, box.right = math.min(box.left, col), math.max(box.right, col)
      end
      col = col + vim.fn.strdisplaywidth(char) - 1
    end
  end
  if box then
    box.top, box.bottom = box.top - keep_out_margin.rows, box.bottom + keep_out_margin.rows
    box.left, box.right = box.left - keep_out_margin.cols, box.right + keep_out_margin.cols
  end
  return box
end

local function in_box(box, row, col)
  return box and row >= box.top and row <= box.bottom and col >= box.left and col <= box.right
end

local function fill_window_height(buf, height)
  local count = vim.api.nvim_buf_line_count(buf)
  if count < height then
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, count, count, false, vim.fn["repeat"]({ "" }, height - count))
    vim.bo[buf].modifiable = false
  end
end

local function row_segments(canvas, box, row)
  local segments, current = {}, nil
  for col = 1, canvas.width do
    local top, bottom = canvas:get(col, row * 2 - 1), canvas:get(col, row * 2)
    if in_box(box, row, col) or (top == 0 and bottom == 0) then
      current = nil
    else
      local char, group = cell(top, bottom)
      if not current then
        current = { col = col, chunks = {} }
        table.insert(segments, current)
      end
      local last = current.chunks[#current.chunks]
      if last and last[2] == group then
        last[1] = last[1] .. char
      else
        table.insert(current.chunks, { char, group })
      end
    end
  end
  return segments
end

function M.draw(buf, win)
  local width, height = vim.api.nvim_win_get_width(win), vim.api.nvim_win_get_height(win)
  local box = content_box(vim.api.nvim_buf_get_lines(buf, 0, height, false))
  fill_window_height(buf, height)
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  local canvas = M.paint(width, height * 2, box and box.bottom * 2 or 0)
  for row = 1, height do
    for _, segment in ipairs(row_segments(canvas, box, row)) do
      vim.api.nvim_buf_set_extmark(buf, ns, row - 1, 0, {
        virt_text = segment.chunks,
        virt_text_win_col = segment.col - 1,
      })
    end
  end
end

local function is_dashboard(win)
  return vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "snacks_dashboard"
end

local function float_has_focus()
  local win = vim.api.nvim_get_current_win()
  return vim.api.nvim_win_get_config(win).relative ~= "" and not is_dashboard(win)
end

local hidden_under_float = false

local function refresh_dashboards()
  hidden_under_float = float_has_focus()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if is_dashboard(win) then
      local buf = vim.api.nvim_win_get_buf(win)
      if hidden_under_float then
        vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
      else
        M.draw(buf, win)
      end
    end
  end
end

local function refresh_if_focus_changed()
  if float_has_focus() ~= hidden_under_float then
    refresh_dashboards()
  end
end

function M.setup()
  M.set_highlights()
  local group = vim.api.nvim_create_augroup("DashboardScene", { clear = true })
  vim.api.nvim_create_autocmd("User", { group = group, pattern = "SnacksDashboardUpdatePost", callback = refresh_dashboards })
  -- Snacks closes terminal floats (lazygit) from inside TermClose, and autocmds
  -- don't nest, so WinEnter never fires on return; SafeState catches that.
  vim.api.nvim_create_autocmd(
    { "WinEnter", "BufEnter", "SafeState" },
    { group = group, callback = refresh_if_focus_changed }
  )
  vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = M.set_highlights })
end

return M
