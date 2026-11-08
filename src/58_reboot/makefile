KERNEL_INCLUDE=../include/uefi/type_inc.s \
               ../include/uefi/pe_inc.s \
               ../include/uefi/uefi_inc.s \
               ../include/uefi/xcall_inc.s \
               ../include/uefi/frame_inc.s

KERNEL_SRC=bootx64.s \
           uefi_main.s \
           ../modules/uefi/puts.s \
           ../modules/uefi/itoa.s \
           ../modules/uefi/htoa.s \
           ../modules/uefi/read_key.s \
           ../modules/uefi/reset.s

BOOT_INCLUDE=../include/uefi/gpt_inc.s

BOOT_SRC=boot.s bootx64.efi \
         ../52_fat32/fat32_partition.bin \
         ../51_gpt/gpt_disk.bin

.PHONY: all clean

all: gpt_image fat32_image ../img/boot.img 

gpt_image:
	@$(MAKE) -s -C ../51_gpt

fat32_image:
	@$(MAKE) -s -C ../52_fat32

../img/boot.img: $(BOOT_SRC) $(BOOT_INCLUDE)
	nasm boot.s -o ../img/boot.img

bootx64.efi: $(KERNEL_SRC) $(KERNEL_INCLUDE)
	nasm $< -o $@ -l bootx64.lst

clean:
	del *.bin > nul 2>&1
	del *.lst > nul 2>&1
	del *.img > nul 2>&1
	del *.efi > nul 2>&1
