-- ============================================================================
--  Formatlama: conform.nvim
--  Kayıtta otomatik format + <leader>f ile elle format
-- ============================================================================
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>f",
      function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
      mode = { "n", "v" },
      desc = "Kodu formatla",
    },
  },
  opts = {
    formatters_by_ft = {
      c = { "clang_format" },
      cpp = { "clang_format" },
      cs = { "csharpier" },
      go = { "goimports", "gofumpt" },
      lua = { "stylua" },
      -- cmake: neocmake LSP formatlaması (lsp_format fallback) kullanılır
    },
    -- Kayıtta otomatik formatla (LSP formatına geri dönüş yapılır)
    format_on_save = function(bufnr)
      -- Makefile'ları formatlama (tab yapısı bozulmasın)
      if vim.bo[bufnr].filetype == "make" then return end
      return { timeout_ms = 3000, lsp_format = "fallback" }
    end,
    formatters = {
      clang_format = {
        -- .clang-format dosyası varsa kullan, yoksa LLVM tarzı
        prepend_args = { "--fallback-style=LLVM" },
      },
    },
  },
  init = function()
    -- gq operatörü için conform'u kullan
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
}
