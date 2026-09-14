local logo = {
  left = { "              ", "█▀▀▄ █▀▀█ █▀▀█", "█__█ █^^^ █__█", "▀~~▀ ▀▀▀▀ ▀▀▀▀" },
  right = { "     ▀        ", "█  █ █ █▀▀█▀▀▄", "█  █ █ █__█__█", " ▀▀  ▀ ▀~~▀~~▀" },
}

local logo_width = vim.api.nvim_strwidth(logo.left[2] .. " " .. logo.right[2])

local marks = {
  ["_"] = { " ", "Fill" },
  ["^"] = { "▀", "Fill" },
  ["~"] = { "▀", "Shadow" },
}

local transparent_bg_fallback = "#1e1e2e"

local function set_logo_highlights()
  local bg = Snacks.util.color("Normal", "bg") or transparent_bg_fallback
  local sides = {
    Left = { fg = Snacks.util.color("Comment") },
    Right = { fg = Snacks.util.color("Normal"), bold = true },
  }
  for side, hl in pairs(sides) do
    local shadow = Snacks.util.blend(hl.fg, bg, 0.25)
    vim.api.nvim_set_hl(0, "DashboardLogo" .. side, hl)
    vim.api.nvim_set_hl(0, "DashboardLogo" .. side .. "Fill", vim.tbl_extend("force", hl, { bg = shadow }))
    vim.api.nvim_set_hl(0, "DashboardLogo" .. side .. "Shadow", { fg = shadow })
  end
end

local function logo_chunks(line, side)
  local chunks = {}
  for _, char in ipairs(vim.fn.split(line, [[\zs]])) do
    local mark = marks[char] or { char, "" }
    table.insert(chunks, { mark[1], hl = "DashboardLogo" .. side .. mark[2] })
  end
  return chunks
end

local function logo_section()
  set_logo_highlights()
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("DashboardLogo", { clear = true }),
    callback = set_logo_highlights,
  })
  local text = {}
  for row = 1, #logo.left do
    if row > 1 then
      table.insert(text, { "\n" })
    end
    vim.list_extend(text, logo_chunks(logo.left[row], "Left"))
    table.insert(text, { " " })
    vim.list_extend(text, logo_chunks(logo.right[row], "Right"))
  end
  return { text = text, align = "center", padding = 2 }
end

local function startup_section()
  local stats = require("lazy.stats").stats()
  local ms = math.floor(stats.startuptime + 0.5)
  local text = ("loaded %d/%d plugins in %dms"):format(stats.loaded, stats.count, ms)
  return { text = { text, hl = "Comment" }, align = "center", padding = 1 }
end

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    dashboard = {
      width = logo_width,
      formats = {
        desc = { "%s", hl = "Normal" },
        key = { "%s", hl = "Comment" },
      },
      preset = {
        keys = {
          { key = "f", desc = "find file", action = ":lua Snacks.dashboard.pick('files')" },
          { key = "n", desc = "new file", action = ":ene | startinsert" },
          { key = "g", desc = "find text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { key = "r", desc = "recent files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { key = "s", desc = "restore session", section = "session" },
          { key = "q", desc = "quit", action = ":qa" },
        },
      },

      sections = {
        require("dashboard_scene").setup,
        logo_section,
        { section = "keys", padding = 2 },
        startup_section,
      },
    },
  },
}
