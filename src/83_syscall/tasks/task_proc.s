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
		; タスク情報の表示
		;---------------------------------------
		scall	SYS_ITOA, cs, [TDATA.cs], 4, 16, 4		;   syscall();
		scall	SYS_ITOA, ds, [TDATA.ds], 4, 16, 4		;   syscall();
		lea		rdi, [task_proc]
		scall	SYS_ITOA, rdi, [TDATA.rip], 8, 16, 4	;   syscall();
		scall	SYS_ITOA, rsp, [TDATA.rsp], 8, 16, 4	;   syscall();

		mov		rdi, TPARAM(r15, .col)			; RDI = 第1引数;
		add		rdi, COL(7)						; // タイトル分移動
		mov		rsi, TPARAM(r15, .row)			; RSI = 第2引数;
		mov		rdx, COLOR_GRAY					; RDX = 第3引数;
		mov		r10, COLOR_DISPLAY_BG			; R10 = 第4引数;
		lea		r8, [TDATA.s1]					; R8 = 第5引数;
		scall	SYS_DRAW_STR					; syscall();

		;---------------------------------------
		; メインループ
		;---------------------------------------
.10L:											; for ( ; ; )
												; {
		mov		rax, TPARAM(r15, .id)			;   // 内部カウンタの更新
		add		TPARAM(r15, .counter), rax		;   // タスクIDを加算
												;   
		jmp		.10L							; }

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		FRAME_END								; // フレームの終了

;========================================================================
[section .tdata]
TDATA:
ALIGN 16, db 0
.param:	times TASK_PARAM_size db 0

.s1:		db	"CS="
.cs:		db	"1234", ", DS="
.ds:		db	"1234", ", RIP="
.rip:		db	"12345678", ", RSP="
.rsp:		db	"12345678", 0

;========================================================================
[section .text]
