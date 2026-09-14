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
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      notifier = { enabled = false },
      picker = {
        sources = {
          files = { exclude = { "node_modules" } },
          grep = { exclude = { "node_modules" } },
        },
      },
    },
  },
  { "folk/noice.nvim", opts = { lsp = { hover = { silent = true } } } },
  { "nvim-neotest/neotest-jest", "marilari88/neotest-vitest" },
  {
    "nvim-neotest/neotest",
    opts = { adapters = { "neotest-jest", "neotest-vitest" } },
  },
}
