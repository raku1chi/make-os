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
		; 数値を表示
		;---------------------------------------
		xcall	itoa, -1, [Buff.b20], 20, 10, 0	; "18446744073709551615"
		xcall	puts, [Buff.b20]

		xcall	itoa, -1, [Buff.b16], 16, 16, 0	; "FFFFFFFFFFFFFFFF"
		xcall	puts, [Buff.b16]

		xcall	htoa, -1, [Buff.b17], 17		; "FFFFFFFF_FFFFFFFF"
		xcall	puts, [Buff.b17]

		jmp		$								; while (1) ; // 無限ループ

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

;************************************************************************
;	インクルード
;************************************************************************
%include	"../modules/uefi/puts.s"
%include	"../modules/uefi/itoa.s"
%include	"../modules/uefi/htoa.s"

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

; 数値変換用バッファ
Buff:
.b20:			db	"123"
.b17:			db	"1"
.b16:			db	"2345678_12345678"
				db	0x0D, 0x0A, 0
