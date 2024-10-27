return {
  "folke/noice.nvim",
  opts = {
    routes = {
      {
        filter = {
          event = "notify",
          kind = "info",
          any = {
            { find = "hidden" },
          },
        },
        opts = { skip = true },
      },
    },
    lsp = {
      hover = {
        silent = true,
      },
    },
  },
}
