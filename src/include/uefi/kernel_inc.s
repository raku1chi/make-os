;************************************************************************
;	カーネル用定義
;************************************************************************
;---------------------------------------
; 割り込み設定マクロ
;---------------------------------------
%macro set_idt 2-*
		mov		rax, [IDTR + 2]			; IDTベースアドレス
		lea		rax, [rax + 16 * %1]	; RAX = IDT[%1];

		lea		rcx, [%2]				; RCX = handler;
		mov		[rax + 0], cx			; Offset[15: 0]
		shr		rcx, 16					; 
		mov		[rax + 6], cx			; Offset[31:16]
		shr		rcx, 16					; 
		mov		[rax + 8], ecx			; Offset[63:32]

		mov		word [rax + 2], cs		; Segment Selector

		mov		cx, (1 << 15)			; Pビット
		or		cx, (0x0E << 8)			; TYPE
		mov		[rax + 4], cx			; 
%endmacro

;---------------------------------------
; レジスタの保存と復帰
;---------------------------------------
%macro  push_all 0
		push	rax
		push	rbx
		push	rcx
		push	rdx
		push	rbp
		push	rsi
		push	rdi
		push	r8
		push	r9
		push	r10
		push	r11
		push	r12
		push	r13
		push	r14
		push	r15
%endmacro

%macro  pop_all 0
		pop		r15
		pop		r14
		pop		r13
		pop		r12
		pop		r11
		pop		r10
		pop		r9
		pop		r8
		pop		rdi
		pop		rsi
		pop		rbp
		pop		rdx
		pop		rcx
		pop		rbx
		pop		rax
%endmacro

;-----------------------------------------------
; ポート出力用
;-----------------------------------------------
%macro  outp 2
		mov		al, %2
		out		%1, al
%endmacro

;-----------------------------------------------
; リングバッファ
;-----------------------------------------------
%define		RING_ITEM_SIZE		(1 << 4)
%define		RING_INDEX_MASK		(RING_ITEM_SIZE - 1)

struc ring_buff
		.rp				resq	1				; RP:読み込み位置
		.wp				resq	1				; WP:書き込み位置
		.item			resb	RING_ITEM_SIZE	; バッファ
endstruc

;-----------------------------------------------
;	タスク管理用構造体
;-----------------------------------------------
struc TASK_CTRL
		QWORD			cs						; CS
		QWORD			ds						; DS
		QWORD			ss						; SS
		QWORD			es						; ES
		QWORD			fs						; FS
		QWORD			gs						; GS
		QWORD			rip						; RIP
		QWORD			rsp0					; RSP0
		QWORD			rsp						; RSP
		QWORD			cr3						; CR3
		QWORD			buffer					; タスク用バッファ
		QWORD			sse_saved				; SSE保存フラグ
		QWORD			sse_context				; SSEコンテキスト
		QWORD			param					; タスクパラメータ
endstruc

%define	TCTRL(adr, ofs)		[adr + TASK_CTRL %+ ofs]

;-----------------------------------------------
; TSS
;-----------------------------------------------
struc TSS
		DWORD			reserved_0				; 予約済み
		QWORD			RSP0					; RSP0
		QWORD			RSP1					; RSP1
		QWORD			RSP2					; RSP2
		QWORD			reserved_1				; 予約済み
		QWORD			IST1					; IST1
		QWORD			IST2					; IST2
		QWORD			IST3					; IST3
		QWORD			IST4					; IST4
		QWORD			IST5					; IST5
		QWORD			IST6					; IST6
		QWORD			IST7					; IST7
		QWORD			reserved_2				; 予約済み
		WORD			reserved_3				; 予約済み
		WORD			io_map_base				; I/Oマップのベース
endstruc

%macro  set_tss 2-* 
		lea		rdx, %1							; ディスクリプタアドレス
		lea		rax, %2							; ベースアドレス

		mov		[rdx + 2], ax					; ベース（[15: 0]）
		shr		rax, 16							; 
		mov		[rdx + 4], al					; ベース（[23:16]）
		mov		[rdx + 7], ah					; ベース（[31:24]）
		shr		rax, 16							; 
		mov		[rdx + 8], eax					; ベース（[63:32]）
%endmacro

;-----------------------------------------------
; タスク用バッファの設定
;-----------------------------------------------
		TASK_OFFSET_RSP0	equ		0x0010_1000
		TASK_OFFSET_RSP		equ		0x0010_2000
		TASK_OFFSET_SSE		equ		0x0010_2000
		TASK_OFFSET_CR3		equ		0x0010_4000
