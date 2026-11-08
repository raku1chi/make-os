;************************************************************************
;	TASK
;************************************************************************
[section .tcode]
TCODE:
task_proc:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
		FRAME_BEGIN								; // フレームの開始

		; ローカル変数の定義
		%local	x_pos:qword						; int x0;
		%local	y_pos:qword						; int x0;
		%local	x_origin:qword					; int x0;
		%local	y_origin:qword					; int y0;

		FRAME_STACK								; // スタック領域の確保

		;---------------------------------------
		; タスク起動時の処理
		;---------------------------------------
		lea		r15, [TDATA.param]				; R15 = タスクパラメータ

		;---------------------------------------
		; タイトルの表示
		;---------------------------------------
		mov		rdi, TPARAM(r15, .col)			; RDI = 第1引数;
		mov		rsi, TPARAM(r15, .row)			; RSI = 第2引数;
		mov		rdx, COLOR_GRAY					; RDX = 第3引数;
		mov		r10, COLOR_DISPLAY_BG			; R10 = 第4引数;
		lea		r8, TPARAM(r15, .title)			; R8 = 第5引数;
		scall	SYS_DRAW_STR					; syscall();

		;---------------------------------------
		; 座標計算（初期化）
		;---------------------------------------
		; X軸の中点
		mov		rcx, TPARAM(r15, .x0)			; RCX  = X0座標
		mov		rdx, TPARAM(r15, .x1)			; RDX  = X1座標
		sub		rdx, rcx						; RDX  = (X1 - X0);
		shr		rdx, 1							; RDX /= 2;
		add		rdx, rcx						; RDX += X0
		mov		[x_origin], rdx					; x0   = RDX; // X座標原点;

		; Y軸の中点
		mov		rcx, TPARAM(r15, .y0)			; RCX  = Y0座標
		mov		rdx, TPARAM(r15, .y1)			; RDX  = Y1座標
		sub		rdx, rcx						; RDX  = (Y1 - Y0);
		shr		rdx, 1							; RDX /= 2;
		add		rdx, rcx						; RDX += Y0
		mov		[y_origin], rdx					; y0   = RDX; // Y座標原点;

		; 振幅をX軸の約95%とする
		mov		rcx, TPARAM(r15, .x1)			; RCX  = X1座標;
		sub		rcx, TPARAM(r15, .x0)			; RCX -= X0座標;
		shr		rcx, 1							; RCX /= 2;
		mov		rdx, rcx						; RDX  = RCX;
		shr		rdx, 4							; RDX /= 16;
		sub		rcx, rdx						; RCX -= RDX;

		; XMM11:t
		mov		rax, 0							; // 角度
		cvtsi2sd xmm11, rax						; XMM11 = 0;

		; XMM12:A
		cvtsi2sd xmm12, rcx						; XMM12  = 振幅;

		; XMM13:k = n / d;
		cvtsi2sd xmm13, TPARAM(r15, .n)			; XMM13 = n;
		cvtsi2sd xmm0, TPARAM(r15, .d)			; XMM0  = d;
		divsd	xmm13, xmm0						; XMM13 /= XMM0;

		movsd	xmm14, [.delta]					; XMM14 = 加算値;
		movsd	xmm15, [.max_t]					; XMM15 = 最大値;

		;---------------------------------------
		; タイトルの表示
		;---------------------------------------
		mov		rdi, TPARAM(r15, .x0)			; RDI = 列;
		mov		rsi, TPARAM(r15, .y0)			; RSI = 行;
		sub		rsi, ROW(1)						; // 1行分上に移動
		mov		rdx, TPARAM(r15, .color_s)		; RDX = 文字色;
		mov		r10, TPARAM(r15, .color_e)		; RDX = 背景色;
		lea		r8, TPARAM(r15, .title)			; R10 = 文字列;
		scall	SYS_DRAW_STR					; syscall();

		;---------------------------------------
		; 枠の描画
		;---------------------------------------
		mov		rdi, TPARAM(r15, .x0)			; RDI = 列;
		mov		rsi, TPARAM(r15, .y0)			; RSI = 行;
		mov		rdx, TPARAM(r15, .x1)			; RDX = 列;
		mov		r10, TPARAM(r15, .y1)			; RSI = 行;
		lea		r8, [.area_colors]				; // 描画色
		scall	SYS_DRAW_FRAME					; syscall();

		;---------------------------------------
		; X軸の描画
		;---------------------------------------
		mov		rdi, TPARAM(r15, .x0)			; RDI = X0座標;
		mov		rsi, [y_origin]					; RSI = Y軸の中点;
		mov		rdx, TPARAM(r15, .x1)			; RDX = X1座標;
		mov		r10, [y_origin]					; R10 = Y軸の中点;
		mov		r8, TPARAM(r15, .color_x)		; R8 = 描画色;
		scall	SYS_DRAW_LINE					;   syscall();

		;---------------------------------------
		; Y軸の描画
		;---------------------------------------
		mov		rdi, [x_origin]					; RCX = X軸の中点;
		mov		rsi, TPARAM(r15, .y0)			; RDX = Y0座標;
		mov		rdx, [x_origin]					; R8  = X軸の中点;
		mov		r10, TPARAM(r15, .y1)			; R9  = Y1座標;
		mov		r8, TPARAM(r15, .color_y)		; R10 = 描画色;
		scall	SYS_DRAW_LINE					;   syscall();

		;---------------------------------------
		; メインループ
		;---------------------------------------
.10L:											; for ( ; ; )
												; {
		mov		rax, TPARAM(r15, .id)			;   // 内部カウンタの更新
		add		TPARAM(r15, .counter), rax		;   // タスクIDを加算

		;---------------------------------------
		; 座標計算
		;---------------------------------------
		; sin(kt)
		movsd	xmm0, xmm13						;   XMM0 = k;
		mulsd	xmm0, xmm11						;   XMM0 *= t;
		xcall	sin								;   sin();
		movsd	xmm7, xmm0						;   XMM7 = sin(kt);

		; cos(t)
		movsd	xmm0, xmm11						;   XMM0 = t;
		xcall	cos								;   cos();
		movsd	xmm8, xmm0						;   XMM8 = cos(t);

		; sin(t)
		movsd	xmm0, xmm11						;   XMM0 = t;
		xcall	sin								;   sin();
		movsd	xmm9, xmm0						;   XMM9 = sin(t);

		; X = A*sin(kt)*cos(t)
		movsd	xmm0, XMM12						;   XMM0 = A;
		mulsd	xmm0, xmm7						;   XMM0 *= sin(kt);
		mulsd	xmm0, xmm8						;   XMM0 *= cos(t);
		cvtsd2si rcx, xmm0						;   RCX = A*sin(kt)*cos(t);
		mov		[x_pos], rcx					;   x_pos = RCX;

		; Y = A*sin(kr)*sin(r)
		movsd	xmm0, XMM12						;   XMM0 = A;
		mulsd	xmm0, xmm7						;   XMM0 *= sin(kr);
		mulsd	xmm0, xmm9						;   XMM0 *= sin(r);
		cvtsd2si rcx, xmm0						;   RCX = Y = A*sin(kr)*sin(r);
		mov		[y_pos], rcx					;   y_pos = RCX;

		;---------------------------------------
		; ピクセルの描画
		;---------------------------------------
		mov		rdi, [x_origin]					; 
		add		rdi, [x_pos]					; 
		mov		rsi, [y_origin]					; 
		add		rsi, [y_pos]					; 
		mov		rdx, TPARAM(r15, .color_f)		; 
		scall	SYS_DRAW_PIXEL					;   syscall();

		;---------------------------------------
		; ウェイト
		;---------------------------------------
		scall	SYS_WAIT_TICK, 2				;   syscall();

		;---------------------------------------
		; ピクセルの消去
		;---------------------------------------
		mov		rdi, [x_origin]					; 
		add		rdi, [x_pos]					; 
		mov		rsi, [y_origin]					; 
		add		rsi, [y_pos]					; 
		mov		rdx, TPARAM(r15, .color_e)		; 
		scall	SYS_DRAW_PIXEL					;   syscall();

		;---------------------------------------
		; 角度更新
		;---------------------------------------
		addsd	xmm11, xmm14					;   t += θ;
		comisd	xmm11, xmm15					;   if (t < max_t)
		jbe		.14E							;   {
		mov		rax, 0							;     
		cvtsi2sd xmm11, rax						;     t = 0;
.14E:											;   }
												;   
		jmp		.10L							; }

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		FRAME_END								; // フレームの終了

ALIGN 16, db 0
.delta:		dq	0.01, 0
.max_t:		dq	314.15926535897, 0

.area_colors:									; 描画エリア
		dq	0x00_000000							; 背景色
		dq	0x00_777777							; 左
		dq	0x00_777777							; 上
		dq	0x00_F7F7F7							; 右
		dq	0x00_F7F7F7							; 下

;************************************************************************
;	モジュール
;************************************************************************
%include	"../modules/uefi/sin.s"

;========================================================================
[section .tdata]
TDATA:
ALIGN 16, db 0
.param:	times TASK_PARAM_size db 0

;========================================================================
[section .text]
