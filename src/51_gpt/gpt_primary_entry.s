;************************************************************************
;	Primary GPT Partition Entry
;************************************************************************
PRIMARY_ENTRY:
.top:
		;---------------------------------------
		; 最初のエントリ
		;---------------------------------------
		DEF_GUID 0xEBD0A0A2, 0xB9E5, 0x4433, \
					0x87C0, 0x68B6B72699C7		; PartitionTypeGUID(FAT32)
		DEF_GUID 0xA4B54322, 0xDAE1, 0x4E8C, \
					0xAD0E, 0x70F8B32CD52A		; UniquePartitionGUID
		dq	FIRST_USABLE_LBA					; First LBA
		dq	LAST_USABLE_LBA						; Last  LBA
		dq	0									; Attribute FLAGS
		dw	__utf16__('FAT32'), 0				; Partition Name

		;---------------------------------------
		; 残り（127）のエントリ
		;---------------------------------------
		times LBA_SIZE - ($ - .top) db 0
		times LBA_SIZE * 31 db 0
