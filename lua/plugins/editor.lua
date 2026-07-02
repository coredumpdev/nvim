-- ============================================================================
--  Editör yardımcıları: otomatik parantez, yorumlama, çevreleme, tmux gezinme
-- ============================================================================
return {
  -- Otomatik parantez/tırnak kapatma
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },

  -- gcc / gc ile yorum satırı aç/kapa (nvim yerleşik değilse)
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  -- ys/cs/ds ile çevreleme (ör. ysiw" → kelimeyi tırnağa al)
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },

  -- Otomatik tespit edilen sekme/boşluk (proje stiline uyum)
  {
    "tpope/vim-sleuth",
    event = { "BufReadPost", "BufNewFile" },
  },

  -- Todo/FIXME/NOTE vurgulama + arama
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = true },
  },
}
