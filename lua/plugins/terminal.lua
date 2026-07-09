-- ============================================================================
--  Terminal: akmz/toggleterm.nvim
--  Neovim içinde kayan / yatay / dikey terminal aç-kapa.
--  NOT: Aç-kapa tuşu <C-/> seçildi. <C-\> BİLEREK kullanılmadı çünkü
--  keymaps.lua'da terminalden çıkış "<C-\\><C-n>" olarak tanımlı ve tek
--  başına <C-\> ile çakışıp gecikmeye yol açardı.
-- ============================================================================
return {
  "akinsho/toggleterm.nvim",
  version = "*",
  keys = {
    -- Hızlı aç-kapa: normal ve terminal modunda aynı tuş.
    -- NOT: Çoğu terminal (xterm/GNOME/foot...) Ctrl+/ tuşunu Neovim'e <C-_>
    -- (0x1f) olarak gönderir, <C-/> olarak DEĞİL. İkisi de bağlandı ki
    -- terminalin hangisini gönderdiği fark etmesin.
    -- <leader>T (BÜYÜK T) kullanıldı; <leader>t (küçük) neo-tree'ye bağlı.
    { [[<C-/>]], "<cmd>ToggleTerm<CR>", mode = { "n", "t" }, desc = "Terminal aç/kapat" },
    { [[<C-_>]], "<cmd>ToggleTerm<CR>", mode = { "n", "t" }, desc = "Terminal aç/kapat" },
    { "<leader>Tf", "<cmd>ToggleTerm direction=float<CR>", desc = "Terminal (kayan)" },
    { "<leader>Th", "<cmd>ToggleTerm direction=horizontal<CR>", desc = "Terminal (yatay)" },
    { "<leader>Tv", "<cmd>ToggleTerm direction=vertical<CR>", desc = "Terminal (dikey)" },
  },
  opts = {
    -- Aç-kapa tuşları yukarıda `keys` içinde tanımlı (<C-/> ve <C-_>).
    open_mapping = [[<C-_>]],
    direction = "float",              -- varsayılan: kayan pencere
    shade_terminals = true,           -- terminali biraz koyulaştır
    start_in_insert = true,           -- açılınca doğrudan yazmaya başla
    persist_size = true,
    persist_mode = true,
    size = function(term)
      if term.direction == "horizontal" then
        return 15
      elseif term.direction == "vertical" then
        return math.floor(vim.o.columns * 0.4)
      end
    end,
    float_opts = {
      border = "curved",
      width = function() return math.floor(vim.o.columns * 0.85) end,
      height = function() return math.floor(vim.o.lines * 0.85) end,
    },
  },
}
