local logo = {
  left = { "              ", "█▀▀▄ █▀▀█ █▀▀█", "█__█ █^^^ █__█", "▀~~▀ ▀▀▀▀ ▀▀▀▀" },
  right = { "     ▀        ", "█  █ █ █▀▀█▀▀▄", "█  █ █ █__█__█", " ▀▀  ▀ ▀~~▀~~▀" },
}

local marks = {
  ["_"] = { " ", "Fill" },
  ["^"] = { "▀", "Fill" },
  ["~"] = { "▀", "Shadow" },
}

local transparent_bg_fallback = "#1e1e2e"

local tips = {
  "Press gx to open the link under the cursor",
  "Press gcc to toggle a comment on the current line",
  "Press <C-o> to jump back to where you came from",
  "Press gv to reselect the last visual selection",
  "Press gi to resume insert where you left off",
  "Press <C-a> or <C-x> to bump the number under the cursor",
  "Press * to search for the word under the cursor",
  "Press q: to edit your command history in a buffer",
  "Use :g/pattern/d to delete every matching line",
  "Use :%s/old/new/gc to replace with confirmation",
}

local tip = tips[vim.uv.hrtime() % #tips + 1]

local function set_highlights()
  local bg = Snacks.util.color("Normal", "bg") or transparent_bg_fallback
  local fg = Snacks.util.color("Normal")
  local muted = Snacks.util.color("Comment")
  local sides = {
    Left = { fg = muted },
    Right = { fg = fg, bold = true },
  }
  for side, hl in pairs(sides) do
    local shadow = Snacks.util.blend(hl.fg, bg, 0.25)
    vim.api.nvim_set_hl(0, "DashboardLogo" .. side, hl)
    vim.api.nvim_set_hl(0, "DashboardLogo" .. side .. "Fill", vim.tbl_extend("force", hl, { bg = shadow }))
    vim.api.nvim_set_hl(0, "DashboardLogo" .. side .. "Shadow", { fg = shadow })
  end
  vim.api.nvim_set_hl(0, "DashboardText", { fg = fg })
  vim.api.nvim_set_hl(0, "DashboardMuted", { fg = muted })
  vim.api.nvim_set_hl(0, "DashboardTip", { fg = Snacks.util.color("DiagnosticWarn") })
end

local function logo_chunks(line, side)
  local chunks = {}
  for _, char in ipairs(vim.fn.split(line, [[\zs]])) do
    local mark = marks[char] or { char, "" }
    table.insert(chunks, { mark[1], hl = "DashboardLogo" .. side .. mark[2] })
  end
  return chunks
end

local function version_row()
  local version = vim.version()
  local label = ("v%d.%d.%d"):format(version.major, version.minor, version.patch)
  local logo_width = vim.api.nvim_strwidth(logo.left[1] .. " " .. logo.right[1])
  return { { (" "):rep(logo_width - #label) }, { label, hl = "DashboardMuted" } }
end

local function logo_section()
  set_highlights()
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("DashboardLogo", { clear = true }),
    callback = set_highlights,
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
  table.insert(text, { "\n" })
  vim.list_extend(text, version_row())
  return { text = text, align = "center", padding = 2 }
end

local function tip_section()
  return {
    text = { { "● Tip ", hl = "DashboardTip" }, { tip, hl = "DashboardMuted" } },
    align = "center",
    padding = 2,
  }
end

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    dashboard = {
      width = 44,
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

      formats = {
        desc = function(item)
          return { item.desc, hl = "DashboardText" }
        end,
        key = function(item)
          return { item.key, hl = "DashboardMuted" }
        end,
      },

      sections = {
        logo_section,
        { section = "keys", padding = 2 },
        tip_section,
        { section = "startup", padding = 1 },
      },
    },
  },
}
