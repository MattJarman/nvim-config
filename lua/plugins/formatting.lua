local biome_filetypes =
  { "javascript", "javascriptreact", "typescript", "typescriptreact", "json", "jsonc", "css", "scss", "graphql", "vue" }
local other_filetypes = { "html", "less", "yaml", "handlebars" }
local markdown_filetypes = { "markdown", "markdown.mdx" }

local function first(bufnr, ...)
  local conform = require("conform")
  for i = 1, select("#", ...) do
    local formatter = select(i, ...)
    if conform.get_formatter_info(formatter, bufnr).available then
      return formatter
    end
  end
  return select(1, ...)
end

return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters.oxfmt = {
        cwd = require("conform.util").root_file({ ".oxfmtrc.json", ".oxfmtrc.jsonc", "oxfmt.config.ts" }),
        require_cwd = true,
      }
      for _, ft in ipairs(biome_filetypes) do
        opts.formatters_by_ft[ft] = { "biome-check", "oxfmt", "prettier", stop_after_first = true }
      end
      for _, ft in ipairs(other_filetypes) do
        opts.formatters_by_ft[ft] = { "oxfmt", "prettier", stop_after_first = true }
      end
      for _, ft in ipairs(markdown_filetypes) do
        opts.formatters_by_ft[ft] = function(bufnr)
          return { first(bufnr, "oxfmt", "prettier"), "markdownlint-cli2", "markdown-toc" }
        end
      end
    end,
  },
}
