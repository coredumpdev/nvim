-- ============================================================================
--  Genel tuş atamaları  (Leader = <Space>)
--  LSP ve eklentiye özel atamalar ilgili plugin dosyalarında tanımlıdır.
-- ============================================================================
local map = vim.keymap.set

-- Arama vurgusunu temizle
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Vurguyu temizle" })

-- Kaydet (Ctrl+S — normal, insert ve görsel modda)
-- Not: <leader>w artık PENCERE grubudur (aşağıda); kaydetme <C-s> ile.
map({ "n", "i", "v" }, "<C-s>", "<cmd>write<CR><Esc>", { desc = "Kaydet" })

-- ---------------------------------------------------------------------------
-- Pencere (window) yönetimi  ->  <leader>w... ve <C-w> yerleşik
-- ---------------------------------------------------------------------------
-- Pencereler arası gezinme (Ctrl + h/j/k/l)
map("n", "<C-h>", "<C-w>h", { desc = "Sol pencere" })
map("n", "<C-j>", "<C-w>j", { desc = "Alt pencere" })
map("n", "<C-k>", "<C-w>k", { desc = "Üst pencere" })
map("n", "<C-l>", "<C-w>l", { desc = "Sağ pencere" })

-- Pencere boyutlandırma
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Yükseklik +" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Yükseklik -" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Genişlik -" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Genişlik +" })

-- Pencere aç / kapat / böl  (istenen: pencere kapatma keymap'i)
map("n", "<leader>wc", "<C-w>c", { desc = "Pencereyi kapat" })
map("n", "<leader>wq", "<C-w>q", { desc = "Pencereden çık" })
map("n", "<leader>wo", "<C-w>o", { desc = "Diğer pencereleri kapat" })
map("n", "<leader>wv", "<cmd>vsplit<CR>", { desc = "Dikey böl" })
map("n", "<leader>ws", "<cmd>split<CR>", { desc = "Yatay böl" })
map("n", "<leader>w=", "<C-w>=", { desc = "Pencereleri eşitle" })
-- Kısa yol: son pencereyi kapatınca nvim'den çıkma yerine güvenli kapat
map("n", "<leader>q", "<C-w>c", { desc = "Pencereyi kapat" })
map("n", "<leader>Q", "<cmd>qall<CR>", { desc = "Neovim'den çık (hepsi)" })

-- ---------------------------------------------------------------------------
-- Buffer yönetimi  (Shift+H / Shift+L ile geçiş)
-- Not: yalnızca normal dosya buffer'larında çalışır; neo-tree/terminal gibi
-- özel pencerelerde bir şey yapmaz (yanlışlıkla içeriği değiştirmesin diye).
-- ---------------------------------------------------------------------------
local function buf_cycle(cmd)
  if vim.bo.buftype ~= "" then return end -- özel pencere -> dokunma
  pcall(vim.cmd, cmd)
end
map("n", "<S-l>", function() buf_cycle("bnext") end, { desc = "Sonraki buffer" })
map("n", "<S-h>", function() buf_cycle("bprevious") end, { desc = "Önceki buffer" })

-- Buffer'ı kapat AMA pencereyi/Neovim'i kapatma (tek buffer kalsa bile güvenli)
local function buf_close()
  local cur = vim.api.nvim_get_current_buf()
  local listed = vim.fn.getbufinfo({ buflisted = 1 })
  if #listed > 1 then
    vim.cmd("bprevious")
  else
    vim.cmd("enew") -- son buffer'sa boş bir buffer aç, nvim açık kalsın
  end
  pcall(vim.cmd, "bdelete " .. cur)
end
map("n", "<leader>bd", buf_close, { desc = "Buffer'ı kapat (pencere kalır)" })
map("n", "<leader>bo", "<cmd>%bd|e#|bd#<CR>", { desc = "Diğer buffer'ları kapat" })

-- Görsel modda satır kaydırma
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Satırı aşağı taşı" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Satırı yukarı taşı" })

-- Görsel modda girinti sonrası seçimi koru
map("v", "<", "<gv", { desc = "Girintiyi azalt" })
map("v", ">", ">gv", { desc = "Girintiyi artır" })

-- İmleci merkezde tutarak arama/kaydırma
map("n", "n", "nzzzv", { desc = "Sonraki eşleşme (merkez)" })
map("n", "N", "Nzzzv", { desc = "Önceki eşleşme (merkez)" })
map("n", "<C-d>", "<C-d>zz", { desc = "Yarım sayfa aşağı" })
map("n", "<C-u>", "<C-u>zz", { desc = "Yarım sayfa yukarı" })

-- Diagnostic gezinme
map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Önceki tanı" })
map("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Sonraki tanı" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Tanıyı göster" })
map("n", "<leader>dl", vim.diagnostic.setloclist, { desc = "Tanı listesi" })

-- Terminalden çıkış kolaylığı
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Terminal normal moduna" })
