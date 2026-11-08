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

		xcall	init_draw_area					; // 描画領域の設定
		xcall	init_task						; // タスクの初期化
		add		r13, ROW(1)						; R13 += 1行;
		xcall	draw_str, r12, r13, r14, 0, [.s4]

		xcall	init_tss						; // TSSの初期化
		add		r13, ROW(1)						; R13 += 1行;
		xcall	draw_str, r12, r13, r14, 0, [.s5]

		xcall	init_syscall					; // syscallの初期化
		add		r13, ROW(9)						; R13 += 9行;
		xcall	draw_str, r12, r13, r14, 0, [.s6]

		set_idt	0x07, int_nm					; // 割り込み処理の登録：デバイス使用不可

		xcall	init_sse						; // SSEの初期化
		add		r13, ROW(1)						; R13 += 1行;
		xcall	draw_str, r12, r13, r14, 0, [.s7]

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

		;---------------------------------------
		; CTRL+ALD+ENDキーの検出
		;---------------------------------------
		cmp		rax, 0							;   if (0 !=RAX)
		je		.11E							;   {
		xcall	ctrl_alt_end, qword [.key]		;     RAX = ctrl_alt_end();
		cmp		rax, 0							;     if (0 != RAX)
		je		.11E							;     {

		; テキストを表示する位置を計算（画面の中央部分）
		mov		r12, [Video.HorizontalResolution]
		shr		r12, 1							;
		sub		r12, COL(8)						;
		mov		r13, [Video.VerticalResolution]	; 
		shr		r13, 1							;
		sub		r13, ROW(1)						;

		mov		r14, 0x00_FFFFFF				;       R14 = 前景色;
		mov		r15, 0x00_7F007F				;       R15 = 背景色;

		; カウントダウン
		xcall	draw_str, r12, r13, r14, r15, [.s8]
		add		r12, COL(13)
		xcall	draw_str, r12, r13, r14, r15, [.t3]
		xcall	wait_tick, 100
		xcall	draw_str, r12, r13, r14, r15, [.t2]
		xcall	wait_tick, 100
		xcall	draw_str, r12, r13, r14, r15, [.t1]
		xcall	wait_tick, 100

		xcall	reset, EfiResetShutdown			;       reset(EfiResetShutdown);

		jmp		$								;       while (1) ; // 無限ループ
												;     }
.11E:											;   }

		;---------------------------------------
		; 各タスクのカウンタ値を表示
		;---------------------------------------
		mov		r12, ROW(15)					;   RDX = 行;
		lea		r13, [Task.Task_1]				;   task_ctrl = &Task_1;
		lea		r14, [Task.TaskEnd]				;   task_end  = &TaskEnd;
.12L:	cmp		r13, r14						;   while (task_ctrl < task_end)
		jae		.12E							;   {

		mov		rcx, TCTRL(r13, .buffer)		;     // タスク用バッファ
		add		rcx, TASK_CODE_MEMORY_SIZE		;     // タスクのデータセクション
		mov		rcx, TPARAM(rcx, .counter)		;     // 内部カウンタを取得
		xcall	itoa, rcx, [.counter], 16, 10, 0;     itoa();

		mov		rcx, COL(2)						;     RCX = 列;
		mov		rdx, r12						;     RDX = 行;
		mov		r8, COLOR_GRAY					;     R8 = 前景色;
		mov		r9, COLOR_DISPLAY_BG			;     R9 = 背景色;
		xcall	draw_str, rcx, rdx, r8, r9, [.counter]

		add		r12, ROW(1)						;     ROW++;
		add		r13, TASK_CTRL_size				;     task_ctrl++;

		jmp		.12L							; 
.12E:											;   }
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
.s6:	db	"Syscall initialized.", 0
.s7:	db	"SSE2 initialized.", 0
.s8:	db	" Power off...   ", 0
.t3:	db	" 3", 0
.t2:	db	" 2", 0
.t1:	db	" 1", 0

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
