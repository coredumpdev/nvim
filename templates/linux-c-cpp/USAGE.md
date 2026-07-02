# Linux userspace C / C++ + Neovim kullanımı

## 1) compile_commands.json üret
clangd'nin başlıkları/sembolleri tam çözmesi için gereklidir.

| Yapı sistemi | Komut |
|--------------|-------|
| CMake | `cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -B build` |
| Make  | `bear -- make` |
| Meson | build dizininde otomatik oluşur |

Sonra kök dizine bağla:
```bash
ln -sf build/compile_commands.json .
```

## 2) Şablon dosyalarını yerleştir
```bash
cp ~/.config/nvim/templates/linux-c-cpp/.clangd .
cp ~/.config/nvim/templates/linux-c-cpp/.clang-format .   # istersen
```
- `.clangd` → tanı/inlay hint ayarları (compile_commands yoksa standart bayrağı aç).
- `.clang-format` → `<leader>f` ile biçimlendirme stili (LLVM tabanlı, 4 boşluk).

## 3) Faydalı kısayollar
| Tuş | İşlev |
|-----|-------|
| `gd` / `gr` / `gi` | Tanıma / referanslara / gerçeklemeye git |
| `K` | Belgeleme (hover) |
| `<leader>ca` / `<leader>rn` | Kod eylemi / yeniden adlandır |
| `<leader>f` | clang-format ile biçimlendir |
| `<leader>ih` | Inlay hints aç/kapa |
| `<leader>fg` | Projede metin ara (live grep) |

## Notlar
- Derleyici bayrakları compile_commands.json'dan gelir; `.clangd` yalnızca
  ek tanı/uyarı ayarı yapar.
- Standart kütüphane başlıkları için sistemde `gcc`/`g++` yeterlidir (kurulu).
- Bellek hatalarını yakalamak için: `clang-analyzer-*` denetimleri `.clangd`'de açık.
