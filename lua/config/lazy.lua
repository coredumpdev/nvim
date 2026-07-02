-- ============================================================================
--  lazy.nvim önyükleme + eklenti spesifikasyonlarını yükleme
-- ============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "lazy.nvim klonlanamadı:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nÇıkmak için bir tuşa basın..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- lua/plugins/ altındaki tüm dosyaları eklenti spesifikasyonu olarak içe aktar
    { import = "plugins" },
  },
  install = { colorscheme = { "catppuccin" } },
  checker = { enabled = true, notify = false }, -- güncellemeleri sessizce kontrol et
  change_detection = { notify = false },
  ui = { border = "rounded" },
})

-- Eklenti yöneticisini açma kısayolu
vim.keymap.set("n", "<leader>L", "<cmd>Lazy<CR>", { desc = "Lazy (eklenti yöneticisi)" })
