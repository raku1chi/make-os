;************************************************************************
;	ステージ1
;========================================================================
;■書式		: void stage_1(void);
;
;■引数		: 無し
;
;■戻り値	: 無し
;************************************************************************
stage_1:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
		FRAME_BEGIN								; // フレームの開始

		; ローカル変数の定義
		%local	save_rbx:qword					; void* save_rbx;
		%local	save_r12:qword					; void* save_r12;
		%local	save_r13:qword					; void* save_r13;
		%local	save_r14:qword					; void* save_r14;
		%local	save_r15:qword					; void* save_r15;

		FRAME_STACK								; // スタック領域の確保

		; レジスタの保存
		mov		[save_rbx], rbx					; save_rbx = RBX;
		mov		[save_r12], r12					; save_r12 = R12;
		mov		[save_r13], r13					; save_r13 = R13;
		mov		[save_r14], r14					; save_r14 = R14;
		mov		[save_r15], r15					; save_r15 = R15;

		;---------------------------------------
		; コントロールレジスタの表示
		;---------------------------------------
		xcall	puts, [.s0]						; puts();

		; CR0
		xcall	htoa, cr0, [.s17b], 17			; htoa();
		xcall	puts, [.sCR0]					; puts();
		xcall	puts, [.s17b]					; puts();

		; CR2
		xcall	htoa, cr2, [.s17b], 17			; htoa();
		xcall	puts, [.sCR2]					; puts();
		xcall	puts, [.s17b]					; puts();

		; CR3
		xcall	htoa, cr3, [.s17b], 17			; htoa();
		xcall	puts, [.sCR3]					; puts();
		xcall	puts, [.s17b]					; puts();

		; CR4
		xcall	htoa, cr4, [.s17b], 17			; htoa();
		xcall	puts, [.sCR4]					; puts();
		xcall	puts, [.s17b]					; puts();

		;---------------------------------------
		; CPUIDの表示
		;---------------------------------------
		; ベンダIDストリング
		mov		eax, 0x00000000					; CPUID(EAX=0x00000000)
		cpuid									; CPUID();
		mov		[.s1_EBX], ebx					; .sEBX = EBX;
		mov		[.s1_EDX], edx					; .sEDX = EDX;
		mov		[.s1_ECX], ecx					; .sECX = ECX;
		xcall	puts, [.s1]						; puts();

		; 拡張機能フラグ
		mov		eax, 0x80000001					; EAX = 0x80000001;
		cpuid									; CPUID();
		mov		r12, rax						; R12 = RAX;
		mov		r13, rbx						; R13 = RBX;
		mov		r14, rcx						; R14 = RCX;
		mov		r15, rdx						; R15 = RDX;

		xcall	htoa, 0x80000001, [.s2_ID], 8	; htoa();
		xcall	htoa, r12, [.s2_EAX], 8			; htoa();
		xcall	htoa, r13, [.s2_EBX], 8			; htoa();
		xcall	htoa, r14, [.s2_ECX], 8			; htoa();
		xcall	htoa, r15, [.s2_EDX], 8			; htoa();
		xcall	puts, [.s2]						; puts();

		; 拡張アドレスサイズ
		mov		eax, 0x80000008					; EAX = 0x80000008;
		cpuid									; CPUID();
		mov		r12, rax						; R12 = RAX;
		mov		r13, rbx						; R13 = RBX;
		mov		r14, rcx						; R14 = RCX;
		mov		r15, rdx						; R15 = RDX;

		xcall	htoa, 0x80000008, [.s2_ID], 8	; htoa();
		xcall	htoa, r12, [.s2_EAX], 8			; htoa();
		xcall	htoa, r13, [.s2_EBX], 8			; htoa();
		xcall	htoa, r14, [.s2_ECX], 8			; htoa();
		xcall	htoa, r15, [.s2_EDX], 8			; htoa();
		xcall	puts, [.s2]						; puts();

		;---------------------------------------
		; MSRの表示
		;---------------------------------------
		xcall	puts, [.s3]						; puts();

		; ECX=IA32_EFER
		mov		ecx, 0xC0000080					; ECX = 0xC0000080;
		rdmsr									; rdmsr();
		mov		r12, rax						; R12 = RAX;
		mov		r13, rdx						; R13 = RDX;

		xcall	htoa, 0xC0000080, [.s4_ECX], 8	; htoa();
		xcall	htoa, r12, [.s4_EAX], 8			; htoa();
		xcall	htoa, r13, [.s4_EDX], 8			; htoa();
		xcall	puts, [.s4]						; puts();

		; ECX=IA32_APIC_BASE
		mov		ecx, 0x0000001B					; ECX = 0x0000001B;
		rdmsr									; rdmsr();
		mov		r12, rax						; R12 = RAX;
		mov		r13, rdx						; R13 = RDX;

		xcall	htoa, 0x0000001B, [.s4_ECX], 8	; htoa();
		xcall	htoa, r12, [.s4_EAX], 8			; htoa();
		xcall	htoa, r13, [.s4_EDX], 8			; htoa();
		xcall	puts, [.s4]						; puts();

		;---------------------------------------
		; キー入力待ち
		;---------------------------------------
		xcall	puts, [Const.PressAnyKey]		; puts();
		xcall	read_key						; read_key();
		xcall	puts, [Const.ClearMessage]		; puts();

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		mov		rbx, [save_rbx]					; RBX = save_rbx;
		mov		r12, [save_r12]					; R12 = save_r12;
		mov		r13, [save_r13]					; R13 = save_r13;
		mov		r14, [save_r14]					; R14 = save_r14;
		mov		r15, [save_r15]					; R15 = save_r15;
		FRAME_END								; // フレームの終了

;========================================================================
[section .data]
.s0:		db	"Control Register", 0x0D, 0x0A, 0
.sCR0:		db	" CR0          : ", 0
.sCR2:		db	" CR2          : ", 0
.sCR3:		db	" CR3          : ", 0
.sCR4:		db	" CR4          : ", 0
.s17b:		db	"12345678_12345678", 0x0D, 0x0A, 0
.s1:		db	"CPUID(", 
.s1_EBX:	db	"----"
.s1_EDX:	db	"----"
.s1_ECX:	db	"----)", 0x0D, 0x0A, 0
.s2:		db	" EAX="
.s2_ID:		db	"12345678", " : EAX="
.s2_EAX:	db	"12345678", " EBX="
.s2_EBX:	db	"12345678", " ECX="
.s2_ECX:	db	"12345678", " EDX="
.s2_EDX:	db	"12345678", 0x0D, 0x0A, 0
.s3:		db	"MSR(Model Specific Register)", 0x0D, 0x0A, 0
.s4:		db	" ECX="
.s4_ECX:	db	"12345678", " : EDX="
.s4_EDX:	db	"12345678", " EAX="
.s4_EAX:	db	"12345678", 0x0D, 0x0A, 0

;========================================================================
[section .text]
