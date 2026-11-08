;************************************************************************
;	UEFI MAIN
;************************************************************************
%include	"../include/uefi/uefi_inc.s"
%include	"../include/uefi/xcall_inc.s"
%include	"../include/uefi/frame_inc.s"
%include	"../include/uefi/apic_inc.s"
%include	"../include/uefi/app_inc.s"
%include	"../include/uefi/kernel_inc.s"
%include	"../include/uefi/task_inc.s"
%include	"../include/uefi/syscall_inc.s"

;************************************************************************
;	EFIエントリポイント
;========================================================================
;■書式		: EFI_STATUS uefi_main(ImageHandle, SystemTable)
;
;■引数
;	ImageHandle	: プログラムイメージのハンドル
;	SystemTable	: システムテーブルへのポインタ
;
;■戻り値	: ステータスコード
;************************************************************************
uefi_main:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
		FRAME_BEGIN								; // フレームの開始
		FRAME_STACK								; // スタック領域の確保

		;---------------------------------------
		; グローバル変数
		;---------------------------------------
		mov		[gImageHandle], rcx				; gImageHandle = ImageHandle;

		mov		rax, ST(rdx, .BootServices)		; // ブートサービス
		mov		[gBS], rax						; gBS = gST->BootServices;

		mov		rax, ST(rdx, .RuntimeServices)	; // ランタイムサービス
		mov		[gRT], rax						; gRT = gST->BootServices;

		mov		rax, ST(rdx, .ConIn)			; // コンソール入力プロトコル
		mov		[gTIP], rax						; gTIP = gST->ConIn;

		mov		rax, ST(rdx, .ConOut)			; // コンソール出力プロトコル
		mov		[gTOP], rax						; gTOP = gST->ConOut

		;---------------------------------------
		; 文字を表示
		;---------------------------------------
		mov		rcx, [rdx + EFI_SYSTEM_TABLE.ConOut]
		mov		rax, [rcx + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.OutputString]
		lea		rdx, [.s0]
		call	rax								; OutputString(ConOut, .s0);

		xcall	puts, [.s1]						; puts();

		;---------------------------------------
		; ステージ毎の処理
		;---------------------------------------
		xcall	stage_1							; stage_1();
		cmp		word [gInputKey], 0x17			; if (ESC == gInputKey)
		je		.10E							;   return;

		xcall	stage_2							; stage_2();
		xcall	stage_3							; stage_3();
		xcall	stage_4							; stage_4();
		xcall	stage_5							; stage_5();
		xcall	stage_6							; stage_6();
		xcall	stage_7							; stage_7();
		xcall	stage_8							; stage_8();
		xcall	stage_9							; stage_9();
		xcall	stage_10						; stage_10();
		xcall	stage_11						; stage_11();
		xcall	stage_12						; stage_12();

		jmp		$								; while (1) ; // 無限ループ

		;---------------------------------------
		; プログラム終了時の処理
		;---------------------------------------
		xcall	puts, [.s2]						; puts();
		xcall	read_key						; RAX = read_key();
												; 
												; // 下位バイトに文字コードを設定
		shr		rax, 16							; RAX >>= 16;
												; switch (AL)
		cmp		al, 'r'							; {
		je		.12C							; 
		cmp		al, 'R'							; 
		je		.12C							; 
												; 
		cmp		al, 's'							; 
		je		.14C							; 
		cmp		al, 'S'							; 
		je		.14C							; 
.12D:											;   default:
		xcall	reset, EfiResetShutdown			;     reset(EfiResetShutdown);
		jmp		$								;     while (1) ; // 無限ループ
												;   
.12C:											;   case 'r':
												;   case 'R':
		xcall	reset, EfiResetCold				;     reset(EfiResetCold);
		jmp		$								;     while (1) ; // 無限ループ
												;   
.14C:											;   case 's':
												;   case 'S':
		jmp		.10E							;     break;
.10E:											; }

		;---------------------------------------
		; プログラムの終了
		;---------------------------------------
		mov		rax, EFI_SUCCESS				; return EFI_SUCCESS;

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		FRAME_END								; // フレームの終了

.s0:	dw	__utf16__("Booting..."), 0x0D, 0x0A, 0
.s1:	db	"Hello, UEFI!", 0x0D, 0x0A, 0
.s2:	db	"Press any key to", 0x0D, 0x0A
		db	" reboot system.   : 'R' key", 0x0D, 0x0A
		db	" return to shell. : 'S' key", 0x0D, 0x0A
		db	" shutdown.        : others", 0x0D, 0x0A, 0

;-----------------------------------------------
; 定数
;-----------------------------------------------
Const:
.InputKey:		db	" Input Key : ", 0
.PressAnyKey:	db	"Press any key to continue...", 0
.ClearMessage:	db	0x0D
				times (.ClearMessage - .PressAnyKey - 1) db ' '
				db	0x0D, 0

EFI_HII_FONT_PROTOCOL_GUID:			dd	0xe9ca4775
									dw	0x8657, 0x47fc
									db	0x97, 0xe7, 0x7e, 0xd6, 0x5a, 0x08, 0x43, 0x24
EFI_GRAPHICS_OUTPUT_PROTOCOL_GUID:	dd	0x9042a9de
									dw	0x23dc, 0x4a38
									db	0x96, 0xfb, 0x7a, 0xde, 0xd0, 0x80, 0x51, 0x6a

;************************************************************************
;	インクルード
;************************************************************************
%include	"../modules/uefi/puts.s"
%include	"../modules/uefi/itoa.s"
%include	"../modules/uefi/htoa.s"
%include	"../modules/uefi/read_key.s"
%include	"../modules/uefi/reset.s"
%include	"../modules/uefi/allocate_pool.s"
%include	"../modules/uefi/memory_map.s"
%include	"../modules/uefi/get_protocol.s"
%include	"../modules/uefi/get_font.s"
%include	"../modules/uefi/put_glyph.s"
%include	"../modules/uefi/put_gop_mode.s"
%include	"../modules/uefi/get_gop_mode.s"
%include	"../modules/uefi/put_gop_info.s"
%include	"../modules/uefi/get_gop_info.s"
%include	"../modules/uefi/draw_pixel.s"
%include	"../modules/uefi/draw_line.s"
%include	"../modules/uefi/draw_rect.s"
%include	"../modules/uefi/fill_rect.s"
%include	"../modules/uefi/get_font_image.s"
%include	"../modules/uefi/get_font_pixel.s"
%include	"../modules/uefi/draw_char.s"
%include	"../modules/uefi/draw_str.s"
%include	"../modules/uefi/get_time.s"
%include	"../modules/uefi/scan_key.s"
%include	"../modules/uefi/query_gop_info.s"
%include	"../modules/uefi/set_gop_mode.s"
%include	"../modules/uefi/exit_boot_service.s"
%include	"../modules/uefi/init_gdt.s"
%include	"../modules/uefi/int_stop.s"
%include	"../modules/uefi/init_idt.s"
%include	"../modules/uefi/init_apic.s"
%include	"../modules/uefi/draw_frame.s"
%include	"../modules/uefi/draw_time.s"
%include	"../modules/uefi/init_pic.s"
%include	"../modules/uefi/int_keyboard.s"
%include	"../modules/uefi/ring_buff.s"
%include	"../modules/uefi/draw_key.s"
%include	"../modules/uefi/init_tss.s"
%include	"../modules/uefi/memcpy.s"
%include	"../modules/uefi/init_page_default.s"
%include	"../modules/uefi/init_page_user.s"
%include	"../modules/uefi/init_syscall.s"
%include	"../modules/uefi/int_syscall.s"
%include	"../modules/uefi/int_nm.s"
%include	"../modules/uefi/init_sse.s"

%include	"modules/int_timer.s"
%include	"modules/init_task.s"

%include	"stage_1.s"
%include	"stage_2.s"
%include	"stage_3.s"
%include	"stage_4.s"
%include	"stage_5.s"
%include	"stage_6.s"
%include	"stage_7.s"
%include	"stage_8.s"
%include	"stage_9.s"
%include	"stage_10.s"
%include	"stage_11.s"
%include	"stage_12.s"

%include	"tasks/task_proc.s"

;========================================================================
;	Data Section
;------------------------------------------------------------------------
[section .data]
;-----------------------------------------------
;	UEFIに関する情報
;-----------------------------------------------
gImageHandle:	dq		0						; EFI_HANDLE *ImageHandle;
gBS:			dq		0						; EFI_BOOT_SERVICES *gBS;
gRT:			dq		0						; EFI_RUNTIME_SERVICES *gRT;

; プロトコル
gTIP:			dq		0						; EFI_SIMPLE_TEXT_INPUT_PROTOCOL *ConIn;
gTOP:			dq		0						; EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL *ConOut;
gHFP:			dq		0						; EFI_HII_FONT_PROTOCOL_GUID *gHFP;
gGOP:			dq		0						; EFI_GRAPHICS_OUTPUT_PROTOCOL* gGOP;

; 入力されたキーコード
gInputKey:		dq		0						; EFI_gInputKey gInputKey;

;-----------------------------------------------
;	GDT
;-----------------------------------------------
ALIGN 16, db 0
GDTR:
.Limit:			dw 	0							; ディスクリプタテーブルのリミット
.Base:			dq 	0							; ディスクリプタテーブルのアドレス

ALIGN 16, db 0
NEW_GDT:		dq	0x00000000_00000000			; 00 NULL
.cs_kernel:		dq	0x00209A00_00000000			; 08 CODE(Ring 0/Long Mode)
.ds_kernel:		dq	0x00409200_00000000			; 10 DATA(Ring 0/32Bit)
				dq	0x00000000_00000000			; 18 NULL
.ds_task:		dq	0x0040F200_00000000			; 20 DATA(Ring 3)
.cs_task:		dq	0x0020FA00_00000000			; 28 CODE(Ring 3)
.tss:			dq	0x00008900_00000067			; 30 TSS(Low)
				dq	0x00000000_00000000			; 38     (Hi)
.end:

CS_KERNEL		equ	.cs_kernel - NEW_GDT		; カーネル用CSセレクタ
DS_KERNEL		equ	.ds_kernel - NEW_GDT		; カーネル用DSセレクタ
CS_TASK			equ	(.cs_task - NEW_GDT) | 3	; タスク用CSセレクタ
DS_TASK			equ	(.ds_task - NEW_GDT) | 3	; タスク用DSセレクタ
TSS_TASK		equ	.tss - NEW_GDT				; TSS

NEW_GDTR:		dw	NEW_GDT.end - NEW_GDT - 1	; ディスクリプタテーブルのリミット
				dq	NEW_GDT						; ディスクリプタテーブルのアドレス

;-----------------------------------------------
;	IDT
;-----------------------------------------------
ALIGN 16, db 0
IDTR:
.Limit:			dw 	0							; ディスクリプタテーブルのリミット
.Base:			dq 	0							; ディスクリプタテーブルのアドレス

ALIGN 16, db 0
IDT: times 256	dq	0, 0						; 256エントリ:割り込みベクタ

;-----------------------------------------------
;	メモリに関する情報
;-----------------------------------------------
ALIGN 16, db 0
MemoryMap:
.AllocBytes:	dq	0							; メモリのバイト数
.AllocPtr:		dq	0							; メモリのポインタ
.Size:			dq	0							; 必要なバイト数
.MapKey:		dq	0							; マップキー
.DescSize:		dq	0							; ディスクリプタのバイト数
.DescVer:		dq	0							; ディスクリプタのバージョン

;-----------------------------------------------
;	フォントに関する情報
;-----------------------------------------------
ALIGN 16, db 0
FONT:			dq	0

;-----------------------------------------------
;	画面出力に関する情報
;-----------------------------------------------
Video:
.MaxMode:				dq	0					; モード数
.Mode:					dq	0					; モード番号
.HorizontalResolution:	dq	0					; 水平解像度
.VerticalResolution:	dq	0					; 垂直解像度
.PixelsPerScanLine:		dq	0					; ライン毎のピクセル数
.PixelFormat:			dq	0					; ピクセルフォーマット
.BytesPerPixel:			dq	0					; ピクセル毎のバイト数
.RedMask:				dq	0					; ビットマスク：赤
.GreenMask:				dq	0					; ビットマスク：緑
.BlueMask:				dq	0					; ビットマスク：青
.ReservedMask:			dq	0					; ビットマスク：予約
.FrameBufferBase:		dq	0					; フレームバッファアドレス
.FrameBufferSize:		dq	0					; フレームバッファサイズ

;-----------------------------------------------
;	時刻に関する情報
;-----------------------------------------------
ALIGN 16, db 0
EfiTime: times EFI_TIME_size db 0				; 時刻

;-----------------------------------------------
;	APICに関する情報
;-----------------------------------------------
ALIGN 16, db 0
APIC:
.Base			dq	0							; APICベースアドレス

Timer:
.Interval		dq	0							; APICタイマーインターバル
.Counter:		dq	0							; APICタイマーカウンタ

;-----------------------------------------------
;	タスクに関する情報
;-----------------------------------------------
ALIGN 16, db 0
Task:
.AllocPtr:		dq	0							; タスク用メモリ領域の先頭
.BaseAddr:		dq	0							; タスク用メモリ領域（2M境界）
.Current:		dq	0							; 現在のタスク
.UsedSse:		dq	0							; 前回SSEを使用したタスク

TASK_COUNT	equ		5							; カーネルを含めたタスクの個数

.TSS:		times TSS_size db 0					; TSS

.Kernel:
	istruc	TASK_CTRL
		at	TASK_CTRL.cs,		dq	CS_KERNEL	; CS
		at	TASK_CTRL.ds,		dq	DS_KERNEL	; DS
		at	TASK_CTRL.ss,		dq	DS_KERNEL	; SS
		at	TASK_CTRL.es,		dq	DS_KERNEL	; ES
		at	TASK_CTRL.fs,		dq	DS_KERNEL	; FS
		at	TASK_CTRL.gs,		dq	DS_KERNEL	; GS
		at	TASK_CTRL.param,	dq	.Param_0	; PARAM
	iend
.Task_1:
	istruc	TASK_CTRL
		at	TASK_CTRL.cs,		dq	CS_TASK		; CS
		at	TASK_CTRL.ds,		dq	DS_TASK		; DS
		at	TASK_CTRL.ss,		dq	DS_TASK		; SS
		at	TASK_CTRL.es,		dq	DS_TASK		; ES
		at	TASK_CTRL.fs,		dq	DS_TASK		; FS
		at	TASK_CTRL.gs,		dq	DS_TASK		; GS
		at	TASK_CTRL.param,	dq	.Param_1	; PARAM
	iend
.Task_2:
	istruc	TASK_CTRL
		at	TASK_CTRL.cs,		dq	CS_TASK		; CS
		at	TASK_CTRL.ds,		dq	DS_TASK		; DS
		at	TASK_CTRL.ss,		dq	DS_TASK		; SS
		at	TASK_CTRL.es,		dq	DS_TASK		; ES
		at	TASK_CTRL.fs,		dq	DS_TASK		; FS
		at	TASK_CTRL.gs,		dq	DS_TASK		; GS
		at	TASK_CTRL.param,	dq	.Param_2	; PARAM
	iend
.Task_3:
	istruc	TASK_CTRL
		at	TASK_CTRL.cs,		dq	CS_TASK		; CS
		at	TASK_CTRL.ds,		dq	DS_TASK		; DS
		at	TASK_CTRL.ss,		dq	DS_TASK		; SS
		at	TASK_CTRL.es,		dq	DS_TASK		; ES
		at	TASK_CTRL.fs,		dq	DS_TASK		; FS
		at	TASK_CTRL.gs,		dq	DS_TASK		; GS
		at	TASK_CTRL.param,	dq	.Param_3	; PARAM
	iend
.Task_4:
	istruc	TASK_CTRL
		at	TASK_CTRL.cs,		dq	CS_TASK		; CS
		at	TASK_CTRL.ds,		dq	DS_TASK		; DS
		at	TASK_CTRL.ss,		dq	DS_TASK		; SS
		at	TASK_CTRL.es,		dq	DS_TASK		; ES
		at	TASK_CTRL.fs,		dq	DS_TASK		; FS
		at	TASK_CTRL.gs,		dq	DS_TASK		; GS
		at	TASK_CTRL.param,	dq	.Param_4	; PARAM
	iend
.TaskEnd:

.Param_0:
	istruc	TASK_PARAM
	iend
.Param_1:
	istruc	TASK_PARAM
		at	TASK_PARAM.id,		db	1			; タスクID
		at	TASK_PARAM.title,	db	"Task-1", 0	; タイトル
		at	TASK_PARAM.col,		dq	COL(2)		; タスク情報表示位置：列
		at	TASK_PARAM.row,		dq	ROW(11)		; タスク情報表示位置：行
	iend
.Param_2:
	istruc	TASK_PARAM
		at	TASK_PARAM.id,		db	2			; タスクID
		at	TASK_PARAM.title,	db	"Task-2", 0	; タイトル
		at	TASK_PARAM.col,		dq	COL(2)		; タスク情報表示位置：列
		at	TASK_PARAM.row,		dq	ROW(12)		; タスク情報表示位置：行
	iend
.Param_3:
	istruc	TASK_PARAM
		at	TASK_PARAM.id,		db	3			; タスクID
		at	TASK_PARAM.title,	dq	"Task-3", 0	; タイトル
		at	TASK_PARAM.col,		dq	COL(2)		; タスク情報表示位置：列
		at	TASK_PARAM.row,		dq	ROW(13)		; タスク情報表示位置：行
	iend
.Param_4:
	istruc	TASK_PARAM
		at	TASK_PARAM.id,		db	4			; タスクID
		at	TASK_PARAM.title,	db	"Task-4", 0	; タイトル
		at	TASK_PARAM.col,		dq	COL(2)		; タスク情報表示位置：列
		at	TASK_PARAM.row,		dq	ROW(14)		; タスク情報表示位置：行
	iend
