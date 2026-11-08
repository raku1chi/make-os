;************************************************************************
;	ステージ11
;========================================================================
;■書式		: void stage_11(void);
;
;■引数		: 無し
;
;■戻り値	: 無し
;************************************************************************
stage_11:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
		FRAME_BEGIN								; // フレームの開始
		FRAME_STACK								; // スタック領域の確保

		;---------------------------------------
		; タスク用メモリの確保
		;---------------------------------------
		mov		rcx, (TASK_COUNT + 2) * (1 << 21)	; // 1タスクにつき2M
		xcall	allocate_pool, rcx				; RAX = allocate_pool();
		mov		[Task.AllocPtr], rax			; Task.AllocPtr = RAX;

		; 2M境界に設定
		add		rax,  ((1 << 21) - 1)			; RAX +=  0x1F_FFFF;
		and		rax, ~((1 << 21) - 1)			; RAX &= ~0x1F_FFFF;
		mov		[Task.BaseAddr], rax			; Task.BaseAddr = RAX;

		xcall	htoa, qword [Task.AllocPtr], [.alloc], 8
		xcall	htoa, qword [Task.BaseAddr], [.base], 8

		;---------------------------------------
		; メモリマップの取得
		;---------------------------------------
		xcall	get_memory_map					; // メモリマップの取得

		;---------------------------------------
		; ブートサービスの終了
		;---------------------------------------
		xcall	exit_boot_service				; ExitBootServices();
		cmp		rax, 0							; if (0 == RAX)
		jne		.10F							; {
		xcall	puts, [.e0]						;   puts();
		jmp		.10E							;   return;
.10F:											; }

		;---------------------------------------
		; 画面の初期化
		;---------------------------------------
		mov		rcx, 0								; X0 = 0;
		mov		rdx, 0								; Y0 = 0;
		mov		r8, [Video.HorizontalResolution]	; X1 = HorizontalResolution;
		mov		r9, [Video.VerticalResolution]		; Y1 = VerticalResolution;
		xcall	fill_rect, rcx, rdx, r8, r9, \
					qword COLOR_DISPLAY_BG			; fill_rect();

		; タスクバー（矩形）
		mov		rcx, 0								; X0 = 0;
		mov		rdx, [Video.VerticalResolution]		; Y0 = VerticalResolution
		sub		rdx, TASK_BAR_H						;    - TASK_BAR_H;
		mov		r8, [Video.HorizontalResolution]	; X1 = 0;
		mov		r9, [Video.VerticalResolution]		; Y1 = VerticalResolution;
		xcall	fill_rect, rcx, rdx, r8, r9, \
					qword COLOR_TASK_BAR_BG

		; タスクバー（上部の白線）
		mov		rcx, 0								; X0 = 0;
		mov		rdx, [Video.VerticalResolution]		; Y0 = VerticalResolution
		sub		rdx, (TASK_BAR_H + 1)				;    - (TASK_BAR_H + 1);
		mov		r8, [Video.HorizontalResolution]	; X1 = 0;
		mov		r9, rdx								; Y1 = VerticalResolution;
		xcall	draw_line, rcx, rdx, r8, r9, \
					qword COLOR_TASK_BAR_TOP

		;---------------------------------------
		; メッセージの表示
		;---------------------------------------
		mov		r12, COL(1)								; R12 = 列;
		mov		r13, COLOR_TRANSPARENT | COLOR_WHITE	; R13 = 前景色
		mov		r14, COLOR_TRANSPARENT | COLOR_GRAY		; R14 = 前景色

		xcall	draw_str, r12, qword ROW(1), r13, 0, [.s0]
		xcall	draw_str, r12, qword ROW(2), r14, 0, [.s1]
		xcall	draw_str, r12, qword ROW(3), r14, 0, [.s2]

.10E:											; 

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		FRAME_END								; // フレームの終了

.s0:	db	"ExitBootServices.", 0
.e0:	db	"Failed ExitBootServices.", 0

;========================================================================
[section .data]
ALIGN 16, db 0
.s1:		db	" Mem alloc : "
.alloc:		db	"12345678", 0
.s2:		db	" Task base : "
.base:		db	"12345678", 0

;========================================================================
[section .text]
