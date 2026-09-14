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
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "emmet-language-server", "biome" } },
  },
  { "tpope/vim-abolish" },
  { "markonm/traces.vim" },
}
