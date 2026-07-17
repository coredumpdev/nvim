-- ============================================================================
--  LSP: Mason (araç kurulumu) + nvim-lspconfig + nvim 0.11 yerel LSP API'si
--  Diller: C, C++, C# (sistem prog. dahil), Go, CMake, Lua
-- ============================================================================
return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "mason-org/mason.nvim", opts = { ui = { border = "rounded" } } },
      "mason-org/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "saghen/blink.cmp", -- tamamlama yetenekleri için
    },
    config = function()
      -- ------------------------------------------------------------------
      -- Mason ile kurulacak araçlar (LSP sunucuları + formatlayıcılar)
      -- Kullanıcı dizinine kurulur, sudo gerekmez.
      -- ------------------------------------------------------------------
      require("mason-tool-installer").setup({
        ensure_installed = {
          -- LSP sunucuları
          "clangd",          -- C / C++ / sistem programlama / Linux kernel
          "gopls",           -- Go
          "omnisharp",       -- C# (.NET)
          "neocmake",        -- CMake  (neocmakelsp)
          "lua-language-server",
          -- Formatlayıcılar / araçlar
          "clang-format",    -- C / C++
          "gofumpt",         -- Go (katı gofmt)
          "goimports",       -- Go import düzenleme
          "csharpier",       -- C#
          "stylua",          -- Lua
        },
        run_on_start = true,
      })

      -- ------------------------------------------------------------------
      -- Tamamlama yetenekleri (blink.cmp) her sunucuya uygulanır
      -- ------------------------------------------------------------------
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      vim.lsp.config("*", { capabilities = capabilities })

      -- ------------------------------------------------------------------
      -- Sunucuya özel yapılandırmalar (nvim-lspconfig varsayılanlarıyla birleşir)
      -- ------------------------------------------------------------------
      vim.lsp.config("clangd", {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--fallback-style=llvm",
          -- Embedded/STM32: clangd'nin çapraz-derleyicinin (arm-none-eabi-gcc)
          -- sistem başlıklarını ve hedef tanımlarını çıkarmasına izin ver
          "--query-driver=/usr/bin/arm-none-eabi-*,/usr/bin/gcc,/usr/bin/g++,/usr/bin/clang*",
        },
        init_options = {
          usePlaceholders = true,
          completeUnimported = true,
          clangdFileStatus = true,
        },
      })

      vim.lsp.config("gopls", {
        settings = {
          gopls = {
            gofumpt = true,
            usePlaceholders = true,
            completeUnimported = true,
            staticcheck = true,
            analyses = {
              unusedparams = true,
              nilness = true,
              unusedwrite = true,
              useany = true,
            },
            hints = {
              parameterNames = true,
              assignVariableTypes = true,
              constantValues = true,
              rangeVariableTypes = true,
              compositeLiteralTypes = true,
            },
          },
        },
      })

      vim.lsp.config("omnisharp", {
        settings = {
          FormattingOptions = { EnableEditorConfigSupport = true, OrganizeImports = true },
          RoslynExtensionsOptions = {
            EnableAnalyzersSupport = true,
            EnableImportCompletion = true,
            AnalyzeOpenDocumentsOnly = false,
          },
          Sdk = { IncludePrereleases = true },
        },
      })

      -- qmlls: Qt ile birlikte gelir (Mason'da yok). En yüksek Qt sürümünün
      -- binary'sini otomatik bul. Build dizinindeki .qmltypes'ları görmesi için
      -- projede QT_QML_GENERATE_QMLLS_INI ON olmalı (üretilen .qmlls.ini'yi okur).
      local function find_qmlls()
        local candidates = vim.fn.glob(vim.fn.expand("~/Qt") .. "/*/gcc_64/bin/qmlls", true, true)
        -- Sürüm-farkındalıklı sıralama: 6.11.1 > 6.9.3 (leksikografik değil, sayısal)
        local function ver(path)
          local s = path:match("/Qt/([%d%.]+)/") or "0"
          local t = {}
          for n in s:gmatch("%d+") do
            t[#t + 1] = tonumber(n)
          end
          return t
        end
        table.sort(candidates, function(a, b)
          local va, vb = ver(a), ver(b)
          for i = 1, math.max(#va, #vb) do
            local x, y = va[i] or 0, vb[i] or 0
            if x ~= y then
              return x < y
            end
          end
          return false
        end)
        return candidates[#candidates] or "qmlls"
      end

      vim.lsp.config("qmlls", {
        cmd = { find_qmlls() },
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } }, -- 'vim' global uyarısını kapat
            workspace = { checkThirdParty = false, library = vim.api.nvim_get_runtime_file("", true) },
            telemetry = { enable = false },
          },
        },
      })

      -- ------------------------------------------------------------------
      -- Sunucuları etkinleştir (nvim-lspconfig'in taşıdığı tanımları kullanır)
      -- ------------------------------------------------------------------
      vim.lsp.enable({ "clangd", "gopls", "omnisharp", "neocmake", "lua_ls", "qmlls" })

      -- ------------------------------------------------------------------
      -- LSP bir tampona bağlandığında geçerli olan tuş atamaları
      -- ------------------------------------------------------------------
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
        callback = function(ev)
          local buf = ev.buf
          local function m(keys, fn, desc, mode)
            vim.keymap.set(mode or "n", keys, fn, { buffer = buf, desc = "LSP: " .. desc })
          end

          m("gd", vim.lsp.buf.definition, "Tanıma git")
          m("gD", vim.lsp.buf.declaration, "Bildirime git")
          m("gr", vim.lsp.buf.references, "Referanslar")
          m("gi", vim.lsp.buf.implementation, "Gerçeklemeye git")
          m("gy", vim.lsp.buf.type_definition, "Tür tanımına git")
          m("K", vim.lsp.buf.hover, "Belgeleme (hover)")
          m("<C-k>", vim.lsp.buf.signature_help, "İmza yardımı", "i")
          m("<leader>rn", vim.lsp.buf.rename, "Yeniden adlandır")
          m("<leader>ca", vim.lsp.buf.code_action, "Kod eylemi", { "n", "v" })
          m("<leader>D", vim.lsp.buf.type_definition, "Tür tanımı")

          -- Inlay hints (ipuçları) aç/kapa — nvim 0.11 destekli
          if vim.lsp.inlay_hint then
            m("<leader>ih", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
            end, "Inlay hints aç/kapa")
          end
        end,
      })
    end,
  },
}
