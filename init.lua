-- ============================================================================
--  Neovim yapılandırması — C / C++ / Sistem prog. / Linux kernel / C# / Go
--  Tema: Catppuccin
--  Yapı: lua/config (ayarlar) + lua/plugins (eklentiler, lazy.nvim ile)
-- ============================================================================

-- Leader tuşu, eklentiler yüklenmeden ÖNCE tanımlanmalı
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.keymaps")
require("config.lazy")
