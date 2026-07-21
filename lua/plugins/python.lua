-- ============================================================================
--  Python: ortam seçici (conda) + hata ayıklama (debugpy)
--
--  Kullanım:
--    :VenvSelect  (<leader>vs) -> conda ortamını / .venv'i seç
--        - Seçilen ortam basedpyright + ruff'a ve debug'a otomatik uygulanır
--    <F5>                       -> Python dosyasında debug başlat (debugpy)
--
--  Not: base dahil tüm conda ortamları $CONDA_PREFIX üzerinden otomatik bulunur.
--       (~/miniconda3/envs/*). fd gerektirir (kurulu).
-- ============================================================================
return {
  -- --------------------------------------------------------------------------
  -- Python debug adaptörü (nvim-dap-python + Mason'daki debugpy)
  -- --------------------------------------------------------------------------
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      -- Mason ile kurulan debugpy'nin kendi venv python'u (kutudan çıkar çıkmaz
      -- çalışır). Bir conda ortamı seçilince venv-selector bunu o ortamın
      -- python'una çevirir — o ortamda debugpy kurulu olmalı (conda install debugpy).
      local debugpy_python = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      require("dap-python").setup(debugpy_python)

      -- Python için kullanışlı debug tuşları (nvim-dap'in genel <F5> vb. ile uyumlu)
      vim.keymap.set("n", "<leader>dn", function() require("dap-python").test_method() end,
        { desc = "Debug: Python test metodu" })
      vim.keymap.set("n", "<leader>df", function() require("dap-python").test_class() end,
        { desc = "Debug: Python test sınıfı" })
    end,
  },

  -- --------------------------------------------------------------------------
  -- Ortam seçici: conda ortamlarını ve .venv'leri bulur, LSP + debug'a uygular
  -- --------------------------------------------------------------------------
  {
    "linux-cultist/venv-selector.nvim",
    -- Yeni sürüm `main` dalında (conda/anaconda otomatik algılar, fd kullanır)
    ft = "python",
    dependencies = {
      "neovim/nvim-lspconfig",
      "mfussenegger/nvim-dap-python",
      { "nvim-telescope/telescope.nvim", branch = "0.1.x" },
    },
    keys = {
      { "<leader>vs", "<cmd>VenvSelect<cr>", desc = "Python: ortam (conda/venv) seç" },
    },
    opts = {
      settings = {
        options = {
          -- Ortam seçilince bildir ve debug'ı (dap-python) da o python'a bağla
          notify_user_on_venv_activation = true,
          dap_enabled = true,
        },
      },
    },
  },
}
