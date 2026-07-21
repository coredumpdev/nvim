-- ============================================================================
--  Markdown: editör içi canlı render (render-markdown.nvim)
--
--  LSP (marksman) lsp.lua'da, formatlama (prettierd) formatting.lua'da,
--  treesitter parser'ları (markdown + markdown_inline) treesitter.lua'da.
--  Bu dosya yalnızca görsel render'ı ekler — tarayıcı gerektirmez.
--
--  Kullanım:
--    Markdown dosyası açınca otomatik render'lanır (başlık, liste, kod bloğu,
--    tablo, onay kutusu, link ikonları...). İmleç bir satırdayken o satır ham
--    (raw) gösterilir ki düzenleyebilesin.
--    <leader>mr  -> render aç/kapa
-- ============================================================================
return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter", -- markdown + markdown_inline parser'ları
    "nvim-tree/nvim-web-devicons", -- kod bloğu dil ikonları
  },
  ft = { "markdown", "markdown.mdx" },
  keys = {
    { "<leader>mr", "<cmd>RenderMarkdown toggle<cr>", desc = "Markdown render aç/kapa" },
  },
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    -- İmlecin olduğu satırı ham göster (düzenleme kolaylığı)
    render_modes = { "n", "c", "t" },
    code = {
      sign = false,
      width = "block", -- kod bloğunu içerik genişliğinde çerçevele
      right_pad = 1,
    },
    heading = {
      sign = false,
      icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
    },
  },
}
