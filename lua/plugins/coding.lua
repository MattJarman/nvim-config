return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "enter",
        ["<Tab>"] = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
        ["<C-l>"] = { "snippet_forward", "fallback" },
        ["<C-h>"] = { "snippet_backward", "fallback" },
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
