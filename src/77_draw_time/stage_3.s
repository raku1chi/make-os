;************************************************************************
;	ステージ3
;========================================================================
;■書式		: void stage_3(void);
;
;■引数		: 無し
;
;■戻り値	: 無し
;************************************************************************
stage_3:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
		FRAME_BEGIN								; // フレームの開始

		; ローカル変数の定義
		%local	begin:qword						; DESCRIPTOR* begin;
		%local	end:qword						; DESCRIPTOR* end;
		%local	desc:oword						; DESCRIPTOR desc; // 16バイト
		%local	selector:qword					; int selector;

		FRAME_STACK								; // スタック領域の確保

		;---------------------------------------
		; IDTの表示
		;---------------------------------------
		xcall	puts, [.s0]						; puts();
												; 
		sidt	[IDTR]							; // 割り込みディスクリプタテーブルを保存
												; 
		mov		rcx, [IDTR.Base]				; // IDTベースアドレスを設定
		mov		[begin], rcx					; begin = IDT Base;
												; 
		mov		rdx, 16 * 8						; // 最初の8エントリのみ表示
		add		rcx, rdx						; end = begin + len;
		mov		[end], rcx						; 
												; 
		mov		qword [selector], 0				; selector = 0;
.10L:	mov		rcx, [begin]					; while (begin < end)
		cmp		rcx, [end]						; {
		jae		.10E							;   
												;   
		; ディスクリプタを取得
		mov		r8, [rcx + 0]					;   desc = *begin;
		mov		r9, [rcx + 8]					;   
		mov		[desc + 0], r8					;   
		mov		[desc + 8], r9					;   
												; 
		; セレクタ
		mov		rcx, [selector]					;   RCX = selector;
		xcall	htoa, rcx, [.selector], 2		;   htoa();
												; 
		; ディスクリプタ全体
		mov		rcx, [desc + 8]					;   RCX = DESC[95:64];
		xcall	htoa, rcx, [.desc_hi], 8		;   htoa();
		mov		rcx, [desc]						;   RCX = DESC[63:0];
		xcall	htoa, rcx, [.desc], 17			;   htoa();
												; 
		; オフセット
		mov		cx, [desc + 6]					;   CX = desc[31:16];
		shl		rcx, 16							;   RCX << 16;
		mov		cx, [desc]						;   CX = desc[15:0];
		xcall	htoa, rcx, [.offset], 8			;   htoa();
												; 
		; DPL
		mov		rcx, [desc]						;   RCX = desc;
		shr		rcx, 45							;   RCX >>= 45;
		and		rcx, 0b0011						;   RCX &= 0b0011;
		xcall	htoa, rcx, [.dpl], 1			;   htoa();
												; 
		; TYPE
		mov		rcx, [desc]						;   RCX = desc;
		shr		rcx, 40							;   RCX >>= 40;
		and		rcx, 0b1111						;   RCX &= 0b1111;
		xcall	htoa, rcx, [.type], 1			;   htoa();
												; 
		; IST
		mov		rcx, [desc]						;   RCX = desc;
		shr		rcx, 32							;   RCX >>= 32;
		and		rcx, 0b0111						;   RCX &= 0x07;
		xcall	htoa, rcx, [.ist], 1			;   htoa();
												; 
		; SS
		mov		rcx, [desc]						;   RCX = desc;
		shr		rcx, 16							;   RCX >>= 16;
		and		rcx, 0xFFFF						;   RCX &= 0xFFFF;
		xcall	htoa, rcx, [.ss], 4				;   htoa();
												; 
		; 文字列を出力
		xcall	puts, [.s1]						;   puts();
												; 
		; 次のディスクリプタを設定
		add		qword [selector], 16			;   selector += 16;
		add		qword [begin], 16				;   begin++;
												; 
		jmp		.10L							; }
.10E:

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

.s0:	db	"IDT(Interrupt Descriptor Table)", 0x0D, 0x0A, 0

;========================================================================
[section .data]
.s1:		db	" "
.selector:	db	"12", " : "
.desc_hi:	db	"12345678", "_"
.desc:		db	"12345678_12345678", " (Offset="
.offset:	db	"12345678", " DPL="
.dpl:		db	"1", " TYPE="
.type:		db	"1", " IST="
.ist:		db	"1", " SS="
.ss:		db	"1234", ")"
			db	0x0D, 0x0A, 0

;========================================================================
[section .text]
