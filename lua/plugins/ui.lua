-- ============================================================================
--  Arayüz: dosya ağacı, durum çubuğu, sekmeler, girinti çizgileri, which-key
-- ============================================================================
return {
  -- Dosya gezgini -----------------------------------------------------------
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>t", "<cmd>Neotree toggle<CR>", desc = "Dosya ağacı aç/kapa" },
      { "<leader>o", "<cmd>Neotree focus<CR>", desc = "Dosya ağacına odaklan" },
    },
    opts = {
      close_if_last_window = true,
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = { hide_dotfiles = false, hide_gitignored = true },
      },
      window = { width = 32 },
    },
  },

  -- Durum çubuğu ------------------------------------------------------------
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
      options = {
        theme = "catppuccin-nvim",
        globalstatus = true,
        section_separators = { left = "", right = "" },
        component_separators = { left = "", right = "" },
      },
      sections = {
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "diagnostics", "encoding", "fileformat", "filetype" },
      },
    },
  },

  -- Üst sekme/buffer çubuğu -------------------------------------------------
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        offsets = { { filetype = "neo-tree", text = "Dosyalar", separator = true } },
        show_buffer_close_icons = false,
      },
    },
    config = function(_, opts)
      require("bufferline").setup(opts)
      vim.cmd.colorscheme("catppuccin") -- highlight'ları tazele
    end,
  },

  -- Girinti çizgileri -------------------------------------------------------
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = { indent = { char = "│" }, scope = { enabled = true } },
  },

  -- Git işaretleri ----------------------------------------------------------
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local function m(l, r, d) vim.keymap.set("n", l, r, { buffer = bufnr, desc = d }) end
        m("]h", gs.next_hunk, "Sonraki değişiklik")
        m("[h", gs.prev_hunk, "Önceki değişiklik")
        m("<leader>hp", gs.preview_hunk, "Değişikliği önizle")
        m("<leader>hb", gs.blame_line, "Satır blame")
        m("<leader>hs", gs.stage_hunk, "Değişikliği stage'le")
        m("<leader>hr", gs.reset_hunk, "Değişikliği geri al")
      end,
    },
  },

  -- Tuş ipuçları penceresi --------------------------------------------------
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      spec = {
        { "<leader>f", group = "Bul (find)" },
        { "<leader>h", group = "Git hunk" },
        { "<leader>w", group = "Pencere (window)" },
        { "<leader>b", group = "Buffer" },
        { "<leader>c", group = "Kod (code)" },
        { "<leader>d", group = "Tanı / Debug" },
        { "<leader>r", group = "Yeniden adlandır" },
        { "<leader>x", group = "Hex" },
      },
    },
  },
}
