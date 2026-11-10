# make-os

『【改訂新版】作って理解するOS x86系コンピュータを動かす理論と実装』（林高勲 著、川合秀実 監修、技術評論社）を Mac で読み進めながら動かしているコード。読んで試したことは、ブログ（https://raku1chi.dev）のシリーズ「『作って理解するOS』を読む」に書いている。

## Mac で動かす

本は Windows 向けに書かれていて、`env/` のバッチファイルで組み立てて起動する。このリポジトリには、同じことを Mac でするスクリプト（`env/mk.sh`・`env/boot.sh`・`env/box.sh`）を足してある。

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

   QEMU のウィンドウは、Retina の画面だととても小さく開く。`boot.sh` は Mac では Zoom To Fit の状態で開くので、ウィンドウの端をドラッグして広げると画面も一緒に大きくなる。メニューの Zoom Interpolation はオフのままにしておくと、ドットがにじまずくっきり見える

`mk.sh` は、`kernel.s` があれば `boot.s` と一緒に組み立ててつなげ、なければ `boot.s` だけを組み立てる。`boot.sh` は `boot.img` を QEMU で起動する。Mac では `-display cocoa,zoom-to-fit=on` を付ける。後ろに書いた引数はそのまま QEMU に渡り、`-display` は後ろに書いたほうが使われるので、`boot.sh -display none` のように上書きもできる。

第 4 部（UEFI で起動する 64 ビット OS）は、本と同じく節のフォルダで `make` を打って組み立てる。起動のしかたは、第 4 部まで進んだら書き足す。

## Bochs で動かす

本では、QEMU のほかに Bochs でも動作を確かめる（12.7、付録 A.2）。Bochs は QEMU より遅いが、デバッガが組み込まれていて、1 命令ずつ止めながらレジスタやメモリを見られる。

1. Bochs を入れる。Homebrew の Bochs（3.1）はデバッガ付きで、Mac のウィンドウ（SDL2）に画面を出す

   ```sh
   brew install bochs
   ```

2. 節のフォルダで組み立てて、Bochs で起動する（本の `box.bat` の代わり）

   ```sh
   cd ~/make-os/src/00_boot_only
   mk.sh && box.sh
   ```

   起動するとすぐに動き出す（本と同じく、デバッガに最初に `c` を渡している）。ターミナルで Ctrl+C を押すと止まり、`<bochs:2>` のようにデバッガのコマンドを待つ

| コマンド | すること |
| :-- | :-- |
| `r` | レジスタを見る（14.1 なら `rip` が `0x7c00`） |
| `x /16xb 0x7c00` | メモリの `0x7C00` から 16 バイトを見る |
| `s` | 1 命令だけ進める |
| `lb 0x7c00` | 次にその番地に来たら止める |
| `c` | 続きを動かす |
| `q` | Bochs を終える |

- 起動すると `ata0-0: specified geometry doesn't fit on disk image` という PANIC が出るが、気にしなくてよい。本の設定がディスクを 320KB の形と決めているのに、`boot.img` がそれより小さいために出るもので、知らせるだけで先へ進む（本の設定の `panic: action=report`）
- Bochs が途中で落ちると、次に起動したとき `image locked` と言って止まることがある。`boot.img.lock` を消すか、`box.sh -unlock` で起動する

`box.sh` は、本の `bochsrc.bxrc`・`cmd.init` を Mac で使えるようにした `env/bochsrc-mac.bxrc`・`env/cmd-mac.init` を読む。本の設定から変えたのは次のところで、理由は `env/bochsrc-mac.bxrc` の先頭にも書いてある。

- 画面の方式（`config_interface`・`display_library`）を Mac で使えるもの（`textconfig`・`sdl2`）にした
- BIOS（`romimage`・`vgaromimage`）を、`C:\Program Files\…` ではなく Bochs に付いているもの（`$BXSHARE`）から読む
- Homebrew の Bochs に入っていない部品（`plugin_ctrl` の `voodoo`・`gameport`・`ne2k`・`sb16` など）、音（`sound`、`speaker` の音量）、USB のデバッガ（`usb_debug`）は書かない。書くと起動しない
- `debugger_log` を、Bochs 3.1 での名前の `debugger: log=` にした
- `cmd.init` は Windows の改行（CRLF）のままだと Mac の Bochs が読めず、すぐ終わってしまうので、改行を LF にした `cmd-mac.init` を使う

## 中身

| フォルダ | 中身 |
| :-- | :-- |
| `src/` | 本のサンプルコード。節ごとのフォルダ（第 3 部は `00_boot_only` から `46_acpi`、第 4 部は `50_crc` から `87_power_off`）と、各節が読み込む `include/`・`modules/`。第 4 部のイメージは `img/` にできる |
| `env/` | 組み立てと起動のスクリプトと設定。`*.bat`・`bochsrc.bxrc`・`cmd.init` は本のもの（Windows 用）で、`mk.sh`・`boot.sh`・`box.sh`・`bochsrc-mac.bxrc`・`cmd-mac.init` はこのリポジトリで足した Mac 用 |

本のサンプルから変えたところ：

- `.s` のコメントを、Shift_JIS（Windows の CP932）から UTF-8 に直した。日本語はコメントの中にしかないので、組み立てたイメージは変わらない（第 3 部の 47 個すべてと第 4 部の `53_boot_only` で確かめた）
  - 変換するときは `SHIFT_JIS` ではなく `CP932` として読む。`SHIFT_JIS` として読むと、行の続きを表す `\` が `¥` に化けて組み立てられなくなる
- `env/mk.sh`・`env/boot.sh`・`env/box.sh` と、Bochs の Mac 用の設定（`env/bochsrc-mac.bxrc`・`env/cmd-mac.init`）を足した
- 配布の ZIP にある `tools/`（Windows 用の NASM や Rufus を置くための空のフォルダ）は入れていない

## 出典

サンプルコードは、本のサポートページ（https://gihyo.jp/book/2026/978-4-297-15921-4/support ）で配布されている `prog_20261005.zip` から。サポートページには、学習用であること、著作権は著者にあること、断りなく利用・改変・再配布してよいことが書かれている（本の P.16「本書に掲載しているコードについて」も参照）。
