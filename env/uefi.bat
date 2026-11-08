@qemu-system-x86_64.exe -rtc base=localtime -drive file=..\img\boot.img,format=raw -boot order=c -bios ..\..\tools\OVMF-X64-r15214\OVMF.fd
