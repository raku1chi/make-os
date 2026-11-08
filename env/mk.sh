#!/bin/sh
# 本の env/mk.bat と同じ：kernel.s があれば boot と kernel を組み立ててつなげ、なければ boot.s だけを組み立てる
set -e
if [ -f kernel.s ]; then
  nasm boot.s -o boot.bin -l boot.lst
  nasm kernel.s -o kernel.bin -l kernel.lst
  cat boot.bin kernel.bin > boot.img
else
  nasm boot.s -o boot.img -l boot.lst
fi
