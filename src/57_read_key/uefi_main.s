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
		; キー入力
		;---------------------------------------
.10L:
		; キー入力
		xcall	puts, [Const.InputKey]			; puts();
		xcall	read_key						; RAX = read_key();
		mov		r12, rax						; R12 = RAX;

		; 下位16ビットを変換
		xcall	htoa, r12, [KeyBuff.ScanCode], 4

		; 上位16ビットを変換
		shr		r12, 16							; R12 >>= 16; // 上位16ビット
		xcall	htoa, r12, [KeyBuff.UnicodeChar], 4

		; 変換されたキーコードを表示
		xcall	puts, [KeyBuff]					; puts();

		jmp		.10L

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

;-----------------------------------------------
; 定数
;-----------------------------------------------
Const:
.InputKey:		db	" Input Key : ", 0

;************************************************************************
;	インクルード
;************************************************************************
%include	"../modules/uefi/puts.s"
%include	"../modules/uefi/itoa.s"
%include	"../modules/uefi/htoa.s"
%include	"../modules/uefi/read_key.s"

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

; キーコード用バッファ
KeyBuff:
.UnicodeChar:	db		"0000", "_"
.ScanCode:		db		"0000", 0x0D, 0x0A, 0
