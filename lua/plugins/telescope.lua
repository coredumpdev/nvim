-- ============================================================================
--  Telescope: dosya/metin bulanık arama  (rg + fzf-native gerektirir)
-- ============================================================================
return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  cmd = "Telescope",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make", -- C ile derlenen hızlı eşleştirici
    },
  },
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Dosya bul" },
    { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Metin ara (grep)" },
    { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Buffer'lar" },
    { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Yardım" },
    { "<leader>fr", "<cmd>Telescope oldfiles<CR>", desc = "Son dosyalar" },
    { "<leader>fw", "<cmd>Telescope grep_string<CR>", desc = "İmleçteki kelimeyi ara" },
    { "<leader>fd", "<cmd>Telescope diagnostics<CR>", desc = "Tanılar" },
    { "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>", desc = "Belge sembolleri" },
    { "<leader>fS", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", desc = "Proje sembolleri" },
    { "<leader>fk", "<cmd>Telescope keymaps<CR>", desc = "Tuş atamaları" },
    { "<leader><leader>", "<cmd>Telescope find_files<CR>", desc = "Dosya bul" },
  },
  config = function()
    local telescope = require("telescope")
    telescope.setup({
      defaults = {
        prompt_prefix = "  ",
        selection_caret = " ",
        path_display = { "truncate" },
        file_ignore_patterns = { "%.git/", "node_modules/", "%.o$", "%.obj$", "build/", "bin/", "obj/" },
        layout_config = { horizontal = { preview_width = 0.55 } },
        mappings = {
          i = {
            ["<C-j>"] = "move_selection_next",
            ["<C-k>"] = "move_selection_previous",
            ["<C-u>"] = false, -- prompt'u temizle
          },
        },
      },
      pickers = {
        find_files = { hidden = true },
      },
    })
    pcall(telescope.load_extension, "fzf")
  end,
}
