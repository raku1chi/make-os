#!/bin/sh
# 本の env/box.bat と同じ：boot.img を Bochs で起動する（設定は Mac 用の env/bochsrc-mac.bxrc）
# -dbg でデバッガを使う（本と同じ）。起動するとすぐに動き出し（env/cmd-mac.init の c）、
# ターミナルで Ctrl+C を押すと止まってデバッガのコマンドを打てる
env_dir=$(cd "$(dirname "$0")" && pwd)
exec bochs -dbg -q -f "$env_dir/bochsrc-mac.bxrc" -rc "$env_dir/cmd-mac.init" "$@"
