KERNEL_INCLUDE=../include/uefi/type_inc.s \
               ../include/uefi/pe_inc.s \
               ../include/uefi/uefi_inc.s \
               ../include/uefi/xcall_inc.s \
               ../include/uefi/frame_inc.s \
               ../include/uefi/apic_inc.s \
               ../include/uefi/app_inc.s \
               ../include/uefi/kernel_inc.s \
               ../include/uefi/task_inc.s \
               ../include/uefi/syscall_inc.s

KERNEL_SRC=bootx64.s \
           uefi_main.s \
           ../modules/uefi/puts.s \
           ../modules/uefi/itoa.s \
           ../modules/uefi/htoa.s \
           ../modules/uefi/read_key.s \
           ../modules/uefi/reset.s \
           ../modules/uefi/allocate_pool.s \
           ../modules/uefi/memory_map.s \
           ../modules/uefi/get_protocol.s \
           ../modules/uefi/get_font.s \
           ../modules/uefi/put_glyph.s \
           ../modules/uefi/put_gop_mode.s \
           ../modules/uefi/get_gop_mode.s \
           ../modules/uefi/put_gop_info.s \
           ../modules/uefi/get_gop_info.s \
           ../modules/uefi/draw_pixel.s \
           ../modules/uefi/draw_line.s \
           ../modules/uefi/draw_rect.s \
           ../modules/uefi/fill_rect.s \
           ../modules/uefi/get_font_image.s \
           ../modules/uefi/get_font_pixel.s \
           ../modules/uefi/draw_char.s \
           ../modules/uefi/draw_str.s \
           ../modules/uefi/get_time.s \
           ../modules/uefi/scan_key.s \
           ../modules/uefi/query_gop_info.s \
           ../modules/uefi/set_gop_mode.s \
           ../modules/uefi/exit_boot_service.s \
           ../modules/uefi/init_gdt.s \
           ../modules/uefi/int_stop.s \
           ../modules/uefi/init_idt.s \
           ../modules/uefi/init_apic.s \
           ../modules/uefi/draw_frame.s \
           ../modules/uefi/draw_time.s \
           ../modules/uefi/init_pic.s \
           ../modules/uefi/int_keyboard.s \
           ../modules/uefi/ring_buff.s \
           ../modules/uefi/draw_key.s \
           ../modules/uefi/init_tss.s \
           ../modules/uefi/memcpy.s \
           ../modules/uefi/init_page_default.s \
           ../modules/uefi/init_page_user.s \
           ../modules/uefi/init_syscall.s \
           ../modules/uefi/int_syscall.s \
           ../modules/uefi/int_nm.s \
           ../modules/uefi/sin.s \
           ../modules/uefi/init_sse.s \
           ../modules/uefi/init_draw_area.s \
           modules/int_timer.s \
           modules/init_task.s \
           tasks/task_proc.s \
           stage_1.s \
           stage_2.s \
           stage_3.s \
           stage_4.s \
           stage_5.s \
           stage_6.s \
           stage_7.s \
           stage_8.s \
           stage_9.s \
           stage_10.s \
           stage_11.s \
           stage_12.s

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
