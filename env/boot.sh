#!/bin/sh
# 本の env/boot.bat と同じ：boot.img を QEMU で起動する
exec qemu-system-x86_64 -rtc base=localtime -drive file=boot.img,format=raw -boot order=c "$@"
