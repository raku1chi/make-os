INCLUDE_FILES=../include/uefi/gpt_inc.s \
              ../include/uefi/fat32_inc.s

SRC_FILES=fat32_partition.s \
          fat32_bpb.s \
          fat32_fsinfo.s

fat32_partition.bin : $(SRC_FILES) $(INCLUDE_FILES)

%.bin: %.s
	nasm $< -o $@ -l $*.lst

clean:
	del *.bin > nul 2>&1
	del *.lst > nul 2>&1
	del *.img > nul 2>&1
