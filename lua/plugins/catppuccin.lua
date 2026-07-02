-- ============================================================================
--  Catppuccin teması
-- ============================================================================
return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000, -- diğer eklentilerden önce yüklensin
  config = function()
    require("catppuccin").setup({
      flavour = "mocha", -- latte | frappe | macchiato | mocha
      background = { light = "latte", dark = "mocha" },
      transparent_background = false,
      term_colors = true,
      integrations = {
        cmp = true,
        blink_cmp = true,
        gitsigns = true,
        treesitter = true,
        telescope = { enabled = true },
        mason = true,
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
        neotree = true,
        which_key = true,
        indent_blankline = { enabled = true },
      },
    })
    vim.cmd.colorscheme("catppuccin")
  end,
}
