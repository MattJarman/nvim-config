return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      window = { position = "right" },
    },
  },
  {
    "folke/edgy.nvim",
    opts = {
      animate = {
        enabled = false,
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      opts.options.component_separators = ""
      opts.options.section_separators = ""
      opts.sections.lualine_z = {}
      table.remove(opts.sections.lualine_c)

      -- Transparent statusline: strip section backgrounds. The mode
      -- indicator (lualine_a) uses dark text on a colored bg, so recolor
      -- its text to that accent color before dropping the background.
      local theme = require("lualine.themes.kanagawa")
      for _, mode in pairs(theme) do
        if mode.a and mode.a.bg then
          mode.a.fg = mode.a.bg
        end
        for _, section in pairs(mode) do
          section.bg = nil
        end
      end
      opts.options.theme = theme
    end,
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      notifier = { enabled = false },
    },
  },
  { "nvim-neotest/neotest-jest", "marilari88/neotest-vitest" },
  {
    "nvim-neotest/neotest",
    opts = { adapters = { "neotest-jest", "neotest-vitest" } },
  },
}
