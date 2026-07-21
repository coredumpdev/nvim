-- ============================================================================
--  Hata ayıklama (Debug): nvim-dap + dap-ui
--  C/C++: STM32 (OpenOCD) + native gdb · Node.js/JS/TS: js-debug-adapter
--
--  Kullanım:
--    1) Projeyi derle (build/<proje>.elf üretilsin)
--    2) :OpenOCD  -> hedef seç (ör. stm32f4x) ve ST-Link'i bağla
--    3) <F5>      -> ELF yolunu gir, debug başlasın (breakpoint, adım adım...)
--    4) :OpenOCDStop -> OpenOCD'yi kapat
-- ============================================================================
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
      "theHamsta/nvim-dap-virtual-text", -- değişken değerlerini satır içinde göster
    },
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "Debug: Başlat/Devam" },
      { "<F10>", function() require("dap").step_over() end, desc = "Debug: Adım geç (over)" },
      { "<F11>", function() require("dap").step_into() end, desc = "Debug: İçine gir (into)" },
      { "<F12>", function() require("dap").step_out() end, desc = "Debug: Dışına çık (out)" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Debug: Breakpoint aç/kapa" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Koşul: ")) end, desc = "Debug: Koşullu breakpoint" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Debug: REPL" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Debug: UI aç/kapa" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Debug: Sonlandır" },
      { "<leader>dc", function() require("dap").run_to_cursor() end, desc = "Debug: İmlece kadar çalıştır" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- OpenOCD betik dizini (xpack kurulumu)
      local openocd_scripts = vim.fn.expand("~/.local/xpack-openocd/openocd/scripts")

      -- ------------------------------------------------------------------
      -- DAP UI ve sanal metin
      -- ------------------------------------------------------------------
      dapui.setup()
      require("nvim-dap-virtual-text").setup({ commented = true })

      -- Oturum açıldığında UI'yı otomatik aç/kapat
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      -- Breakpoint işaretleri
      vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticError", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "", texthl = "DiagnosticWarn", linehl = "Visual", numhl = "" })

      -- ------------------------------------------------------------------
      -- cpptools (OpenDebugAD7) adaptörü
      -- ------------------------------------------------------------------
      local mason = vim.fn.stdpath("data") .. "/mason"
      dap.adapters.cppdbg = {
        id = "cppdbg",
        type = "executable",
        command = mason .. "/bin/OpenDebugAD7",
      }

      -- ------------------------------------------------------------------
      -- STM32 / Cortex-M launch yapılandırması
      -- OpenOCD localhost:3333'te gdbserver sağlar; gdb-multiarch bağlanır.
      -- ------------------------------------------------------------------
      local stm32 = {
        name = "STM32: OpenOCD ile debug (:3333)",
        type = "cppdbg",
        request = "launch",
        MIMode = "gdb",
        miDebuggerPath = "gdb-multiarch",
        miDebuggerServerAddress = "localhost:3333",
        cwd = "${workspaceFolder}",
        externalConsole = false,
        -- Derlenmiş ELF dosyasını sor (build/ altında ara)
        program = function()
          return vim.fn.input("ELF yolu: ", vim.fn.getcwd() .. "/build/", "file")
        end,
        setupCommands = {
          { text = "-enable-pretty-printing", description = "pretty print", ignoreFailures = true },
          { text = "set mem inaccessible-by-default off", ignoreFailures = true },
        },
        -- Bağlanınca çipi resetle & flash'la, main'de dur
        customLaunchSetupCommands = {
          { text = "-target-select extended-remote localhost:3333", ignoreFailures = false },
          { text = "monitor reset halt", ignoreFailures = true },
          { text = "load", description = "Flash", ignoreFailures = false },
          { text = "monitor reset halt", ignoreFailures = true },
        },
        launchCompleteCommand = "exec-continue",
      }

      -- ------------------------------------------------------------------
      -- Native Linux userspace (host) debug — gdb ile yerel çalıştır/bağlan
      -- ------------------------------------------------------------------
      local native_launch = {
        name = "Native: çalıştırılabilir başlat (gdb)",
        type = "cppdbg",
        request = "launch",
        MIMode = "gdb",
        miDebuggerPath = "gdb",
        cwd = "${workspaceFolder}",
        externalConsole = false,
        stopAtEntry = false,
        program = function()
          return vim.fn.input("Çalıştırılabilir yolu: ", vim.fn.getcwd() .. "/", "file")
        end,
        args = function()
          local raw = vim.fn.input("Argümanlar (boşlukla ayır): ")
          return vim.split(raw, " ", { trimempty = true })
        end,
        setupCommands = {
          { text = "-enable-pretty-printing", ignoreFailures = true },
        },
      }

      local native_attach = {
        name = "Native: çalışan sürece bağlan (attach)",
        type = "cppdbg",
        request = "attach",
        MIMode = "gdb",
        miDebuggerPath = "gdb",
        cwd = "${workspaceFolder}",
        program = function()
          return vim.fn.input("Çalıştırılabilir yolu (semboller için): ", vim.fn.getcwd() .. "/", "file")
        end,
        processId = require("dap.utils").pick_process, -- listeden PID seç
        setupCommands = {
          { text = "-enable-pretty-printing", ignoreFailures = true },
        },
      }

      -- <F5> basınca bu listeden seçim menüsü çıkar
      dap.configurations.c = { native_launch, native_attach, stm32 }
      dap.configurations.cpp = { native_launch, native_attach, stm32 }

      -- ------------------------------------------------------------------
      -- Node.js / JavaScript / TypeScript (Mason: js-debug-adapter)
      -- pwa-node: vscode-js-debug'un DAP sunucusu. TS dosyalarını doğrudan
      -- çalıştırmak için projede "tsx" ya da "ts-node" gerekir (aşağıda tsx ile).
      -- ------------------------------------------------------------------
      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = { mason .. "/packages/js-debug-adapter/js-debug/src/dapDebugServer.js", "${port}" },
        },
      }

      local js_config = {
        {
          type = "pwa-node",
          request = "launch",
          name = "Node: bu dosyayı çalıştır",
          program = "${file}",
          cwd = "${workspaceFolder}",
          sourceMaps = true,
        },
        {
          type = "pwa-node",
          request = "launch",
          name = "TS: bu dosyayı çalıştır (tsx)",
          runtimeExecutable = "tsx", -- npm i -g tsx  (ya da proje devDependency)
          program = "${file}",
          cwd = "${workspaceFolder}",
          sourceMaps = true,
        },
        {
          type = "pwa-node",
          request = "attach",
          name = "Node: çalışan sürece bağlan",
          processId = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
          sourceMaps = true,
        },
      }
      for _, lang in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
        dap.configurations[lang] = js_config
      end

      -- ------------------------------------------------------------------
      -- OpenOCD'yi Neovim içinden başlat/durdur
      -- ------------------------------------------------------------------
      local openocd_job = nil
      -- Yaygın Cortex-M hedefleri (kendininkini "Diğer" ile girebilirsin)
      local targets = {
        "stm32f0x", "stm32f1x", "stm32f2x", "stm32f3x", "stm32f4x",
        "stm32f7x", "stm32g0x", "stm32g4x", "stm32h7x", "stm32l0",
        "stm32l1", "stm32l4x", "stm32wbx", "stm32wlx",
      }

      local function start_openocd(target)
        if openocd_job then
          vim.notify("OpenOCD zaten çalışıyor (:OpenOCDStop ile durdur)", vim.log.levels.WARN)
          return
        end
        local cmd = {
          "openocd",
          "-s", openocd_scripts,
          "-f", "interface/stlink.cfg",
          "-f", "target/" .. target .. ".cfg",
        }
        openocd_job = vim.fn.jobstart(cmd, {
          on_stderr = function(_, data)
            if data and #table.concat(data) > 0 then
              vim.schedule(function() vim.notify(table.concat(data, "\n"), vim.log.levels.INFO, { title = "OpenOCD" }) end)
            end
          end,
          on_exit = function()
            openocd_job = nil
            vim.schedule(function() vim.notify("OpenOCD durdu", vim.log.levels.WARN) end)
          end,
        })
        vim.notify("OpenOCD başlatıldı → target/" .. target .. " (:3333)", vim.log.levels.INFO)
      end

      vim.api.nvim_create_user_command("OpenOCD", function(opts)
        if opts.args ~= "" then
          start_openocd(opts.args)
        else
          vim.ui.select(targets, { prompt = "STM32 hedefi seç:" }, function(choice)
            if choice then start_openocd(choice) end
          end)
        end
      end, { nargs = "?", complete = function() return targets end, desc = "OpenOCD gdbserver başlat" })

      vim.api.nvim_create_user_command("OpenOCDStop", function()
        if openocd_job then
          vim.fn.jobstop(openocd_job)
          openocd_job = nil
        else
          vim.notify("OpenOCD çalışmıyor", vim.log.levels.WARN)
        end
      end, { desc = "OpenOCD'yi durdur" })
    end,
  },
}
