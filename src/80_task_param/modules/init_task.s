;************************************************************************
;	タスクの初期化
;========================================================================
;■書式		: void init_task(void);
;
;■引数		: 無し
;
;■戻り値	: 無し
;************************************************************************
init_task:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
		FRAME_BEGIN								; // フレームの開始

		; ローカル変数の定義
		%local	task_ctrl:qword					; int task_ctrl;
		%local	task_ptr:qword					; int task_ptr;
		%local	task_id:qword					; int task_id;

		FRAME_STACK								; // スタック領域の確保

		;---------------------------------------
		; タスク用メモリの取得
		;---------------------------------------
		mov		rcx, [Task.BaseAddr]			; // 全タスク用メモリを取得
		add		rcx, (1 << 21)					; // 最初の2Mバイトは空けておく
		mov		[task_ptr], rcx					; task_ptr += 2M;

		;---------------------------------------
		; タスク毎の設定
		;---------------------------------------
		lea		rcx, [Task.Kernel]				; // 先頭タスクへのポインタ
		mov		[task_ctrl], rcx				; task_ctrl = &Task.Kernel;
		mov		qword [task_id], 0				; task_id = 0;
.10L:	mov		rcx, [task_id]					; 
		cmp		rcx, TASK_COUNT					; while (task_id < TASK_COUNT)
		jae		.10E							; {

		; メモリ領域の設定
		mov		rcx, [task_ctrl]				;   RCX = task_ctrl;
		mov		rdx, [task_ptr]					;   RDX = task_ptr;
		xcall	init_task_mem, rcx, rdx			;   init_task_mem();

		; エントリポイントの設定
		mov		rcx, [task_ctrl]				;   RCX = task_ctrl;
		mov		rdx, [task_id]					;   RDX = task_id;
		xcall	init_task_entry, rcx, rdx		;   init_task_entry();

		; タスク用データの初期化
		mov		rcx, [task_ctrl]				;   RCX = task_ctrl;
		xcall	init_task_data, rcx				;   init_task_data();

		; 次のタスク
		add		qword [task_ctrl], TASK_CTRL_size ; task_ctrl++;
		add		qword [task_ptr], (1 << 21)		;   task_ptr += 2M;
		inc		qword [task_id]					;   task_id++;
												;   
		jmp		.10L							;   
.10E:											; }

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		FRAME_END								; // フレームの終了

;************************************************************************
;	タスク用メモリの領域設定
;========================================================================
;■書式		: void init_task_mem(task_ctrl, task_mem);
;
;■引数
;	task_ctrl	: タスク管理情報
;	task_mem	: タスク用メモリ領域
;
;■戻り値	: 無し
;************************************************************************
init_task_mem:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
		FRAME_BEGIN								; // フレームの開始
		FRAME_STACK								; // スタック領域の確保

		;---------------------------------------
		; メモリ領域の設定
		;---------------------------------------
		; buff[0x0000_0000:0x001F_FFFF]			; // タスク用メモリ（2M）
		mov		TCTRL(rcx, .buffer), rdx		; task_ctrl.buffer = RDX;

		; RSP0（リング0用スタック領域:4K）
		mov		rax, rdx						; RAX = &buffer[0];
		add		rax, TASK_OFFSET_RSP0			; RAX += TASK_OFFSET_RSP0;
		mov		TCTRL(rcx, .rsp0), rax			; task_ctrl.rsp0 = RAX;

		; RSP（リング3用スタック領域:4K）
		mov		rax, rdx						; RAX = &buffer[0];
		add		rax, TASK_OFFSET_RSP			; RAX += TASK_OFFSET_RSP;
		mov		TCTRL(rcx, .rsp), rax			; task_ctrl.rsp = RAX;

		; SSEコンテキスト保存領域(8K)
		mov		rax, rdx						; RAX = &buffer[0];
		add		rax, TASK_OFFSET_SSE			; RAX += TASK_OFFSET_SSE;
		mov		TCTRL(rcx, .sse_context), rax	; task_ctrl.sse_context = RAX;
		mov		qword TCTRL(rcx, .sse_saved), 0	; task_ctrl.sse_saved = 0;

		; CR3（アドレス変換テーブル領域）
		mov		rax, rdx						; RAX = &buffer[0];
		add		rax, TASK_OFFSET_CR3			; RAX += TASK_OFFSET_CR3;
		mov		TCTRL(rcx, .cr3), rax			; task_ctrl.cr3 = RAX;

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		FRAME_END								; // フレームの終了

;************************************************************************
;	タスク毎のエントリポイントを設定
;========================================================================
;■書式		: void init_task_entry(task_ctrl, task_id);
;
;■引数
;	task_ctrl	: タスク管理情報
;	task_id		: タスクID
;
;■戻り値	: 無し
;************************************************************************
init_task_entry:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
		FRAME_BEGIN								; // フレームの開始
		FRAME_STACK								; // スタック領域の確保

		;---------------------------------------
		; タスク用データ設定
		;---------------------------------------
		lea		r10, [task_proc]				; RIP = task_proc;
		mov		r11, TCTRL(rcx, .rsp)			; RSP = task_ctrl.RSP;

		;---------------------------------------
		; タスクパラメータ設定
		;---------------------------------------
		mov		rdx, TCTRL(rcx, .buffer)		; RDX = task_ctrl.buffer;

		;---------------------------------------
		; 割り込み発生時のスタックを構成
		;---------------------------------------
		xchg	rsp, TCTRL(rcx, .rsp)			; // PUSH命令を使用するために入れ替え

		; IRETQ
		push	DS_TASK							; SS
		push	r11								; RSP
		push	0x0202							; EFLAGS
		push	CS_TASK							; CS 
		push	r10								; RIP

		; レジスタ
		push	0								; RAX
		push	0								; RBX
		push	0								; RCX
		push	0								; RDX
		push	0								; RBP
		push	0								; RSI
		push	0								; RDI
		push	0								; R8
		push	0								; R9
		push	0								; R10
		push	0								; R11
		push	0								; R12
		push	0								; R13
		push	0								; R14
		push	rdx								; R15

		; スタックを復帰
		xchg	rsp, TCTRL(rcx, .rsp)			; 

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		FRAME_END								; // フレームの終了

;************************************************************************
;	タスク用データの初期化
;========================================================================
;■書式		: void init_task_data(task_ctrl);
;
;■引数
;	task_ctrl	: タスク管理情報
;
;■戻り値	: 無し
;************************************************************************
init_task_data:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
		FRAME_BEGIN								; // フレームの開始

		; 引数の定義
		%arg	task_ctrl:qword					; int task_ctrl;

		FRAME_STACK								; // スタック領域の確保

		; レジスタの保存
		mov		[task_ctrl], rcx				; task_ctrl = RCX;

		;---------------------------------------
		; タスクパラメータのコピー
		;---------------------------------------
		mov		rax, [task_ctrl]				; 
		mov		rcx, TCTRL(rax, .buffer)		; RCX = コピー先;
		mov		rdx, TCTRL(rax, .param)			; RDX = コピー元;
		mov		r8, TASK_PARAM_size				; R8 = コピーバイト数;
		xcall	memcpy, rcx, rdx, r8			; memcpy();

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		FRAME_END								; // フレームの終了
