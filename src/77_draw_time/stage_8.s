;************************************************************************
;	ステージ8
;========================================================================
;■書式		: void stage_8(void);
;
;■引数		: 無し
;
;■戻り値	: 無し
;************************************************************************
stage_8:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
		FRAME_BEGIN								; // フレームの開始
		FRAME_STACK								; // スタック領域の確保

		;---------------------------------------
		; 時刻の表示
		;---------------------------------------
.10L:													; do
														; {
		xcall	get_time, [EfiTime]						;   get_time()
														;   
		movzx	rcx, byte [EfiTime + EFI_TIME.Hour]		;   RCX = 時;
		xcall	itoa, rcx, .hour, 2, 10, 4				;   itoa();
														;   
		movzx	rcx, byte [EfiTime + EFI_TIME.Minute]	;   RCX = 分;
		xcall	itoa, rcx, .min, 2, 10, 4				;   itoa();
														;   
		movzx	rcx, byte [EfiTime + EFI_TIME.Second]	;   RCX = 秒;
		xcall	itoa, rcx, .sec, 2, 10, 4				;   itoa();
														;   
		mov		rcx, [Video.HorizontalResolution]		;   // 画面の右端
		sub		rcx, 8 * 10								;   // 10文字分左
		mov		rdx, [Video.VerticalResolution]			;   // 画面の下部
		sub		rdx, 19									;   // １行分上
		xcall	draw_str, rcx, rdx, 0, 0x989898, [.time]
														;   
		xcall	scan_key								;   RAX = scan_key();
		cmp		rax, 0									;   ZF = RAX == 0;
		je		.10L									; } while (ZF);

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		FRAME_END								; // フレームの終了

;========================================================================
[section .data]
ALIGN 16, db 0
.time:	db	" "
.hour:	db	"12", ":"
.min:	db	"12", ":"
.sec:	db	"12", " ", 0

;========================================================================
[section .text]
