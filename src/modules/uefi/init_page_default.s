;************************************************************************
;	ページングの設定（デフォルト）
;
;	2Mバイト単位で下位32ビット分のアドレス空間をリニアに配置
;	（0x00000000_00000000～0x00000000_FFFFFFFF）
;========================================================================
;■書式		: void init_page_default(task_ctrl);
;
;■引数
;	task_ctrl	: タスク管理情報
;
;■戻り値	: 無し
;************************************************************************
init_page_default:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
		FRAME_BEGIN								; // フレームの開始

		; 引数の定義
		%arg	task_ctrl:qword					; // 引数の定義

		; ローカル変数の定義
		%local	save_rsi:qword					; int save_rsi;
		%local	save_rdi:qword					; int save_rdi;

		FRAME_STACK								; // スタック領域の確保

		; レジスタの保存
		mov		[task_ctrl], rcx				; task_ctrl = RCX;
		mov		[save_rsi], rsi					; save_rsi = RSI;
		mov		[save_rdi], rdi					; save_rdi = RDI;

		;---------------------------------------
		; PML4テーブルをコピー
		;---------------------------------------
		mov		rsi, cr3						; // 現在のPML4T
		and		rsi, ~0x0FFF					; RSI = CR3 & ~0x0FFF;
		mov		rax, [task_ctrl]				; RAX = タスク管理情報;
		mov		rdi, TCTRL(rax, .cr3)			; RDI = PML4T;
		and		rdi, ~0x0FFF					; RDI = task_ctrl.cr3 & ~0x0FFF;
		mov		rcx, 512						; RCX = 512;
		cld										; // DFクリア（+方向）
		rep movsq								; while (rcx--) *rdi++ = *rsi++;

		;---------------------------------------
		; 先頭のPDPテーブルをコピー
		;---------------------------------------
		mov		rsi, cr3						; RSI = CR3;
		and		rsi, ~0x0FFF					; RSI &= ~0x0FFF;
		mov		rsi, [rsi]						; RSI = PML4T[0];
		and		rsi, ~0x0FFF					; RSI &= ~0x0FFF;
		mov		rax, [task_ctrl]				; RAX = タスク管理情報;
		mov		rdi, TCTRL(rax, .cr3)			; RDI = PML4T;
		add		rdi, 4096						; RDI += 4096;
		and		rdi, ~0x0FFF					; RDI = task_ctrl.cr3 & ~0x0FFF;
		mov		rcx, 512						; RCX = 512;
		cld										; // DFクリア（+方向）
		rep movsq								; while (rcx--) *rdi++ = *rsi++;

		;---------------------------------------
		; PML4テーブルの最初のエントリを設定
		;---------------------------------------
		mov		rax, [task_ctrl]				; RAX = タスク管理情報;
		mov		rdi, TCTRL(rax, .cr3)			; RDI = PML4T;
		lea		rax, [rdi + 4096 * 1 + 0x03]	; RAX = PDPT; // U/S=0, R/W=1, P=1
		stosq									; *RDI++ = RAX;

		;---------------------------------------
		; PDPテーブルの4エントリを設定
		;---------------------------------------
		mov		rax, [task_ctrl]				; RAX = タスク管理情報;
		mov		rdi, [rax + TASK_CTRL.cr3]		; RDI = PML4T;
		lea		rdi, [rdi + 4096 * 1]			; RDI = PDPT;
		lea		rax, [rdi + 4096 * 1 + 0x03]	; RAX = PDE; // U/S=0, R/W=1, P=1
		mov		rcx, 4							; RCX = 4;
												; do
.10L:											; {
		stosq									;   *RDI++ = RAX;
		add		rax, 1 << 12					;   RAX += 1 << 12; // インデックスを加算
		loop	.10L							; } while (--RCX);

		;---------------------------------------
		; PDを初期化（RING0）
		; 0x00000000_00000000～0x00000000_FFFFFFFFまで（512*4エントリ）
		;---------------------------------------
		mov		rax, [task_ctrl]				; RAX = タスク管理情報;
		mov		rdi, [rax + TASK_CTRL.cr3]		; RDI = PML4T;
		lea		rdi, [rdi + 4096 * 2]			; RDI = PDPT;
		mov		rax, 0x83						; RAX = PDE; // 2M=1, U/S=0, R/W=1, P=1
		mov		rcx, 512 * 4					; RCX = 512 * 4;
												; do
.20L:											; {
		stosq									;   *RDI++ = RAX;
		add		rax, 1 << 21					;   RAX += 1 << 21; // 2M加算
		loop	.20L							; } while (--RCX);

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		mov		rsi, [save_rsi]					; RSI = save_rsi;
		mov		rdi, [save_rdi]					; RDI = save_rdi;

		FRAME_END								; // フレームの終了
