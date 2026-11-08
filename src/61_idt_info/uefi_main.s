;************************************************************************
;	UEFI MAIN
;************************************************************************
%include	"../include/uefi/uefi_inc.s"
%include	"../include/uefi/xcall_inc.s"
%include	"../include/uefi/frame_inc.s"

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
		xcall	stage_2							; stage_2();
		xcall	stage_3							; stage_3();

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

;************************************************************************
;	インクルード
;************************************************************************
%include	"../modules/uefi/puts.s"
%include	"../modules/uefi/itoa.s"
%include	"../modules/uefi/htoa.s"
%include	"../modules/uefi/read_key.s"
%include	"../modules/uefi/reset.s"

%include	"stage_1.s"
%include	"stage_2.s"
%include	"stage_3.s"

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

; 入力されたキーコード
gInputKey:		dq		0						; EFI_gInputKey gInputKey;

;-----------------------------------------------
;	GDT
;-----------------------------------------------
ALIGN 16, db 0
GDTR:
.Limit:			dw 	0							; ディスクリプタテーブルのリミット
.Base:			dq 	0							; ディスクリプタテーブルのアドレス

;-----------------------------------------------
;	IDT
;-----------------------------------------------
ALIGN 16, db 0
IDTR:
.Limit:			dw 	0							; ディスクリプタテーブルのリミット
.Base:			dq 	0							; ディスクリプタテーブルのアドレス
