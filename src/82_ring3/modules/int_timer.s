;************************************************************************
;	タイマー割り込み
;************************************************************************
int_timer:
		;---------------------------------------
		; 【レジスタの保存】
		;---------------------------------------
		push_all								; // レジスタの保存

		;---------------------------------------
		; 割り込みフラグをクリア(EOI)
		;---------------------------------------
		mov		rax, [APIC.Base]				; 
		mov		LAPIC(rax, .EOI), 0				; LAPIC.EOI = 0;

		;---------------------------------------
		; TICK
		;---------------------------------------
		inc		qword [Timer.Counter]			; Timer.Counter++;

		;---------------------------------------
		; スタックポインタを保存
		;---------------------------------------
		mov		rax, [Task.Current]				; RAX = 現在のタスク;
		mov		cx, ss							; // SSを保存
		mov		TCTRL(rax, .ss), cx				; Task.SS = SS;
		cmp		cx, 0							; if (0 == SS)
		jne		.10F							; {
												;   // RING3 → RING0
		mov		TCTRL(rax, .rsp0), rsp			;   TaskCtrl.RSP0 = RSP;
		jmp		.10E							; }
.10F:											; else
												; {
												;   // RING0 → RING0
		mov		TCTRL(rax, .rsp), rsp			;   TaskCtrl.RSP = RSP;
.10E:											; }

		;---------------------------------------
		; タスクの切り替え
		;---------------------------------------
		mov		rax, [Task.Current]				; ptr = Task.Current;
		add		rax, TASK_CTRL_size				; ptr += sizeof(TASK_CTRL);
		lea		rcx, [Task.TaskEnd]				; end = &Task.TaskEnd;
		cmp		rax, rcx						; if (end <= ptr)
		jb		.20E							; {
		lea		rax, [Task.Kernel]				;   ptr = &Task.Kernel;
.20E:											; }

		mov		[Task.Current], rax				; Task.Current = ptr;

		;---------------------------------------
		; スタックポインタを復帰
		;---------------------------------------
		mov		cx, TCTRL(rax, .ss)				; 
		cmp		cx, 0							; if (SS == 0)
		jne		.30F							; {
												;   // RING3 → RING0
		mov		r10, TCTRL(rax, .rsp0)			;   R10 = TaskCtrl.RSP0;
		jmp		.30E							; }
.30F:											; else
												; {
												;   // RING0 → RING0
		mov		r10, TCTRL(rax, .rsp)			;   R10 = TaskCtrl.RSP;
.30E:											; }

		mov		rcx, TCTRL(rax, .buffer)		; RCX = Current.buffer;
		add		rcx, TASK_OFFSET_RSP0			; RAX += TASK_OFFSET_RSP0;
		mov		[Task.TSS + TSS.RSP0], rcx		; TSS.RSP0 = TaskCtrl.RSP0;

		;---------------------------------------
		; コンテキストを復帰
		;---------------------------------------
		mov		r11, TCTRL(rax, .ds)			; R11 = TaskCtrl.DS;
		mov		r12, TCTRL(rax, .es)			; R12 = TaskCtrl.ES;
		mov		r13, TCTRL(rax, .fs)			; R13 = TaskCtrl.FS;
		mov		r14, TCTRL(rax, .gs)			; R14 = TaskCtrl.GS;
		mov		r15, TCTRL(rax, .cr3)			; R15 = TaskCtrl.CR3;

		mov		rsp, r10						; RSP = TaskCtrl.RSP;
		mov		ds, r11							; DS = TaskCtrl.DS;
		mov		es, r12							; ES = TaskCtrl.ES;
		mov		fs, r13							; FS = TaskCtrl.FS;
		mov		gs, r14							; GS = TaskCtrl.GS;
		mov		cr3, r15						; CR3 = TaskCtrl.CR3;

		;---------------------------------------
		; 【レジスタの復帰】
		;---------------------------------------
		pop_all									; // レジスタの復帰
		iretq
