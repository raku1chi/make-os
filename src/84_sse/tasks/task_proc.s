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
		; 初期化処理
		;---------------------------------------
		cvtsi2sd xmm12, TPARAM(r15, .id)		; // 初期値
		mulsd	xmm12, [math.pi_2]				; XMM12 = TaskID * (π / 2);
		movsd	xmm13, [.delta]					; // 加算値
		movsd	xmm14, [.max_t]					; // 最大値
		movsd	xmm15, [.c1000]					; // 整数取得時の倍率

		mov		rax, TPARAM(r15, .id)			; // 関数ポインタの設定
		cmp		rax, 2							; if (2 < id)
		ja		.08F							; {
		lea		rcx, [sin]						;   RCX = sin;
		jmp		.08E							; }
												; else
.08F:											; {
		lea		rcx, [cos]						;   RCX = cos;
.08E:											; }
		mov		[TDATA.func], rcx				; func = RCX;

		;---------------------------------------
		; メインループ
		;---------------------------------------
.10L:											; for ( ; ; )
												; {
		mov		rax, TPARAM(r15, .id)			;   // 内部カウンタの更新
		add		TPARAM(r15, .counter), rax		;   // タスクIDを加算

		;---------------------------------------
		; sin/cosの計算
		;---------------------------------------
		movsd	xmm0, xmm12						;   XMM0 = t;
		xcall	[TDATA.func]					;   (*func)();

		; 定数倍した整数を取得
		mulsd	xmm0, xmm15						;   XMM0 *= 1000;
		cvtsd2si rcx, xmm0						;   RCX = (int)XMM0;

		; 文字列に変換
		scall	SYS_ITOA, rcx, [TDATA.sin], 5, 10, 7

		; 文字列に小数点を挿入
		mov		eax, [TDATA.point]				;   EAX = "2345";
		shl		eax, 8							;   EAX = "234";
		mov		al, '.'							;   EAX = ".234"
		mov		[TDATA.point], eax				; 

		; 画面に表示
		mov		rdi, TPARAM(r15, .col)			;   RDI = 第1引数;
		add		rdi, COL(10)					;   // 表示位置を右に移動
		mov		rsi, TPARAM(r15, .row)			;   RSI = 第2引数;
		mov		rdx, COLOR_GRAY					;   RDX = 第3引数;
		mov		r10, COLOR_DISPLAY_BG			;   R10 = 第4引数;
		lea		r8, [TDATA.sin]					;   R8 = 第5引数;
		scall	SYS_DRAW_STR					;   syscall();

		;---------------------------------------
		; 角度更新
		;---------------------------------------
		addsd	xmm12, xmm13					;   t += θ;
		comisd	xmm12, xmm14					;   if (t < max_t)
		jbe		.14E							;   {
		mov		rax, 0							;     
		cvtsi2sd xmm12, rax						;     t = 0;
.14E:											;   }
												;   
		jmp		.10L							; }

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		FRAME_END								; // フレームの終了

ALIGN 16, db 0
.delta:		dq	0.0001, 0
.c1000:		dq	1000.0, 0
.max_t:		dq	314.15926535897, 0

;************************************************************************
;	モジュール
;************************************************************************
%include	"../modules/uefi/sin.s"

;========================================================================
[section .tdata]
TDATA:
ALIGN 16, db 0
.param:	times TASK_PARAM_size db 0

ALIGN 16, db 0
.func:		dq	0
.sin:		db	"+1"
.point:		db	".234", 0

;========================================================================
[section .text]
