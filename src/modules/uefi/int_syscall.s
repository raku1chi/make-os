;************************************************************************
;	syscall割り込み (rdi, rsi, rdx, r10, r8, r9)
;		RAX = 割り込み番号;
;		RCX = RIP（戻り番地）
;		R11 = FLAGS
;************************************************************************
int_syscall:
		xchg	[Task.TSS + TSS.RSP0], rsp		; TSS.RSP0 <=> RSP;
		push	rsp								; RSP
		push	r11								; FLAGS
		push	rcx								; 戻り番地
		push	rax								; 割り込み番号

		push	r9								; 第6引数
		push	r8								; 第5引数
		push	r10								; 第4引数
		push	rdx								; 第3引数
		push	rsi								; 第2引数
		push	rdi								; 第1引数
		push	0								; 戻り番地

		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
		FRAME_BEGIN								; // フレームの開始

		%arg	arg_rdi:qword					; // 第1引数
		%arg	arg_rsi:qword					; // 第2引数
		%arg	arg_rdx:qword					; // 第3引数
		%arg	arg_r10:qword					; // 第4引数
		%arg	arg_r8:qword					; // 第5引数
		%arg	arg_r9:qword					; // 第6引数

		%arg	arg_rax:qword					; // 割り込み番号
		%arg	arg_rcx:qword					; // 戻り番地
		%arg	arg_r11:qword					; // EFLAGS
		%arg	arg_rsp:qword					; // RSP

		; ローカル変数の定義
		%local	addr_ofs:qword					; int addr_ofs;

		FRAME_STACK								; // スタック領域の確保

		; TSS.RSP0の復帰
		mov		rax, [arg_rsp]					; // RSP0を復帰
		xchg	[Task.TSS + TSS.RSP0], rax		; TSS.RSP0 = RAX;
		mov		[arg_rsp], rax					; // RSPを設定

		sti										; // 割り込み許可

		;---------------------------------------
		; アドレスの差分を取得
		;---------------------------------------
		mov		rax, cr3						; RAX = CR3;
		and		rax, ~((1 << 21) - 1)			; RAX &= ~0x1F_FFFF;
		sub		rax, [Task.BaseAddr]			; RAX -= Task.BaseAddr;
		mov		[addr_ofs], rax					; addr_ofs = RAX;

		;---------------------------------------
		; 引数の入れ替え
		;---------------------------------------
		mov		rcx, [arg_rdi]					; RCX = 第1引数; // RDI;
		mov		rdx, [arg_rsi]					; RDX = 第2引数; // RSI;
		mov		r8, [arg_rdx]					; R8 = 第3引数; // RDX;
		mov		r9, [arg_r10]					; R9 = 第4引数; // R10;
		mov		r10, [arg_r8]					; R10 = 第5引数; // R8;
		mov		r11, [arg_r9]					; R11 = 第6引数; // R9;

		;---------------------------------------
		; システムコール番号による処理
		;---------------------------------------
		mov		rax, [arg_rax]						; RAX = システムコール番号;
		cmp		rax, SYS_DRAW_STR					; switch (RAX)
		je		.draw_str							; 
		cmp		rax, SYS_ITOA						; 
		je		.itoa								; 
		cmp		rax, SYS_DRAW_PIXEL					; 
		je		.draw_pixel							; 
		cmp		rax, SYS_DRAW_LINE					; 
		je		.draw_line							; 
		cmp		rax, SYS_DRAW_FRAME					; 
		je		.draw_frame							; 
%ifdef USE_SYS_WAIT_TICK
		cmp		rax, SYS_WAIT_TICK					; 
		je		.wait_tick							; 
%endif
		jmp		.10E								; {
.draw_str:											;   case SYS_DRAW_STR:
		add		r10, [addr_ofs]						;     
		xcall	draw_str, rcx, rdx, r8, r9, r10		;     draw_str();
		jmp		.10E								;     break;
													;     
.itoa:												;   case SYS_ITOA:
		add		rdx, [addr_ofs]						;     
		xcall	itoa, rcx, rdx, r8, r9, r10			;     itoa();
		jmp		.10E								;     break;
													;     
.draw_pixel:										;   case SYS_DRAW_PIXEL:
		xcall	draw_pixel, rcx, rdx, r8			;     draw_pixel();
		jmp		.10E								;     break;
													;     
.draw_line:											;   case SYS_DRAW_LINE:
		xcall	draw_line, rcx, rdx, r8, r9, r10	;     draw_line();
		jmp		.10E								;     break;
													;     
.draw_frame:										;   case SYS_DRAW_FRAME:
		add		r10, [addr_ofs]						;     
		xcall	draw_frame, rcx, rdx, r8, r9, r10	;     draw_frame();
		jmp		.10E								;     break;
													;     
%ifdef USE_SYS_WAIT_TICK
.wait_tick:											;   case SYS_WAIT_TICK:
		xcall	wait_tick, rcx						;     wait_tick();
		jmp		.10E								;     break;
%endif
.10E:												; }

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		mov		rdi, [arg_rdi]					; RDI = arg_rdi;
		mov		rsi, [arg_rsi]					; RSI = arg_rsi;
		mov		rdx, [arg_rdx]					; RDX = arg_rdx;
		mov		r10, [arg_r10]					; R10 = arg_r10;
		mov		r8, [arg_r8]					; R8 = arg_r8;
		mov		r9, [arg_r9]					; R9 = arg_r9;

		mov		r11, [arg_r11]					; R11 = arg_r11; // フラグ
		mov		rcx, [arg_rcx]					; RCX = arg_rcx; // 戻り番地

		mov		rsp, rbp						; // RSPの復帰
		pop		rbp								; // RBPの復帰

		add		rsp, 8 * 10						; // 引数のスタックを削除
		pop		rsp								; RING3のRSP

		o64 sysret
		%pop
