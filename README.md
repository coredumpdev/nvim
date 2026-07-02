# Neovim Yapılandırması

C / C++ / sistem programlama / Linux kernel / C# / Go geliştirme için
Catppuccin temalı, LSP tabanlı bir Neovim kurulumu.

## Ön koşullar (config'i kurmadan ÖNCE)

Bu yapılandırma; LSP sunucularını ve formatlayıcıları **Mason** ile otomatik
kurar, ama Mason'ın ve eklentilerin çalışması için aşağıdaki **sistem
paketleri** önceden kurulu olmalıdır. (Ubuntu/Debian komutları verilmiştir.)

### 1) Zorunlu çekirdek
```bash
sudo apt update
sudo apt install -y \
  neovim \            # >= 0.11 gerekir (yerel LSP API'si için)
  git curl unzip \    # lazy.nvim + Mason indirmeleri
  build-essential \   # gcc, g++, make -> treesitter & fzf-native derleme
  ripgrep \           # Telescope live_grep (ZORUNLU)
  xclip               # sistem panosu (Wayland'de: wl-clipboard)
```
> **Neovim sürümü:** apt'taki sürüm eskiyse resmi PPA veya
> [nvim.appimage](https://github.com/neovim/neovim/releases) kullanın (>= 0.11).

> **Nerd Font (ikonlar için):** neo-tree/lualine ikonlarının görünmesi için bir
> Nerd Font kurup **terminal yazı tipini** ona ayarlayın. Örn. JetBrainsMono:
> `~/.local/share/fonts/` altına açıp `fc-cache -f`, sonra terminalde
> "JetBrainsMono Nerd Font" seçin.

### 2) Dil araç zincirleri (kullandığınız dillere göre)
```bash
# C / C++ / sistem programlama       (build-essential yukarıda kuruldu)
sudo apt install -y gdb cmake pkg-config

# Go            -> gopls'in derlenmesi/çalışması için Go derleyicisi
sudo apt install -y golang-go
#   veya resmi: https://go.dev/dl  (ör. /usr/local/go, PATH'e go/bin ekleyin)

# C# (.NET)     -> omnisharp + csharpier
sudo apt install -y dotnet-sdk-10.0     # veya Microsoft paket deposundan

# Mason araçlarının bir kısmı için
sudo apt install -y python3 python3-pip nodejs npm
```

### 3) STM32 / ARM Cortex-M (gömülü geliştirme)
```bash
sudo apt install -y \
  gcc-arm-none-eabi \   # ARM çapraz derleyici
  gdb-multiarch \       # Cortex-M hata ayıklayıcı
  openocd               # flash + gdbserver (ST-Link)
#   openocd yoksa sudo'suz seçenek: xpack-openocd (bkz. STM32 bölümü)
```

### 4) Opsiyonel (tavsiye edilir)
```bash
sudo apt install -y \
  fd-find \   # Telescope find_files hızlandırma (ikili adı: fdfind)
  bear        # Make projelerinde compile_commands.json üretimi
```

### Mason'ın OTOMATİK kurduğu (apt ile uğraşmayın)
İlk `nvim` açılışında Mason şunları indirir:
`clangd`, `gopls`, `omnisharp`, `neocmakelsp`, `lua-language-server`,
`clang-format`, `gofumpt`, `goimports`, `csharpier`, `stylua`, `cpptools`.
Durumu `:Mason` ve `:checkhealth` ile görebilirsiniz.

> Not: `arm-none-eabi-gcc`, `gdb-multiarch`, `dotnet`, `go` gibi **çalıştırılabilir
> araçlar apt/sistemden gelir**; Mason yalnızca LSP/format araçlarını yönetir.

## Yapı

```
init.lua                 -> giriş noktası (leader tanımı + config modülleri)
lua/config/
  options.lua            -> editör ayarları, dile özel girinti, autocmd'ler
  keymaps.lua            -> genel tuş atamaları
  lazy.lua               -> lazy.nvim önyükleme + plugin içe aktarma
lua/plugins/
  catppuccin.lua         -> tema (mocha)
  lsp.lua                -> Mason + LSP sunucuları + LSP tuşları
  completion.lua         -> blink.cmp otomatik tamamlama + LuaSnip
  treesitter.lua         -> sözdizimi/girinti/akıllı seçim
  telescope.lua          -> bulanık dosya/metin arama
  formatting.lua         -> conform.nvim (kayıtta otomatik format)
  ui.lua                 -> neo-tree, lualine, bufferline, gitsigns, which-key
  editor.lua             -> autopairs, yorumlama, surround, todo-comments
```

## Diller ve araçları

| Dil / alan         | LSP          | Formatlayıcı        |
|--------------------|--------------|---------------------|
| C / C++ / sistem   | clangd       | clang-format        |
| Linux kernel (C)   | clangd       | clang-format        |
| C# (.NET 10)       | omnisharp    | csharpier           |
| Go                 | gopls        | gofumpt + goimports |
| CMake              | neocmake     | (LSP formatı)       |
| Make               | (treesitter) | —                   |
| Lua                | lua_ls       | stylua              |

LSP sunucuları ve formatlayıcılar **Mason** ile kullanıcı dizinine kurulur
(`:Mason` ile yönetilir). Go derleyicisi `~/.local/go`, PATH ve `GOPATH`
`~/.bashrc` içine eklenmiştir.

## Önemli tuşlar  (Leader = `<Space>`)

### Genel
| Tuş | İşlev |
|-----|-------|
| `<C-s>` | Kaydet (normal/insert/görsel) |
| `<Esc>` | Arama vurgusunu temizle |
| `<C-h/j/k/l>` | Pencereler arası geçiş |
| `<S-h>` / `<S-l>` | Önceki / sonraki buffer (özel pencerelerde etkisiz) |

### Pencere (`<leader>w`)
| Tuş | İşlev |
|-----|-------|
| `<leader>wc` | Pencereyi kapat |
| `<leader>wo` | Diğer pencereleri kapat |
| `<leader>wv` / `<leader>ws` | Dikey / yatay böl |
| `<leader>w=` | Pencereleri eşitle |
| `<leader>q` | Pencereyi kapat (kısa yol) |
| `<leader>Q` | Neovim'den çık (tümü) |

### Buffer (`<leader>b`)
| Tuş | İşlev |
|-----|-------|
| `<S-h>` / `<S-l>` | Önceki / sonraki buffer |
| `<leader>bd` | Buffer'ı kapat (pencere/nvim açık kalır) |
| `<leader>bo` | Diğer buffer'ları kapat |

### Arama (Telescope)
| Tuş | İşlev |
|-----|-------|
| `<leader>ff` | Dosya bul |
| `<leader>fg` | Metin ara (live grep) |
| `<leader>fb` | Açık buffer'lar |
| `<leader>fr` | Son dosyalar |
| `<leader>fw` | İmleçteki kelimeyi ara |
| `<leader>fs` | Belge sembolleri |

### LSP (bir dosya açıkken)
| Tuş | İşlev |
|-----|-------|
| `gd` / `gD` | Tanıma / bildirime git |
| `gr` | Referanslar |
| `gi` | Gerçeklemeye git |
| `K` | Belgeleme (hover) |
| `<leader>rn` | Yeniden adlandır |
| `<leader>ca` | Kod eylemi (code action) |
| `<leader>f` | Kodu formatla |
| `<leader>ih` | Inlay hints aç/kapa |
| `[d` / `]d` | Önceki / sonraki tanı (diagnostic) |

### Dosya ağacı / Git
| Tuş | İşlev |
|-----|-------|
| `<leader>t` | Dosya ağacını aç/kapa (neo-tree) |
| `]h` / `[h` | Sonraki / önceki git değişikliği |
| `<leader>hp` | Değişikliği önizle |

## C/C++ ve kernel için ipuçları

- **clangd**'nin sembolleri çözmesi için projede bir `compile_commands.json`
  olması gerekir:
  - CMake: `cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -B build` sonrasında
    `ln -s build/compile_commands.json .`
  - Make tabanlı projeler: [`bear`](https://github.com/rizsotto/Bear) ile
    `bear -- make`
  - Linux kernel: `make compile_commands.json` (kernel ağacında yerleşiktir).
- Proje köküne bir `.clang-format` koyarak kod stilini belirleyebilirsiniz
  (kernel için `.clang-format` kernel ağacında hazır gelir).

## STM32 / ARM Cortex-M geliştirme

### Kurulu araçlar
| Araç | Konum | Amaç |
|------|-------|------|
| `arm-none-eabi-gcc` | `/usr/bin` (apt) | Çapraz derleyici |
| `gdb-multiarch` | `/usr/bin` (apt) | Cortex-M hata ayıklayıcı |
| `openocd` | `~/.local/xpack-openocd` | Flash + gdbserver (ST-Link) |
| `clangd` | Mason | Kod tamamlama (embedded'e ayarlı) |
| cpptools (OpenDebugAD7) | Mason | nvim-dap gdb adaptörü |

### clangd'yi çalıştırmak (ÖNEMLİ)
clangd'nin STM32 HAL/CMSIS başlıklarını çözmesi için projede
`compile_commands.json` gerekir:
- **CMake** (STM32CubeMX artık CMake üretebilir):
  ```
  cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -B build
  ln -sf build/compile_commands.json .
  ```
- **Makefile** tabanlı CubeMX projeleri: `bear -- make`

Ekstra güvence için hazır bir `.clangd` şablonu:
```
cp ~/.config/nvim/templates/stm32/.clangd /proje/kökün/
```
(İçindeki `-mcpu`, `-mfpu` bayraklarını çipine göre düzenle.)

### Debug iş akışı (adım adım)
1. Projeyi derle → `build/<proje>.elf` üretilsin.
2. ST-Link'i tak, Neovim'de hedefi başlat:
   ```
   :OpenOCD           " listeden çip ailesini seç (ör. stm32f4x)
   :OpenOCD stm32f4x  " veya doğrudan belirt
   ```
3. `<F5>` → ELF yolunu gir (varsayılan `build/`). OpenOCD üzerinden çip
   flash'lanır, reset atılır ve `main`'de durur.
4. Hata ayıklama tuşları:

| Tuş | İşlev |
|-----|-------|
| `<F5>` | Başlat / devam et |
| `<F10>` / `<F11>` / `<F12>` | Adım geç / içine gir / dışına çık |
| `<leader>db` | Breakpoint aç/kapa |
| `<leader>dB` | Koşullu breakpoint |
| `<leader>du` | Debug UI (değişkenler, stack, breakpoint'ler) |
| `<leader>dr` | GDB REPL |
| `<leader>dt` | Oturumu sonlandır |

5. Bitince: `:OpenOCDStop`

### Sadece flash'lamak (debug'sız)
```
openocd -f interface/stlink.cfg -f target/stm32f4x.cfg \
  -c "program build/proje.elf verify reset exit"
```
(`~/.local/bin/openocd` PATH'te; scriptler otomatik bulunur.)

## Linux userspace C / C++ hata ayıklama (native debug)

Yerel (host) çalıştırılabilirler için `nvim-dap` + `cpptools` (gdb) kullanılır.
STM32'den farklı olarak OpenOCD gerekmez — program doğrudan gdb altında çalışır.

### Hazırlık: debug sembolleriyle derle
`-g` bayrağı (ve tercihen `-O0`) ile derleyin:
```bash
# Tek dosya
gcc -g -O0 program.c -o program
g++ -g -O0 program.cpp -o program
# CMake
cmake -DCMAKE_BUILD_TYPE=Debug -B build && cmake --build build
```

### İş akışı
1. `.c`/`.cpp` dosyasını aç.
2. `<leader>db` ile satırlara breakpoint koy.
3. `<F5>` → menüden yapılandırma seç:
   - **Native: çalıştırılabilir başlat (gdb)** → yol + argümanları sorar, çalıştırır.
   - **Native: çalışan sürece bağlan (attach)** → çalıştırılabilir + listeden PID seçtirir.
   - (STM32: OpenOCD ile debug → gömülü hedef için.)
4. Program breakpoint'te durur; UI otomatik açılır.

### Debug tuşları (STM32 ile ortak)
| Tuş | İşlev |
|-----|-------|
| `<F5>` | Başlat / devam |
| `<F10>` / `<F11>` / `<F12>` | Adım geç / içine gir / dışına çık |
| `<leader>db` / `<leader>dB` | Breakpoint / koşullu breakpoint |
| `<leader>dc` | İmlece kadar çalıştır |
| `<leader>du` | Debug UI (değişkenler, çağrı yığını, watch) |
| `<leader>dr` | GDB REPL |
| `<leader>dt` | Oturumu sonlandır |

> **Attach notu:** Ubuntu'da çocuk olmayan bir sürece bağlanmak `ptrace`
> kısıtlaması nedeniyle başarısız olabilir. Geçici çözüm:
> `sudo sysctl -w kernel.yama.ptrace_scope=0`

## Hex görüntüleyici (hex.nvim)

Binary dosyaları (ELF, `.bin`, `.o`, firmware, `.hex`...) hex olarak
görüntüle/düzenle. `xxd` tabanlıdır (sistemde kurulu).

| Tuş / Komut | İşlev |
|-------------|-------|
| `<leader>xx` / `:HexToggle` | Hex ↔ normal görünüm arası geçiş |
| `<leader>xd` / `:HexDump` | Tamponu hex'e çevir |
| `<leader>xa` / `:HexAssemble` | Hex'ten ikiliye geri çevir |

- `.bin .o .elf .out .a .so .hex .dat .img .dfu` uzantılı dosyalar açıldığında
  **otomatik** hex görünümüne geçer.
- Hex görünümünde düzenleme yapıp kaydedebilirsiniz (assemble ile geri yazılır).

## Proje şablonları (`templates/`)

Her dizin, ilgili proje türü için hazır clangd/format ayarları içerir.
Bir projeye başlarken ilgili dosyaları proje köküne kopyalayın.

| Şablon | İçerik | Kopyala |
|--------|--------|---------|
| `templates/stm32/` | `.clangd` (ARM Cortex-M) | `cp ~/.config/nvim/templates/stm32/.clangd .` |
| `templates/linux-kernel/` | `.clangd` (GCC bayrak temizliği) + `USAGE.md` | `cp ~/.config/nvim/templates/linux-kernel/.clangd .` |
| `templates/linux-c-cpp/` | `.clangd` + `.clang-format` + `USAGE.md` | `cp ~/.config/nvim/templates/linux-c-cpp/{.clangd,.clang-format} .` |

- **stm32**: `-mcpu/-mfpu` bayraklarını çipine göre düzenle.
- **linux-kernel**: clangd'nin anlamadığı GCC'ye özgü bayrakları temizler;
  `USAGE.md` içinde `compile_commands.json` üretimi anlatılır. Biçimlendirme
  kernel'in kendi `.clang-format`'ını kullanır (kernel ağacında hazır gelir).
- **linux-c-cpp**: userspace için tanı + inlay hint + LLVM tabanlı 4-boşluk stili.

Her şablonun `USAGE.md`'si adım adım kullanım içerir.

## Bakım

- `:Lazy`   -> eklentileri güncelle/incele
- `:Mason`  -> LSP sunucusu / formatlayıcı kur-kaldır
- `:checkhealth` -> kurulum sağlığını kontrol et
- `:TSUpdate` -> Treesitter parser'larını güncelle
