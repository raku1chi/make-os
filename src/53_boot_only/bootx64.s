;************************************************************************
;	BOOT IMAGE
;************************************************************************
%include	"../include/uefi/type_inc.s"
%include	"../include/uefi/pe_inc.s"

;************************************************************************
;	SECTION ORDER
;************************************************************************
[section .header align=FILE_ALIGN_SIZE]
[section .text   align=FILE_ALIGN_SIZE follows=.header]
[section .data   align=FILE_ALIGN_SIZE follows=.text]

[section .header vstart=IMAGE_BASE_ADDR]
[section .text   vstart=IMAGE_BASE_ADDR+KERNEL_CODE_START]
[section .data   vstart=IMAGE_BASE_ADDR+KERNEL_DATA_START]

;************************************************************************
;	HEADER SECTION
;************************************************************************
[section .header]
;------------------------------------------------------------------------
PE:
		;================================================================
		; DOS HEADER
		;================================================================
.DOS_HEADER:
		istruc	IMAGE_DOS_HEADER
			at	IMAGE_DOS_HEADER.e_magic,	db		"MZ"
			at	IMAGE_DOS_HEADER.e_lfanew,	dd		.NT_HEADER - .DOS_HEADER
		iend

		;----------------------------------------------------------------
		; DOS STUB
		;----------------------------------------------------------------
[CPU 8086]
[BITS 16]
.DOS_STUB:
		push	cs								; 
		pop		ds								; 
		mov		dx, .s0 - .DOS_STUB				; 
		mov		ah, 0x09						; 
		int		0x21							; puts(.s0);

		mov		ax, 0x4c01						; 
		int		0x21							; exit(1);

.s0:	db	"This program cannot be run in DOS mode.", 0x0D, 0x0D, 0x0A, '$'

ALIGN 16, db 0

		;================================================================
		; PE HEADER
		;	- Signature
		;	- File Header
		;	- Optional Header
		;================================================================
[CPU X64]
[BITS 64]
[DEFAULT REL]
.NT_HEADER:
		;----------------------------------------------------------------
		; Signature
		;----------------------------------------------------------------
		db "PE", 0, 0

		;----------------------------------------------------------------
		; NT FILE HEADER
		;----------------------------------------------------------------
.NT_FILE_HEADER:
		istruc	IMAGE_FILE_HEADER
			at	IMAGE_FILE_HEADER.Machine,								dw	0x8664
																		;	0x8664 = AMD64
			at	IMAGE_FILE_HEADER.NumberOfSections,						dw	2
			at	IMAGE_FILE_HEADER.SizeOfOptionalHeader,					dw	IMAGE_OPTIONAL_HEADER_size
			at	IMAGE_FILE_HEADER.Characteristics,						dw	0x0223
																		;	0x0001 = IMAGE_FILE_RELOCS_STRIPPED
																		;	0x0002 = IMAGE_FILE_EXECUTABLE_IMAGE
																		;	0x0020 = IMAGE_FILE_LARGE_ADDRESS_AWARE
																		;	0x0200 = IMAGE_FILE_DEBUG_STRIPPED
		iend

		;----------------------------------------------------------------
		; NT OPTIONAL HEADER
		;----------------------------------------------------------------
.NT_OPTIONAL_HEADER:
		istruc	IMAGE_OPTIONAL_HEADER
			at	IMAGE_OPTIONAL_HEADER.Magic,							dw	0x020B
																		;	0x020B = PE64
			at	IMAGE_OPTIONAL_HEADER.SizeOfCode,						dd	KERNEL_CODE_SIZE
			at	IMAGE_OPTIONAL_HEADER.SizeOfInitializedData,			dd	KERNEL_DATA_SIZE
			at	IMAGE_OPTIONAL_HEADER.AddressOfEntryPoint,				dd	KERNEL_CODE_START
			at	IMAGE_OPTIONAL_HEADER.BaseOfCode,						dd	KERNEL_CODE_START
			at	IMAGE_OPTIONAL_HEADER.ImageBase,						dd	IMAGE_BASE_ADDR
			at	IMAGE_OPTIONAL_HEADER.SectionAlignment,					dd	MEMORY_ALIGN_SIZE
			at	IMAGE_OPTIONAL_HEADER.FileAlignment,					dd	FILE_ALIGN_SIZE
			at	IMAGE_OPTIONAL_HEADER.SizeOfImage,						dd	HEADER_MEMORY_SIZE + \
																			KERNEL_CODE_MEMORY_SIZE + \
																			KERNEL_DATA_MEMORY_SIZE
			at	IMAGE_OPTIONAL_HEADER.SizeOfHeaders,					dd	HEADER_FILE_SIZE
			at	IMAGE_OPTIONAL_HEADER.Subsystem,						dw	10
																		;	10 = IMAGE_SUBSYSTEM_EFI_APPLICATION
			at	IMAGE_OPTIONAL_HEADER.SizeOfStackReserve,				dd	MEMORY_ALIGN_SIZE
			at	IMAGE_OPTIONAL_HEADER.SizeOfStackCommit,				dd	MEMORY_ALIGN_SIZE
			at	IMAGE_OPTIONAL_HEADER.SizeOfHeapReserve,				dd	MEMORY_ALIGN_SIZE
			at	IMAGE_OPTIONAL_HEADER.SizeOfHeapCommit,					dd	MEMORY_ALIGN_SIZE
			at	IMAGE_OPTIONAL_HEADER.NumberOfRvaAndSizes,				dd	16
		iend

		;----------------------------------------------------------------
		; SECTION HEADER
		;----------------------------------------------------------------
.SECTION_HEADER:
		istruc	IMAGE_SECTION_HEADER
			at	IMAGE_SECTION_HEADER.Name,								db	".text"
			at	IMAGE_SECTION_HEADER.VirtualSize,						dd	KERNEL_CODE_MEMORY_SIZE
			at	IMAGE_SECTION_HEADER.VirtualAddress,					dd	KERNEL_CODE_START
			at	IMAGE_SECTION_HEADER.SizeOfRawData,						dd	KERNEL_CODE_FILE_SIZE
			at	IMAGE_SECTION_HEADER.PointerToRawData,					dd	HEADER_FILE_SIZE
			at	IMAGE_SECTION_HEADER.Characteristics,					dd	0x6050_0020
																		;	0x0000_0020 = IMAGE_SCN_CNT_CODE
																		;	0x0050_0000 = IMAGE_SCN_ALIGN_16BYTES
																		;	0x2000_0000 = IMAGE_SCN_MEM_EXECUTE
																		;	0x4000_0000 = IMAGE_SCN_MEM_READ
		iend

		istruc	IMAGE_SECTION_HEADER
			at	IMAGE_SECTION_HEADER.Name,								db	".data"
			at	IMAGE_SECTION_HEADER.VirtualSize,						dd	KERNEL_DATA_MEMORY_SIZE
			at	IMAGE_SECTION_HEADER.VirtualAddress,					dd	KERNEL_DATA_START
			at	IMAGE_SECTION_HEADER.SizeOfRawData,						dd	KERNEL_DATA_FILE_SIZE
			at	IMAGE_SECTION_HEADER.PointerToRawData,					dd	HEADER_FILE_SIZE + \
																			KERNEL_CODE_FILE_SIZE
			at	IMAGE_SECTION_HEADER.Characteristics,					dd	0xC050_0040
																		;	0x0000_0040 = IMAGE_SCN_CNT_INITIALIZED_DATA
																		;	0x0050_0000 = IMAGE_SCN_ALIGN_16BYTES
																		;	0x4000_0000 = IMAGE_SCN_MEM_READ
																		;	0x8000_0000 = IMAGE_SCN_MEM_WRITE
		iend

;************************************************************************
;	CODE SECTION
;************************************************************************
[section .text]
;------------------------------------------------------------------------
CODE:
	mov		rax, 0														; return 0;
	ret

;************************************************************************
;	DATA SECTION
;************************************************************************
[section .data]
;------------------------------------------------------------------------
DATA:

;************************************************************************
;	HEADER SECTION
;************************************************************************
[section .header]
;------------------------------------------------------------------------
ALIGN FILE_ALIGN_SIZE, db 0
		HEADER_SIZE					equ		($ - $$)
		HEADER_FILE_SIZE			equ		CEIL(HEADER_SIZE, FILE_ALIGN_SIZE)
		HEADER_MEMORY_SIZE			equ		CEIL(HEADER_SIZE, MEMORY_ALIGN_SIZE)

;************************************************************************
;	CODE SECTION
;************************************************************************
[section .text]
;------------------------------------------------------------------------
ALIGN FILE_ALIGN_SIZE, db 0
		KERNEL_CODE_SIZE			equ		($ - $$)
		KERNEL_CODE_FILE_SIZE		equ		CEIL(KERNEL_CODE_SIZE, FILE_ALIGN_SIZE)
		KERNEL_CODE_MEMORY_SIZE		equ		CEIL(KERNEL_CODE_SIZE, MEMORY_ALIGN_SIZE)

;************************************************************************
;	DATA SECTION
;************************************************************************
[section .data]
;------------------------------------------------------------------------
ALIGN FILE_ALIGN_SIZE, db 0
		KERNEL_DATA_SIZE			equ		($ - $$)
		KERNEL_DATA_FILE_SIZE		equ		CEIL(KERNEL_DATA_SIZE, FILE_ALIGN_SIZE)
		KERNEL_DATA_MEMORY_SIZE		equ		CEIL(KERNEL_DATA_SIZE, MEMORY_ALIGN_SIZE)

		KERNEL_CODE_START			equ		(HEADER_MEMORY_SIZE)
		KERNEL_DATA_START			equ		(KERNEL_CODE_START + KERNEL_CODE_MEMORY_SIZE)
