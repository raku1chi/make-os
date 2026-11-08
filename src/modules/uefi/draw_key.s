;************************************************************************
;	リングバッファ内要素の表示
;========================================================================
;■書式		: void draw_key(x, y, ring_buff);
;
;■引数
;	x			: X座標
;	y			: Y座標
;	ring_buff	: リングバッファ
;
;■戻り値	: 無し
;************************************************************************
draw_key:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
		FRAME_BEGIN								; // フレームの開始

		; 引数の定義
		%arg	pos_x:qword						; int pos_x;
		%arg	pos_y:qword						; int pos_y;
		%arg	ring_buff:qword					; void* ring_buff;

		; ローカル変数の定義
		%local	item_wp:qword					; int item_wp;
		%local	item_ptr:qword					; int item_ptr;
		%local	count:qword						; int count;

		FRAME_STACK								; // スタック領域の確保

		;---------------------------------------
		; 引数の保存
		;---------------------------------------
		mov		[pos_x], rcx					; // 引数を保存
		mov		[pos_y], rdx					; // 引数を保存
		mov		[ring_buff], r8					; // 引数を保存

		;---------------------------------------
		; リングバッファの情報を取得
		;---------------------------------------
		mov		rax, [ring_buff]				; // リングバッファの情報
		mov		rcx, [rax + ring_buff.wp]		; // 書き込み位置を取得
		mov		[item_wp], rcx					; item_wp = &ring_buff[ring_buff.wp];

		lea		rcx, [rax + ring_buff.item]		; // バッファの先頭アドレスを取得
		mov		[item_ptr], rcx					; item_ptr = &item[0];

		;---------------------------------------
		; 文字に変換しながら表示
		;---------------------------------------
		mov		qword [count], 0				; count = 0;
.10L:	cmp		qword [count], RING_ITEM_SIZE	; while (count < RING_ITEM_SIZE)
		jae		.10E							; {

		mov		rcx, [item_wp]					;   // 書き込み位置を更新
		dec		rcx								;   item_wp--;
		and		rcx, RING_INDEX_MASK			;   item_wp &= RING_INDEX_MASK;
		mov		[item_wp], rcx					;   
		mov		rdx, [item_ptr]					;   // 更新された位置にあるデータを取得
		mov		rcx, [rdx + rcx]				;   RCX = item_ptr[item_wp];
												;   
		xcall	htoa, rcx, [.value], 2			;   // キーコードを文字列に変換

		mov		rcx, [pos_x]					;   
		mov		rdx, [pos_y]					;   
		xcall	draw_str, rcx, rdx, \
					COLOR_TB_RECT_FG, \
					COLOR_TB_RECT_BG, \
					[.s0]						;   // 変換した文字列を表示

		add		qword [pos_x], COL(3)			;   pos_x += 3文字分;
		inc		qword [count]					;   count++;
		jmp		.10L							;   
.10E:											; }

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		FRAME_END								; // フレームの終了

;========================================================================
[section .data]
ALIGN 16, db 0
.s0:		db ' '
.value:		db '--', 0

;========================================================================
[section .text]
