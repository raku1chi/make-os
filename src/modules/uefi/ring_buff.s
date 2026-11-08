;************************************************************************
;	リングバッファからデータを取得
;========================================================================
;■書式		: QWORD ring_rd(buff, data);
;
;■引数
;	buff	: リングバッファ
;	data	: 読み込んだデータの保存先アドレス
;
;■戻り値	: データあり(0以外)、データ無し(0)
;************************************************************************
ring_rd:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
		FRAME_BEGIN								; // フレームの開始

		; 引数の定義
		%arg	ring_buff:qword					; void* ring_buff;
		%arg	data_ptr:qword					; void* data_ptr;

		FRAME_STACK								; // スタック領域の確保

		; 引数の保存
		mov		[ring_buff], rcx				; // 引数を保存
		mov		[data_ptr], rdx					; // 引数を保存

		;---------------------------------------
		; 読み込み位置を確認
		;---------------------------------------
		mov		rax, 0							; RAX = 0; // データ無し
		mov		r8, [ring_buff]					; R8= ring_buff;
		mov		rcx, [r8 + ring_buff.rp]		; 
		cmp		rcx, [r8 + ring_buff.wp]		; if (rp != wp)
		je		.10E							; {
												;   
		mov		al, [r8 + ring_buff.item + rcx]	;   AL = buff[rp];
		mov		rdx, [data_ptr]					;   *data_ptr = AL;
		mov		[rdx], al						;   
												;   
		inc		rcx								;   rp++;
		and		rcx, RING_INDEX_MASK			;   rp &= RING_INDEX_MASK;
		mov		[r8 + ring_buff.rp], rcx		;   
												;   
		mov		rax, 1							;   RAX = 1;
.10E:											; }
												; return RAX;

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		FRAME_END								; // フレームの終了

;************************************************************************
;	リングバッファにデータを格納
;========================================================================
;■書式		: QWORD ring_wr(buff, data);
;
;■引数
;	buff	: リングバッファ
;	data	: 書き込むデータ
;
;■戻り値	: 成功(0以外)、失敗(0)
;************************************************************************
ring_wr:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
		FRAME_BEGIN								; // フレームの開始

		; 引数の定義
		%arg	ring_buff:qword					; void* ring_buff;
		%arg	data:qword						; 

		FRAME_STACK								; // スタック領域の確保

		; 引数の保存
		mov		[ring_buff], rcx				; // 引数を保存
		mov		[data], rdx						; // 引数を保存

		;---------------------------------------
		; 引数を取得
		;---------------------------------------
		mov		rax, 0							; EAX  = 0; // 失敗
												; 
		mov		r8, [ring_buff]					; R8 = ring_buff;
		mov		rcx, [r8 + ring_buff.wp]		; RCX = ring_buff.wp;
		mov		rdx, rcx						; RDX = RCX;
		inc		rdx								; RDX++;
		and		rdx, RING_INDEX_MASK			; RDX &= RING_INDEX_MASK;
		cmp		rdx, [r8 + ring_buff.rp]		; if (wp != rp)
		je		.10E							; {
												;   
		mov		al, [data]						;   AL = *data;
		mov		[r8 + ring_buff.item + rcx], al	;   buff[wp] = AL;
		mov		[r8 + ring_buff.wp], rdx		;   wp = RDX; // 次の書き込み位置
												;   
		mov		rax, 1							;   RAX = 1; // 成功
.10E:											; }
												; return RAX;

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		FRAME_END								; // フレームの終了
