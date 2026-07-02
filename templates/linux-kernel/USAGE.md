# Linux Kernel + Neovim (clangd) kullanımı

## 1) compile_commands.json üret
clangd'nin sembolleri çözmesi için gereklidir.

### Kernel ağacının kendisi (in-tree)
```bash
make defconfig            # veya: make menuconfig / olddefconfig
make -j"$(nproc)"         # önce derle (nesneler oluşmalı)
./scripts/clang-tools/gen_compile_commands.py
```
Bu, kök dizinde `compile_commands.json` oluşturur.

### Harici (out-of-tree) modül
```bash
# modül dizininde
make -C /lib/modules/$(uname -r)/build M=$(pwd) modules
# ardından kernel ağacındaki üreticiyi modül dizinine yönlendir:
/kernel/kaynak/scripts/clang-tools/gen_compile_commands.py -d $(pwd)
# veya bear kuruluysa:
bear -- make -C /lib/modules/$(uname -r)/build M=$(pwd) modules
```

## 2) .clangd dosyasını yerleştir
```bash
cp ~/.config/nvim/templates/linux-kernel/.clangd .
```
GCC'ye özgü bayrakları temizler; clangd hatasız çalışır.

## 3) Kod stili (kernel coding style)
- Kernel: **gerçek tab, genişlik 8, satır ~80 sütun**.
- Neovim'deki `vim-sleuth` eklentisi tab kullanan dosyalarda bunu otomatik
  algılar; ekstra ayar gerekmez.
- Biçimlendirme için kernel ağacındaki hazır `.clang-format` kullanılır
  (kök dizinde bulunur). `<leader>f` bu dosyayı otomatik dikkate alır.
- Stil denetimi: `./scripts/checkpatch.pl --file dosya.c`

## İpuçları
- `gd` / `gr` / `K` → tanıma git / referanslar / belgeleme.
- Büyük ağaçta ilk indeksleme uzun sürebilir; `:LspInfo` ile clangd durumunu gör.
- `compile_commands.json` yolu farklıysa `.clangd` içine
  `CompileFlags: { CompilationDatabase: yol/ }` ekleyebilirsin.
