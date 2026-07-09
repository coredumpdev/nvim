-- ============================================================================
--  Genel editör ayarları
-- ============================================================================
local opt = vim.opt

-- Satır numaraları
opt.number = true
opt.relativenumber = true

-- Girinti (varsayılan 4 boşluk). Linux kernel ve Go için filetype
-- özel ayarları aşağıdaki autocmd'lerle geçersiz kılınır.
opt.expandtab = true
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.smartindent = true
opt.autoindent = true

-- Arama
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Görünüm
opt.termguicolors = true -- Catppuccin için gerekli
opt.signcolumn = "yes" -- Diagnostic işaretleri satırı kaydırmasın
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.colorcolumn = "80,100" -- 80 (kernel) ve 100 sütun kılavuzu
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Davranış
opt.mouse = "a"
opt.clipboard = "unnamedplus" -- Sistem panosunu kullan
opt.undofile = true -- Kalıcı geri-al geçmişi
opt.swapfile = false
opt.backup = false
opt.updatetime = 250
opt.timeoutlen = 400
opt.splitright = true
opt.splitbelow = true
opt.completeopt = "menu,menuone,noselect"
opt.confirm = true

-- Bölünmüş pencerelerde daha akıcı
opt.fillchars = { eob = " " }

-- Diagnostic görünümü (nvim 0.11)
vim.diagnostic.config({
	virtual_text = { prefix = "●", spacing = 2 },
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = { border = "rounded", source = true },
})

-- ---------------------------------------------------------------------------
-- Embedded / STM32 dosya tipleri
-- ---------------------------------------------------------------------------
vim.filetype.add({
	extension = {
		ld = "ld", -- linker script
		lds = "ld",
		ioc = "confini", -- STM32CubeMX proje dosyası (ini benzeri)
		s = "asm", -- ARM assembly
		S = "asm",
	},
	filename = {
		["openocd.cfg"] = "tcl", -- OpenOCD betikleri Tcl'dir
	},
})

-- ---------------------------------------------------------------------------
-- Dile özel girinti ayarları
-- ---------------------------------------------------------------------------
local aug = vim.api.nvim_create_augroup("UserFiletypeIndent", { clear = true })

-- Go: gerçek tab, girinti 4 (gofmt standardı)
vim.api.nvim_create_autocmd("FileType", {
	group = aug,
	pattern = "go",
	callback = function()
		vim.bo.expandtab = false
		vim.bo.tabstop = 4
		vim.bo.shiftwidth = 4
	end,
})

-- Linux kernel tarzı: gerçek tab, genişlik 8, 80 sütun
-- (kernel kaynak ağacında olduğunuzda faydalı)
vim.api.nvim_create_autocmd("FileType", {
	group = aug,
	pattern = { "c", "cpp", "h", "hpp", "cc" },
	callback = function()
		-- vim-sleuth bu buffer'da otomatik tahmin yapmasın (4'ü ezmesin)
		vim.b.sleuth_automatic = 0
		-- Varsayılan C/C++ 4 boşluk; kernel modu için :set noexpandtab ts=8 sw=8
		vim.bo.tabstop = 4
		vim.bo.softtabstop = 4
		vim.bo.shiftwidth = 4
		vim.bo.expandtab = true
	end,
})

-- Makefile: her zaman gerçek tab (zorunlu!)
vim.api.nvim_create_autocmd("FileType", {
	group = aug,
	pattern = "make",
	callback = function()
		vim.bo.expandtab = false
		vim.bo.tabstop = 4
		vim.bo.shiftwidth = 4
	end,
})

-- Kayıtta sondaki boşlukları temizle (Makefile hariç)
vim.api.nvim_create_autocmd("BufWritePre", {
	group = aug,
	pattern = "*",
	callback = function()
		if vim.bo.filetype == "make" then
			return
		end
		local save = vim.fn.winsaveview()
		vim.cmd([[keeppatterns %s/\s\+$//e]])
		vim.fn.winrestview(save)
	end,
})

-- Yank (kopyalama) yapıldığında kısa vurgu
vim.api.nvim_create_autocmd("TextYankPost", {
	group = aug,
	callback = function()
		vim.highlight.on_yank({ timeout = 150 })
	end,
})
