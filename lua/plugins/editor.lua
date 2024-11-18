return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      window = { position = "right" },
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
    end,
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
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--line-number",
          "--column",
          "--smart-case",
          "--hidden",
          "--glob",
          "!{**/.git/*,**/node_modules/*,**/pkg/mod/*,**/yarn.lock,**/.local/*}",
        },
      },
    },
  },
  { "nvim-neotest/neotest-jest", "marilari88/neotest-vitest" },
  {
    "nvim-neotest/neotest",
    opts = { adapters = { "neotest-jest", "neotest-vitest" } },
  },
}
