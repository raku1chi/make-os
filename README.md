# make-os

『【改訂新版】作って理解するOS x86系コンピュータを動かす理論と実装』（林高勲 著、川合秀実 監修、技術評論社）を Mac で読み進めながら動かしているコード。読んで試したことは、ブログ（https://raku1chi.dev）のシリーズ「『作って理解するOS』を読む」に書いている。

## Mac で動かす

本は Windows 向けに書かれていて、`env/` のバッチファイルで組み立てて起動する。このリポジトリには、同じことを Mac でするスクリプト（`env/mk.sh`・`env/boot.sh`）を足してある。

1. NASM と QEMU を入れる。Apple シリコンの Mac でも、QEMU が x86 の CPU をまねて動かすので設定は要らない

   ```sh
   brew install nasm qemu
   ```

2. クローンして `env/` にパスを通す（本の `env.bat` の代わり）。ターミナルを開き直すと使えるようになる

   ```sh
   git clone https://github.com/raku1chi/make-os ~/make-os
   echo 'export PATH="$HOME/make-os/env:$PATH"' >> ~/.zshrc
   ```

3. 節のフォルダで組み立てて起動する（本の `mk.bat`・`boot.bat` の代わり）

   ```sh
   cd ~/make-os/src/00_boot_only
   mk.sh && boot.sh
   ```

   QEMU のウィンドウが開いて「Booting from Hard Disk...」で止まれば、14.1 の「何もしない」ブートプログラムが動いている

`mk.sh` は、`kernel.s` があれば `boot.s` と一緒に組み立ててつなげ、なければ `boot.s` だけを組み立てる。`boot.sh` は `boot.img` を QEMU で起動する（後ろに書いた引数はそのまま QEMU に渡る）。

第 4 部（UEFI で起動する 64 ビット OS）は、本と同じく節のフォルダで `make` を打って組み立てる。起動のしかたは、第 4 部まで進んだら書き足す。

## 中身

| フォルダ | 中身 |
| :-- | :-- |
| `src/` | 本のサンプルコード。節ごとのフォルダ（第 3 部は `00_boot_only` から `46_acpi`、第 4 部は `50_crc` から `87_power_off`）と、各節が読み込む `include/`・`modules/`。第 4 部のイメージは `img/` にできる |
| `env/` | 組み立てと起動のスクリプト。`*.bat` と `bochsrc.bxrc` は本のもの（Windows 用）で、`mk.sh`・`boot.sh` はこのリポジトリで足した Mac 用 |

本のサンプルから変えたところ：

- `.s` のコメントを、Shift_JIS（Windows の CP932）から UTF-8 に直した。日本語はコメントの中にしかないので、組み立てたイメージは変わらない（第 3 部の 47 個すべてと第 4 部の `53_boot_only` で確かめた）
  - 変換するときは `SHIFT_JIS` ではなく `CP932` として読む。`SHIFT_JIS` として読むと、行の続きを表す `\` が `¥` に化けて組み立てられなくなる
- `env/mk.sh`・`env/boot.sh` を足した
- 配布の ZIP にある `tools/`（Windows 用の NASM や Rufus を置くための空のフォルダ）は入れていない

## 出典

サンプルコードは、本のサポートページ（https://gihyo.jp/book/2026/978-4-297-15921-4/support ）で配布されている `prog_20261005.zip` から。サポートページには、学習用であること、著作権は著者にあること、断りなく利用・改変・再配布してよいことが書かれている（本の P.16「本書に掲載しているコードについて」も参照）。
