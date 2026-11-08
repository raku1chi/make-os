;************************************************************************
;	メモリのコピー
;========================================================================
;■書式		: void memcpy(dst, src, bytes);
;
;■引数
;	dst		: コピー先
;	src		: コピー元
;	bytes	: バイト数
;
;■戻り値	: 無し
;************************************************************************
memcpy:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
		FRAME_BEGIN								; // フレームの開始

		; 引数の定義
		%arg	dst:qword						; void* dst;
		%arg	src:qword						; void* src;
		%arg	bytes:qword						; int bytes;

		; ローカル変数の定義
		%local	save_rdi:qword					; int save_rdi;
		%local	save_rsi:qword					; int save_rsi;

		FRAME_STACK								; // スタック領域の確保

		; レジスタの保存
		mov		[save_rdi], rdi					; save_rdi = RDI;
		mov		[save_rsi], rsi					; save_rsi = RSI;

		; 引数の保存
		mov		[dst], rcx						; // 引数の保存
		mov		[src], rdx						; // 引数の保存
		mov		[bytes], r8						; // 引数の保存

		;---------------------------------------
		; バイト単位でのコピー
		;---------------------------------------
		cld										; DF  = 0; // +方向
		mov		rdi, [dst]						; RDI = コピー先;
		mov		rsi, [src]						; RSI = コピー元;
		mov		rcx, [bytes]					; RCX = バイト数;

		rep movsb								; while (RCX--) *RDI++ = *RSI++;

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		mov		rsi, [save_rsi]					; // レジスタの復帰
		mov		rdi, [save_rdi]					; // レジスタの復帰
		FRAME_END								; // フレームの終了
