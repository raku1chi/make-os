;************************************************************************
;	GPTの構成
;************************************************************************
		;
		;         LBA   Address  ____________  
		;           0 0000_0000 | MBR        | Protective MBR
		;                       |____________| 
		;           1 0000_0200 | Header     | Primary GPT Header
		;                       |____________| 
		;           2 0000_0400 | Entry      | Primary GPT Partition Entry
		;                       |            |   LBA[2:33]
		;                       =            = 
		;                       |____________| 
		;          34 0000_4400 |////////////|   GAP(ALIGN)
		;                       =            = 
		;                       |____________| 
		;          64 0000_8000 |            | 
		;                       | PARTITION  | 
		;                       |  (FAT32)   | 
		;                       |____________| 
		;     1048543 1FFF_BE00 | Entry      | Backup GPT Partition Entry
		;                       |            |   LBA[1048543:1048575]
		;                       =            = 
		;                       |____________| 
		;     1048575 1FFF_FE00 | Header     | Backup GPT Header
		;                       |____________| 
		;     MAX_LBA 2000_0000 |////////////| 512M
		;                       |            | 

		LBA_SIZE				equ		(512)
		DISK_SIZE				equ		(512 * 1024 * 1024)
		MAX_LBA					equ		(DISK_SIZE / LBA_SIZE)

		;---------------------------------------
		; LBAの定義
		;---------------------------------------
		PROTECTIVE_MBR_LBA		equ		(0)
		PRIMARY_HEADER_LBA		equ		(1)
		PRIMARY_ENTRY_LBA		equ		(2)
		PARTITION_LBA			equ		(64)
		BACKUP_ENTRY_LBA		equ		(MAX_LBA - 33)
		BACKUP_HEADER_LBA		equ		(MAX_LBA - 1)

		FIRST_USABLE_LBA		equ		(PARTITION_LBA)
		LAST_USABLE_LBA			equ		(BACKUP_ENTRY_LBA - 1)

		GPT_HEADER_SIZE			equ		(92)
		GPT_ENTRY_SIZE			equ		(128)
