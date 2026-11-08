;************************************************************************
;	ステージ2
;========================================================================
;■書式		: void stage_2(void);
;
;■引数		: 無し
;
;■戻り値	: 無し
;************************************************************************
stage_2:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
		FRAME_BEGIN								; // フレームの開始

		; ローカル変数の定義
		%local	begin:qword						; DESCRIPTOR* begin;
		%local	end:qword						; DESCRIPTOR* end;
		%local	desc:qword						; DESCRIPTOR desc;
		%local	selector:qword					; int selector;

		FRAME_STACK								; // スタック領域の確保

		;---------------------------------------
		; GDTの表示
		;---------------------------------------
		xcall	puts, [.s0]						; puts();
												; 
		sgdt	[GDTR]							; // グローバルディスクリプタテーブルを保存
												; 
		mov		rcx, [GDTR.Base]				; // GDTベースアドレスを設定
		mov		[begin], rcx					; begin = GDTR.Base;
												; 
		movzx	rdx, word [GDTR.Limit]			; // GDT終了アドレス
		add		rcx, rdx						; end = begin + GDT.Limit;
		mov		[end], rcx						; 
												; 
		mov		qword [selector], 0				; selector = 0;
.10L:	mov		rcx, [begin]					; while (begin < end)
		cmp		rcx, [end]						; {
		jae		.10E							;   
												; 
		; ディスクリプタを取得
		mov		rcx, [rcx]						;   desc = *begin;
		mov		[desc], rcx						;   
												; 
		; セレクタ
		mov		rcx, [selector]					;   RCX = selector;
		xcall	htoa, rcx, [.selector], 2		;   htoa();
												; 
		; ディスクリプタ全体
		mov		rcx, [desc]						;   RCX = DESC;
		xcall	htoa, rcx, [.desc], 17			;   htoa();
												; 
		; Gビット
		bt		qword [desc], 55				;   CY = desc & (1 << 55);
		setc	cl								;   CL = CY ? 1 : 0;
		xcall	htoa, rcx, [.b55], 1			;   htoa();
												; 
		; Dビット
		bt		qword [desc], 54				;   CY = desc & (1 << 54);
		setc	cl								;   CL = CY? 1 : 0;
		xcall	htoa, rcx, [.b54], 1			;   htoa();
												; 
		; Lビット
		bt		qword [desc], 53				;   CY = desc & (1 << 53);
		setc	cl								;   CL = CY ? 1 : 0;
		xcall	htoa, rcx, [.b53], 1			;   htoa();
												; 
		; DPL
		mov		rcx, [desc]						;   RCX = desc;
		shr		rcx, 45							;   RCX >>= 45;
		and		rcx, 0b0011						;   RCX &= 0b0011;
		xcall	htoa, rcx, [.dpl], 1			;   htoa();
												; 
		; 文字列を出力
		xcall	puts, [.s1]						;   puts();
												; 
		; 次のディスクリプタを設定
		add		qword [selector], 8				;   selector += 8;
		add		qword [begin], 8				;   begin++;
												; 
		jmp		.10L							; }
.10E:

		;---------------------------------------
		; CS/DSを表示
		;---------------------------------------
		xcall	htoa, cs, [.cs], 4				; htoa();
		xcall	htoa, ds, [.ds], 4				; htoa();
		xcall	puts, [.s2]

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

.s0:	db	"GDT(Global Descriptor Table)", 0x0D, 0x0A, 0

;========================================================================
[section .data]
.s1:		db	" "
.selector:	db	"12", " : "
.desc:		db	"12345678_12345678", " (G="
.b55:		db	"1", " D="
.b54:		db	"1", " L="
.b53:		db	"1", " DPL="
.dpl:		db	"1", ")", 0x0D, 0x0A, 0
.s2:		db	" CS="
.cs:		db	"1234", ", ", "DS="
.ds:		db	"1234", 0x0D, 0x0A, 0

;========================================================================
[section .text]
