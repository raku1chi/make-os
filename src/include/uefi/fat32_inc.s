;************************************************************************
;	FAT32用定義
;************************************************************************
		ATTR_READ_ONLY		equ		0x01
		ATTR_HIDDEN			equ		0x02
		ATTR_SYSTEM			equ		0x04
		ATTR_VOLUME_ID		equ		0x08
		ATTR_DIRECTORY		equ		0x10
		ATTR_ARCHIVE		equ		0x20

		FAT32_SECT_SIZE		equ		(512)
		FAT32_CLUST_SIZE	equ		(4096)
		FAT32_FAT_SECT		equ		(1024)

		FAT32_HIDDEN_SECT	equ		(FIRST_USABLE_LBA)
		FAT32_TOTAL_SECT	equ		(LAST_USABLE_LBA - FIRST_USABLE_LBA + 1)

		FAT32_FSINFO_SECT	equ		(1)
		FAT32_BACKUP_SECT	equ		(6)
		FAT32_RESERVED_SECT	equ		(32)

		FAT32_FAT_SIZE		equ		(FAT32_FAT_SECT * FAT32_SECT_SIZE)
		FAT32_BACKUP_START	equ		(FAT32_BACKUP_SECT * FAT32_SECT_SIZE)

		FAT32_FAT1_START	equ		(FAT32_RESERVED_SECT * FAT32_SECT_SIZE)
		FAT32_FAT2_START	equ		(FAT32_FAT1_START + FAT32_FAT_SIZE)
		FAT32_DATA_START	equ		(FAT32_FAT2_START + FAT32_FAT_SIZE)
