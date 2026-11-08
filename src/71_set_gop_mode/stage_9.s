;************************************************************************
;	ステージ9
;========================================================================
;■書式		: void stage_9(void);
;
;■引数		: 無し
;
;■戻り値	: 無し
;************************************************************************
stage_9:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
		FRAME_BEGIN								; // フレームの開始

		; ローカル変数の定義
		%local	second:qword					; int second;

		FRAME_STACK								; // スタック領域の確保

		;---------------------------------------
		; 処理
		;---------------------------------------
		xcall	puts, [.s0]						; puts();

		;---------------------------------------
		; APIC BASE アドレスの取得
		;---------------------------------------
		mov		ecx, 0x001b						; IA32_APIC_BASE MSR
		rdmsr									; EDX:EAX = rdmsr();
		and		eax, ~0x0FFF					; EAX &= ~0x0FFF;
		mov		[APIC.Base + 0], eax			; APIC.Base[31:0] = EAX;
		mov		[APIC.Base + 4], edx			; APIC.Base[63:32] = EDX;

		;---------------------------------------
		; 秒の取得
		;---------------------------------------
		xcall	get_time, [EfiTime]				; get_time();
												; 
		mov		cl, [EfiTime + EFI_TIME.Second]	; CL = EFI_TIME.Second;
		mov		[second], cl					; second = CL;

		;---------------------------------------
		; 秒が変化するまで待つ
		;---------------------------------------
.10L:											; do
												; {
		xcall	get_time, [EfiTime]				;   get_time();
												;   
		mov		cl, [EfiTime + EFI_TIME.Second]	;   CL = EFI_TIME.Second;
		cmp		[second], cl					;   ZF = EfiSec == CL;
		je		.10L							; } while (ZF);

		; 変化した秒を保存
		mov		[second], cl					; second = CL;

		;---------------------------------------
		; カウント開始
		;---------------------------------------
		mov		rax, [APIC.Base]				; // APICベースアドレスを設定
		mov		LAPIC(rax, .ICR), 0				; ICR = 0; // カウント停止
		mov		LAPIC(rax, .LVT_TR), 0x0001_0000; Mask = 1; // 割り込みマスク
		mov		LAPIC(rax, .DCR), 0				; DIV = 0; // 分周比2倍
		mov		LAPIC(rax, .ICR), -1			; ICR = -1; // カウント開始

		;---------------------------------------
		; 再度、秒が変化するまで待つ
		;---------------------------------------
.20L:											; do
												; {
		xcall	get_time, [EfiTime]				;   get_time();
												;   
		mov		cl, [EfiTime + EFI_TIME.Second]	;   CL = EFI_TIME.Second;
		cmp		[second], cl					;   ZF = EfiSec == CL;
		je		.20L							; } while (ZF);

		;---------------------------------------
		; カウント値を取得
		;---------------------------------------
		mov		rax, [APIC.Base]				; // APICベースアドレスを設定
		mov		ecx, LAPIC(rax, .CCR)			; RCX = CCR; // カウント値を取得
		mov		LAPIC(rax, .ICR), 0				; ICR = 0; // カウント停止
												; 
		neg		ecx								; RCX *= -1; // 符号反転
		mov		[Timer.Interval], rcx			; Interval = RCX;

		;---------------------------------------
		; 得られたを表示
		;---------------------------------------
		mov		rcx, [APIC.Base]				; RCX = Base;
		xcall	htoa, rcx, [.base], 17			; htoa();

		mov		rcx, [Timer.Interval]			; RCX = Interval;
		xcall	htoa, rcx, [.interval], 8		; htoa();

		xcall	puts, [.s1]						; puts();

		;---------------------------------------
		; キー入力待ち
		;---------------------------------------
		xcall	puts, [Const.PressAnyKey]		; puts();
		xcall	read_key						; read_key();
		xcall	puts, [Const.ClearMessage]		; puts();

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		FRAME_END								; // フレームの終了

.s0:	db	"Wait a second...", 0x0D, 0x0A, 0

;========================================================================
[section .data]
ALIGN 16, db 0
.s1:		db	" APIC Base     : "
.base:		db	"12345678_12345678", 0x0D, 0x0A
			db	" APIC Interval : "
.interval:	db	"12345678", 0x0D, 0x0A, 0

;========================================================================
[section .text]
