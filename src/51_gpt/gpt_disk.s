;************************************************************************
;	インクルードファイル
;************************************************************************
%include	"../include/uefi/gpt_inc.s"
%include	"../include/uefi/guid_inc.s"

		PARTITION_ENTRY_CRC		equ		0xD9A6074A
		PRIMARY_HEADER_CRC		equ		0x6FACC1D4
		BACKUP_HEADER_CRC		equ		0xEB1FC4D0

;************************************************************************
;	GPTディスクイメージ
;************************************************************************
%include	"gpt_protective_mbr.s"				; LBA         0 : Protective MBR
%include	"gpt_primary_header.s"				; LBA         1 : Primary GPT Header
%include	"gpt_primary_entry.s"				; LBA         2 : Primary GPT Partition Entry
												; ...           : 
%include	"gpt_partition.s"					; LBA        64 : Partition Area(FAT32)
												; ...           : 
%include	"gpt_backup_entry.s"				; MAX_LBA -  33 : Backup GPT Partition Entry
												; ...           : 
												; MAX_LBA -   2 : 
%include	"gpt_backup_header.s"				; MAX_LBA -   1 : Backup GPT Header
												; MAX_LBA       : 
