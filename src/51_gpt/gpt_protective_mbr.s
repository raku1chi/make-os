;************************************************************************
;	0x0000_0000 : LBA 0 : Protective MBR
;************************************************************************
MBR:
		times 440 db 0							; Boot Code
		times   4 db 0							; Unique MBR Disk Signature
		times   2 db 0							; Unknown

		;---------------------------------------
.PART_0:				    						; Partition Record[0]
		db	0x00									;   BootIndicator
		db	0x00, 0x02, 0x00						;   StartingCHS
		db	0xEE									;   OSType
		db	0xFF, 0xFF, 0xFF						;   EndingCHS
		dd	PRIMARY_HEADER_LBA						;   StartingLBA
		dd	LAST_USABLE_LBA - FIRST_USABLE_LBA + 1	;   SizeInLBA

		;---------------------------------------
		times 510 - ($ - $$) db 0
		db	0x55, 0xAA							; ブートフラグ
