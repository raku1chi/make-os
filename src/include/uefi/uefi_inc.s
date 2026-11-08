;************************************************************************
;	UEFI用定義
;************************************************************************
;---------------------------------------
; ステータスコード
;---------------------------------------
EFI_SUCCESS					equ		(0)
EFI_WARN_UNKNOWN_GLYPH		equ		(1)
EFI_LOAD_ERROR				equ		((1 << 63) | 1)
EFI_INVALID_PARAMETER		equ		((1 << 63) | 2)
EFI_UNSUPPORTED				equ		((1 << 63) | 3)
EFI_BAD_BUFFER_SIZE			equ		((1 << 63) | 4)
EFI_BUFFER_TOO_SMALL		equ		((1 << 63) | 5)
EFI_NOT_READY				equ		((1 << 63) | 6)
EFI_DEVICE_ERROR			equ		((1 << 63) | 7)

;---------------------------------------
; ResetSystem
;---------------------------------------
EfiResetCold				equ		(0)
EfiResetWarm				equ		(1)
EfiResetShutdown			equ		(2)
EfiResetPlatformSpecific	equ		(3)

;---------------------------------------
; メモリタイプ
;---------------------------------------
EfiReservedMemoryType		equ		 0
EfiLoaderCode				equ		 1
EfiLoaderData				equ		 2
EfiBootServicesCode			equ		 3
EfiBootServicesData			equ		 4
EfiRuntimeServicesCode		equ		 5
EfiRuntimeServicesData		equ		 6
EfiConventionalMemory		equ		 7
EfiUnusableMemory			equ		 8
EfiACPIReclaimMemory		equ		 9
EfiACPIMemoryNVS			equ		10
EfiMemoryMappedIO			equ		11
EfiMemoryMappedIOPortSpace	equ		12
EfiPalCode					equ		13
EfiPersistentMemory			equ		14

;************************************************************************
;	構造体
;************************************************************************
;---------------------------------------
; テーブルヘッダ
;---------------------------------------
struc EFI_TABLE_HEADER
		UINT64								Signature
		UINT32								Revision
		UINT32								HeaderSize
		UINT32								CRC32
		UINT32								Reserved
endstruc

;---------------------------------------
; システムテーブル
;---------------------------------------
struc EFI_SYSTEM_TABLE
		BYTE EFI_TABLE_HEADER_size,			Hdr
		PTR									FirmwareVendor
		UINT32 2,							FirmwareRevision
		PTR									ConsoleInHandle
		PTR									ConIn
		PTR									ConsoleOutHandle
		PTR									ConOut
		PTR									StandardErrorHandle
		PTR									StdErr
		PTR									RuntimeServices
		PTR									BootServices
		UINTN								NumberOfTableEntries
		PTR									ConfigurationTable
endstruc

;---------------------------------------
; 標準出力プロトコル
;---------------------------------------
struc EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL
		PTR									Reset
		PTR									OutputString
		PTR									TestString
		PTR									QueryMode
		PTR									SetMode
		PTR									SetAttribute
		PTR									ClearScreen
		PTR									SetCursorPosition
		PTR									EnableCursor
		PTR									Mode
endstruc

;---------------------------------------
; 標準入力プロトコル
;---------------------------------------
struc EFI_SIMPLE_TEXT_INPUT_PROTOCOL
		PTR									Reset
		PTR									ReadKeyStroke
		PTR									WaitForKey
endstruc

;---------------------------------------
; ブートサービス
;---------------------------------------
struc EFI_BOOT_SERVICES
		BYTE	EFI_TABLE_HEADER_size,		Hdr
		PTR									RaiseTPL
		PTR									RestoreTPL
		PTR									AllocatePages
		PTR									FreePages
		PTR									GetMemoryMap
		PTR									AllocatePool
		PTR									FreePool
		PTR									CreateEvent
		PTR									SetTimer
		PTR									WaitForEvent
		PTR									SignalEvent
		PTR									CloseEvent
		PTR									CheckEvent
		PTR									InstallProtocolInterface
		PTR									ReinstallProtocolInterface
		PTR									UninstallProtocolInterface
		PTR									HandleProtocol
		PTR									Reserved
		PTR									RegisterProtocolNotify
		PTR									LocateHandle
		PTR									LocateDevicePath
		PTR									InstallConfigurationTable
		PTR									LoadImage
		PTR									StartImage
		PTR									Exit
		PTR									UnloadImage
		PTR									ExitBootServices
		PTR									GetNextMonotonicCount
		PTR									Stall
		PTR									SetWatchdogTimer
		PTR									ConnectController
		PTR									DisconnectController
		PTR									OpenProtocol
		PTR									CloseProtocol
		PTR									OpenProtocolInformation
		PTR									ProtocolsPerHandle
		PTR									LocateHandleBuffer
		PTR									LocateProtocol
		PTR									InstallMultipleProtocolInterfaces
		PTR									UninstallMultipleProtocolInterfaces
		PTR									CalculateCrc32
		PTR									CopyMem
		PTR									SetMem
		PTR									CreateEventEx
endstruc

;---------------------------------------
; ランタイムサービス
;---------------------------------------
struc EFI_RUNTIME_SERVICES
		BYTE	EFI_TABLE_HEADER_size,		Hdr
		PTR									GetTime
		PTR									SetTime
		PTR									GetWakeupTime
		PTR									SetWakeupTime
		PTR									SetVirtualAddressMap
		PTR									ConvertPointer
		PTR									GetVariable
		PTR									GetNextVariableName
		PTR									SetVariable
		PTR									GetNextHighMonotonicCount
		PTR									ResetSystem
		PTR									UpdateCapsule
		PTR									QueryCapsuleCapabilities
		PTR									QueryVariableInfo
endstruc

;---------------------------------------
; メモリディスクリプタ
;---------------------------------------
struc EFI_MEMORY_DESCRIPTOR
		UINT32								Type 
		UINT32								_padding_ 
		UINT64								PhysicalStart 
		UINT64								VirtualStart 
		UINT64								NumberOfPages 
		UINT64								Attribute 
endstruc

;---------------------------------------
; フォントプロトコル
;---------------------------------------
struc EFI_HII_FONT_PROTOCOL
		PTR									StringToImage
		PTR									StringIdToImage
		PTR									GetGlyph
		PTR									GetFontInfo
endstruc

;---------------------------------------
; イメージ情報
;---------------------------------------
struc EFI_IMAGE_OUTPUT
		UINT16								Width
		UINT16								Height
		UINT32								_padding_
		PTR									Bitmap
endstruc

;---------------------------------------
; グラフィックス出力モード情報
;---------------------------------------
struc EFI_GRAPHICS_OUTPUT_MODE_INFORMATION
		UINT32								Version
		UINT32								HorizontalResolution
		UINT32								VerticalResolution
		UINT32								PixelFormat
		UINT32	4,							PixelInformation		; EFI_PIXEL_BITMASK
		UINT32								PixelsPerScanLine
endstruc

;---------------------------------------
; グラフィックス出力プロトコルモード
;---------------------------------------
struc EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE
		UINT32								MaxMode
		UINT32								Mode
		PTR									Info					; EFI_GRAPHICS_OUTPUT_MODE_INFORMATION
		UINTN								SizeOfInfo
		UINT64								FrameBufferBase
		UINTN								FrameBufferSize
endstruc

;---------------------------------------
; グラフィックス出力プロトコル
;---------------------------------------
struc EFI_GRAPHICS_OUTPUT_PROTOCOL
		PTR									QueryMode
		PTR									SetMode
		PTR									Blt
		PTR									Mode					; EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE
endstruc

;---------------------------------------
; 時刻
;---------------------------------------
struc EFI_TIME
		UINT16								Year						; // 1900-9999
		UINT8								Month						; // 1-12
		UINT8								Day							; // 1-31
		UINT8								Hour						; // 0-23
		UINT8								Minute						; // 0-59
		UINT8								Second						; // 0-59
		UINT8								Pad1						;
		UINT32								Nanosecond					; // 0-999,999,999
		INT16								TimeZone					; // -1440 to 1440 or 2047
		UINT8								Daylight					;
		UINT8								Pad2						;
endstruc

;---------------------------------------
; 構造体要素へのアクセス
;---------------------------------------
%define	ST(adr, ofs)		[adr + EFI_SYSTEM_TABLE %+ ofs]
%define	BS(adr, ofs)		[adr + EFI_BOOT_SERVICES %+ ofs]
%define	RT(adr, ofs)		[adr + EFI_RUNTIME_SERVICES %+ ofs]

%define	TOP(adr, ofs)		[adr + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL %+ ofs]
%define	TIP(adr, ofs)		[adr + EFI_SIMPLE_TEXT_INPUT_PROTOCOL %+ ofs]
%define	MD(adr, ofs)		[adr + EFI_MEMORY_DESCRIPTOR %+ ofs]
%define	HFP(adr, ofs)		[adr + EFI_HII_FONT_PROTOCOL %+ ofs]
%define	GOMI(adr, ofs)		[adr + EFI_GRAPHICS_OUTPUT_MODE_INFORMATION %+ ofs]
%define	GOPM(adr, ofs)		[adr + EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE %+ ofs]
%define	GOP(adr, ofs)		[adr + EFI_GRAPHICS_OUTPUT_PROTOCOL %+ ofs]
