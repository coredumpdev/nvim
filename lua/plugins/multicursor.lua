-- ============================================================================
--  Çoklu imleç: vim-visual-multi
--  Bir kelimeyi seçip tüm eşleşmelerini aynı anda düzenle.
--  NOT: Tetik tuşu <C-n>'dir; <C-d> BİLEREK kullanılmadı çünkü keymaps.lua'da
--  "yarım sayfa aşağı" (<C-d>zz) olarak tanımlı. <C-x>/<C-p> yalnızca VM
--  modundayken aktiftir, global bir çakışma oluşturmaz.
-- ============================================================================
return {
  "mg979/vim-visual-multi",
  branch = "master",
  event = "VeryLazy",
  init = function()
    vim.g.VM_maps = {
      ["Find Under"]         = "<C-n>", -- imleç altındaki kelimeyi seç, tekrar bas → sonraki eşleşme
      ["Find Subword Under"] = "<C-n>", -- görsel modda seçimi kullan
      ["Select All"]         = "<leader>A", -- tüm eşleşmeleri birden seç
      ["Skip Region"]        = "<C-x>", -- mevcut eşleşmeyi atla (yalnızca VM modunda)
      ["Remove Region"]      = "<C-p>", -- son eklenen imleci kaldır (yalnızca VM modunda)
    }
    vim.g.VM_theme = "iceblue"
    vim.g.VM_silent_exit = 1 -- moddan çıkınca mesaj gösterme
  end,
}
