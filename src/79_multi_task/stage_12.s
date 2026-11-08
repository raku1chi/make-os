;************************************************************************
;	ステージ12
;========================================================================
;■書式		: void stage_12(void);
;
;■引数		: 無し
;
;■戻り値	: 無し
;************************************************************************
stage_12:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
		FRAME_BEGIN								; // フレームの開始
		FRAME_STACK								; // スタック領域の確保

		;---------------------------------------
		; システムの初期化
		;---------------------------------------
		cli										; // 割り込み禁止

		xcall	init_gdt						; // GDTの初期化
		mov		r12, COL(1)								; R12 = 列;
		mov		r13, ROW(4)								; R13 = 行;
		mov		r14, COLOR_TRANSPARENT | COLOR_WHITE	; R14 = 前景色
		xcall	draw_str, r12, r13, r14, 0, [.s0]

		xcall	init_idt						; // IDTの初期化
		add		r13, ROW(1)						; R13 += 1行;
		xcall	draw_str, r12, r13, r14, 0, [.s1]

		xcall	init_apic						; // APICの初期化
		add		r13, ROW(1)						; R13 += 1行;
		xcall	draw_str, r12, r13, r14, 0, [.s2]

		xcall	init_pic						; // PICの初期化
		add		r13, ROW(2)						; R13 += 2行;
		xcall	draw_str, r12, r13, r14, 0, [.s3]

		set_idt	0x21, int_keyboard				; // キーボード割り込み
		outp	0x21, 0b_1111_1101				; // 割り込み有効：KBC

		xcall	init_task						; // タスクの初期化
		add		r13, ROW(1)						; R13 += 1行;
		xcall	draw_str, r12, r13, r14, 0, [.s4]

		xcall	init_tss						; // TSSの初期化
		add		r13, ROW(1)						; R13 += 1行;
		xcall	draw_str, r12, r13, r14, 0, [.s5]

		sti										; // 割り込み許可

		; 空読み
 		in		al, 0x60						; AL = キーコードの取得

		;---------------------------------------
		; 時刻表示用の枠
		;---------------------------------------
		mov		rcx, [Video.HorizontalResolution]; X0 = HorizontalResolution
		sub		rcx, COL(10) - 4				;   - COL(10) - 4;
		mov		r8, rcx							; X1 = X0 + COL(10);
		add		r8, COL(9)						; 
		mov		rdx, [Video.VerticalResolution]	; Y0 = VerticalResolution
		sub		rdx, TASK_BAR_H - 2				;    - (TASK_BAR_H - 2);
		mov		r9, rdx							; Y1 = Y0
		add		r9, CHAR_HEIGHT + 3				;    + (CHAR_HEIGHT + 3);
		lea		r10, [.tb_rect_colors]			; // 描画色
		xcall	draw_frame, rcx, rdx, r8, r9, r10; draw_frame();

		;---------------------------------------
		; 入力されたキーコード表示用の枠
		;---------------------------------------
		mov		rcx, 4							; X0 = 4;
		mov		rdx, [Video.VerticalResolution]	; Y0 = VerticalResolution
		sub		rdx, TASK_BAR_H - 2				;    - (TASK_BAR_H - 2);
		mov		r8, 4 + COL(16 * 3 + 2)			; X1 = 16データ + 2文字分;
		mov		r9, rdx							; Y1 = Y0
		add		r9, CHAR_HEIGHT + 3				;    + (CHAR_HEIGHT + 3);
		lea		r10, [.tb_rect_colors]			; // 描画色
		xcall	draw_frame, rcx, rdx, r8, r9, r10; draw_frame();

		;---------------------------------------
		; カーネルタスク
		;---------------------------------------
.10L:											; for ( ; ; )
												; {
		;---------------------------------------
		; タイマーカウント値を表示
		;---------------------------------------
		mov		rcx, [Timer.Counter]
		xcall	itoa, rcx, [.counter], 16, 10, 0; itoa();

		mov		rcx, COL(2)						; RCX = 列;
		mov		rdx, ROW(7)						; RDX = 行;
		mov		r8, COLOR_GRAY					; R8 = 前景色;
		mov		r9, COLOR_DISPLAY_BG			; R9 = 背景色;
		xcall	draw_str, rcx, rdx, r8, r9, [.counter]

		;---------------------------------------
		; 時刻を表示
		;---------------------------------------
		mov		rcx, [Video.HorizontalResolution]
		sub		rcx, COL(9)						;   X = 画面右端から9文字分;
		mov		rdx, [Video.VerticalResolution]	;   Y = VerticalResolution
		sub		rdx, (CHAR_HEIGHT + 3)			;   Y -= (CHAR_HEIGHT + 3);
		xcall	draw_time						;   draw_time();

		;---------------------------------------
		; キーボード入力を表示
		;---------------------------------------
		xcall	ring_rd, KEY_BUFF, [.key]		;   ring_rd();
		mov		rcx, COL(1)						;
		mov		rdx, [Video.VerticalResolution]	;   Y0 = VerticalResolution
		sub		rdx, (CHAR_HEIGHT + 3)			;   Y0 -= (CHAR_HEIGHT + 3);
		xcall	draw_key, rcx, rdx, KEY_BUFF	;   draw_key();

		jmp		.10L							; }

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		FRAME_END								; // フレームの終了

.s0:	db	"GDT initialized.", 0
.s1:	db	"IDT initialized.", 0
.s2:	db	"APIC initialized.", 0
.s3:	db	"PIC initialized.", 0
.s4:	db	"Task initialized.", 0
.s5:	db	"TSS initialized.", 0

.tb_rect_colors:								; タスクバー上の枠
		dq	COLOR_TASK_BAR_BG					; 背景色
		dq	0x00_777777							; 左
		dq	0x00_777777							; 上
		dq	0x00_F7F7F7							; 右
		dq	0x00_F7F7F7							; 下

;========================================================================
[section .data]
ALIGN 16, db 0
.counter:	db	"1122334455667788", 0
.key:		dq	0

;========================================================================
[section .text]
