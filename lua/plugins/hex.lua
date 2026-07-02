-- ============================================================================
--  Hex görüntüleyici / düzenleyici: hex.nvim  (xxd tabanlı)
--  Binary dosyaları (ELF, .bin, .o, firmware...) hex olarak görüntüle/düzenle.
-- ============================================================================
return {
  "RaafatTurki/hex.nvim",
  cmd = { "HexToggle", "HexDump", "HexAssemble" },
  keys = {
    { "<leader>xx", "<cmd>HexToggle<CR>", desc = "Hex görünümü aç/kapa" },
    { "<leader>xd", "<cmd>HexDump<CR>", desc = "Hex'e çevir (dump)" },
    { "<leader>xa", "<cmd>HexAssemble<CR>", desc = "Hex'ten geri çevir (assemble)" },
  },
  opts = {
    -- xxd sistemde kurulu; varsayılan komutlar kullanılır
    dump_cmd = "xxd -g 1 -u",
    assemble_cmd = "xxd -r",
    -- Bilinen binary uzantıları açıldığında otomatik hex görünümüne geç
    is_file_binary_pre_read = function()
      local binary_ext = { "bin", "o", "elf", "out", "a", "so", "hex", "dat", "img", "dfu" }
      local ext = vim.fn.expand("%:e")
      return vim.tbl_contains(binary_ext, ext)
    end,
  },
}
