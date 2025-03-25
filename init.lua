-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- macros
vim.fn.setreg("l", vim.api.nvim_replace_termcodes('yoconsole.log("<Esc>pa: ", <Esc>p$a;<Esc>"', true, true, true))
