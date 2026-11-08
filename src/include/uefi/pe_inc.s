;************************************************************************
;	PE(Portable Executable) File Format
;************************************************************************
;---------------------------------------
; マクロ
;---------------------------------------
%define		CEIL(data_size, align_size)		((((data_size) + ((align_size) - 1)) / (align_size)) * (align_size))

;---------------------------------------
; 定数
;---------------------------------------
		FILE_ALIGN_SIZE			equ		512			; ファイル上のアライメントサイズ
		MEMORY_ALIGN_SIZE		equ		4096		; メモリ上のアライメントサイズ

		IMAGE_BASE_ADDR			equ		0x0040_0000	; イメージが展開されるアドレス

;---------------------------------------
; 構造体
;---------------------------------------
struc IMAGE_DOS_HEADER
		WORD								e_magic
		BYTE 58,							_unuse
		DWORD								e_lfanew
endstruc

struc IMAGE_FILE_HEADER
		WORD								Machine
		WORD								NumberOfSections
		DWORD								TimeDateStamp
		DWORD								PointerToSymbolTable
		DWORD								NumberOfSymbols
		WORD								SizeOfOptionalHeader
		WORD								Characteristics
endstruc

struc IMAGE_DATA_DIRECTORY
		DWORD								VirtualAddress
		DWORD								Size
endstruc

		IMAGE_NUMBEROF_DIRECTORY_ENTRIES	equ	16

struc IMAGE_OPTIONAL_HEADER
		WORD								Magic
		BYTE								MajorLinkerVersion
		BYTE								MinorLinkerVersion
		DWORD								SizeOfCode
		DWORD								SizeOfInitializedData
		DWORD								SizeOfUninitializedData
		DWORD								AddressOfEntryPoint
		DWORD								BaseOfCode
		QWORD								ImageBase
		DWORD								SectionAlignment
		DWORD								FileAlignment
		WORD								MajorOperatingSystemVersion
		WORD								MinorOperatingSystemVersion
		WORD								MajorImageVersion
		WORD								MinorImageVersion
		WORD								MajorSubsystemVersion
		WORD								MinorSubsystemVersion
		DWORD								Win32VersionValue
		DWORD								SizeOfImage
		DWORD								SizeOfHeaders
		DWORD								CheckSum
		WORD								Subsystem
		WORD								DllCharacteristics
		QWORD								SizeOfStackReserve
		QWORD								SizeOfStackCommit
		QWORD								SizeOfHeapReserve
		QWORD								SizeOfHeapCommit
		DWORD								LoaderFlags
		DWORD								NumberOfRvaAndSizes
		BYTE IMAGE_DATA_DIRECTORY_size * IMAGE_NUMBEROF_DIRECTORY_ENTRIES, DataDirectory
endstruc

		IMAGE_SIZEOF_SHORT_NAME		equ		8

struc IMAGE_SECTION_HEADER
		BYTE IMAGE_SIZEOF_SHORT_NAME,		Name
		DWORD								VirtualSize
		DWORD								VirtualAddress
		DWORD								SizeOfRawData
		DWORD								PointerToRawData
		DWORD								PointerToRelocations
		DWORD								PointerToLinenumbers
		WORD								NumberOfRelocations
		WORD								NumberOfLinenumbers
		DWORD								Characteristics
endstruc
