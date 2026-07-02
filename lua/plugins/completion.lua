-- ============================================================================
--  Otomatik tamamlama: blink.cmp (hızlı, modern) + LuaSnip snippet motoru
-- ============================================================================
return {
  "saghen/blink.cmp",
  version = "*", -- önceden derlenmiş ikili indirir (Rust fuzzy eşleştirici)
  dependencies = {
    {
      "L3MON4D3/LuaSnip",
      version = "v2.*",
      dependencies = { "rafamadriz/friendly-snippets" },
      config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
      end,
    },
  },
  event = "InsertEnter",
  opts = {
    snippets = { preset = "luasnip" },
    keymap = {
      preset = "default", -- <C-space> menü, <C-y> onayla, <C-e> iptal
      ["<CR>"] = { "accept", "fallback" },
      ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
      ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      ["<C-j>"] = { "select_next", "fallback" },
      ["<C-k>"] = { "select_prev", "fallback" },
    },
    appearance = { nerd_font_variant = "mono" },
    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
      menu = { border = "rounded" },
      ghost_text = { enabled = true },
    },
    signature = { enabled = true, window = { border = "rounded" } },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
  opts_extend = { "sources.default" },
}
