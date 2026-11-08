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
		mov		rax, [Task.Current]				; // RSPの保存
		mov		TCTRL(rax, .rsp), rsp			; TaskCtrl.RSP = RSP;

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
		; コンテキストを復帰
		;---------------------------------------
		mov		r10, TCTRL(rax, .rsp)			; R10 = TaskCtrl.RSP;
		mov		r11, TCTRL(rax, .ds)			; R11 = TaskCtrl.DS;
		mov		r12, TCTRL(rax, .es)			; R12 = TaskCtrl.ES;
		mov		r13, TCTRL(rax, .fs)			; R13 = TaskCtrl.FS;
		mov		r14, TCTRL(rax, .gs)			; R14 = TaskCtrl.GS;

		mov		rsp, r10						; RSP = TaskCtrl.RSP;
		mov		ds, r11							; DS = TaskCtrl.DS;
		mov		es, r12							; ES = TaskCtrl.ES;
		mov		fs, r13							; FS = TaskCtrl.FS;
		mov		gs, r14							; GS = TaskCtrl.GS;

		;---------------------------------------
		; 【レジスタの復帰】
		;---------------------------------------
		pop_all									; // レジスタの復帰
		iretq
