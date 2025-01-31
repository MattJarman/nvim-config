return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "enter",
        ["<Tab>"] = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
      },
    },
  },
  {
    "williamboman/mason.nvim",
    opts = { ensure_installed = { "emmet-language-server" } },
  },
  { "tpope/vim-abolish" },
  { "markonm/traces.vim" },
}
