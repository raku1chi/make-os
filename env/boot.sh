#!/bin/sh
# 本の env/boot.bat と同じ：boot.img を QEMU で起動する
# Mac では Zoom To Fit の状態で開き、ウィンドウを広げると画面も一緒に大きくなるようにする
# （後ろに書いた引数のほうが優先されるので、boot.sh -display none のように上書きもできる）
if [ "$(uname -s)" = Darwin ]; then
  set -- -display cocoa,zoom-to-fit=on "$@"
fi
exec qemu-system-x86_64 -rtc base=localtime -drive file=boot.img,format=raw -boot order=c "$@"
