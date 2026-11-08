;************************************************************************
;	Backup GPT Header
;************************************************************************
BACKUP_HEADER:
.top:
		db	"EFI PART"							; Signature
		dd	0x0001_0000							; Revision
		dd	GPT_HEADER_SIZE						; Header size
		dd	BACKUP_HEADER_CRC					; HeaderCRC32
		dd	0									; Reserved
		dq	BACKUP_HEADER_LBA					; MyLBA
		dq	PRIMARY_HEADER_LBA					; AlternateLBA
		dq	FIRST_USABLE_LBA					; FirstUsableLBA
		dq	LAST_USABLE_LBA						; LastUsableLBA
		DEF_GUID 0x34D051F3, 0xC6AD, 0x4DE7, \
					0x8EAE, 0xEE43FA58BB48		; DiskGUID
		dq	BACKUP_ENTRY_LBA					; PartitionEntryLBA
		dd	128									; NumberOfPartitionEntries
		dd	GPT_ENTRY_SIZE						; SizeOfPartitionEntry
		dd	PARTITION_ENTRY_CRC					; PartitionEntryArrayCRC32

		;---------------------------------------
		times LBA_SIZE - ($ - .top) db 0
