INCLUDE_FILES=../include/uefi/gpt_inc.s \
	          ../include/uefi/guid_inc.s

SRC_FILES=gpt_disk.s \
          gpt_protective_mbr.s \
          gpt_primary_header.s \
          gpt_primary_entry.s \
          gpt_partition.s \
          gpt_backup_entry.s \
          gpt_backup_header.s

gpt_disk.bin : $(SRC_FILES) $(INCLUDE_FILES)

%.bin: %.s
	nasm $< -o $@ -l $*.lst

clean:
	del *.bin > nul 2>&1
	del *.lst > nul 2>&1
	del *.img > nul 2>&1
