-- ============================================================================
--  Treesitter: sözdizimi vurgulama, girinti, akıllı seçim
-- ============================================================================
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "c", "cpp", "c_sharp", "go", "gomod", "gosum", "gowork",
        "cmake", "make", "lua", "vim", "vimdoc", "query",
        "bash", "json", "yaml", "toml", "markdown", "markdown_inline",
        "printf", "diff", "gitcommit", "gitignore", "regex", "doxygen",
        -- Python + JS/TS (girinti/highlight için parser garanti olsun)
        "python", "javascript", "typescript", "tsx",
      },
      auto_install = true,
      highlight = { enable = true, additional_vim_regex_highlighting = false },
      -- C/C++ için treesitter indent kapalı: parantezleri yanlış girintiliyor.
      -- Bu diller için yerleşik cindent kullanılıyor (options.lua'daki autocmd).
      indent = { enable = true, disable = { "c", "cpp" } },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<CR>",
          node_incremental = "<CR>",
          node_decremental = "<BS>",
          scope_incremental = "<Tab>",
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
            ["ab"] = "@block.outer",
            ["ib"] = "@block.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
          goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
        },
      },
    })

    -- ------------------------------------------------------------------
    -- Neovim 0.12+ uyumluluk düzeltmesi (nvim-treesitter master ile)
    --
    -- Sorun: 0.11+/0.12'de query directive handler'larına gelen match[id]
    -- artık tek TSNode değil, node LİSTESİ. nvim-treesitter'ın
    -- `set-lang-from-info-string!` ve `downcase!` directive'leri bunu tek
    -- node sanıp `get_node_text`'e liste veriyor -> `table:range()` -> nil ->
    -- crash. Belirti: markdown'da DİL BELİRTİLEN kod bloğu (```python) açınca
    --   "attempt to call method 'range' (a nil value)" (highlighter).
    -- Çözüm: bu directive'leri, node'u listeden çıkaran sürümle override et.
    -- (Yukarı akış master'da düzelince kaldırılabilir.)
    -- ------------------------------------------------------------------
    require("nvim-treesitter.query_predicates")
    local Q = vim.treesitter.query
    local function pick(match, id)
      local m = match[id]
      if type(m) == "table" then return m[#m] end -- liste -> son node
      return m -- eski API: doğrudan TSNode (userdata)
    end
    local md_aliases = { ex = "elixir", pl = "perl", sh = "bash", uxn = "uxntal", ts = "typescript" }
    Q.add_directive("set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
      local node = pick(match, pred[2])
      if not node then return end
      local alias = vim.treesitter.get_node_text(node, bufnr):lower()
      local ft = vim.filetype.match({ filename = "a." .. alias })
      metadata["injection.language"] = ft or md_aliases[alias] or alias
    end, { force = true, all = false })
    Q.add_directive("downcase!", function(match, _, bufnr, pred, metadata)
      local id = pred[2]
      local node = pick(match, id)
      if not node then return end
      local text = vim.treesitter.get_node_text(node, bufnr, { metadata = metadata[id] }) or ""
      metadata[id] = metadata[id] or {}
      metadata[id].text = text:lower()
    end, { force = true, all = false })
  end,
}
