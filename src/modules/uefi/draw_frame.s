;************************************************************************
;	枠の描画
;========================================================================
;■書式		: void draw_frame1(X0, Y0, X1, Y1, colors);
;
;■引数
;	X0		: 始点のX座標
;	Y0		: 始点のY座標
;	X1		: 終点のX座標
;	Y1		: 終点のY座標
;	colors	: 描画色情報へのポインタ
;
;■戻り値	: 無し
;************************************************************************
draw_frame:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
		FRAME_BEGIN								; // フレームの開始

		; 引数の定義
		%arg	x0:qword						; int x0;
		%arg	y0:qword						; int y0;
		%arg	x1:qword						; int x1;
		%arg	y1:qword						; int y1;
		%arg	colors:qword					; int (*colors)[5];

		FRAME_STACK								; // スタック領域の確保

		; レジスタの保存
		mov		[x0], rcx						; x0 = RCX;
		mov		[y0], rdx						; y0 = RDX;
		mov		[x1], r8						; x1 = R8;
		mov		[y1], r9						; y1 = R9;

		;---------------------------------------
		; 矩形を描画
		;---------------------------------------

		; 背景色を描画
		mov		rax, [colors]					; 
		mov		rax, [rax + (8 * 0)]			; RAX = colors[0];
		cmp		rax, 0x01_000000				; if (RAX < 0x01_000000)
		jnc		.12E							; {
		mov		rcx, [x0]						;   RCX = X0;
		mov		rdx, [y0]						;   RDX = Y0;
		mov		r8,  [x1]						;   R8  = X1;
		mov		r9,  [y1]						;   R9  = Y1;
												;   RAX = 前景色;
		xcall	fill_rect, rcx, rdx, r8, r9, rax;   fill_rect();
.12E:											; }

		; 左線を描画
		mov		rax, [colors]					; 
		mov		rax, [rax + (8 * 1)]			; RAX = colors[1];
		cmp		rax, 0x01_000000				; if (RAX < 0x01_000000)
		jnc		.13E							; {
		mov		rcx, [x0]						;   RCX = X0;
		mov		rdx, [y0]						;   RDX = Y0;
		mov		r8,  rcx						;   R8  = X0;
		mov		r9,  [y1]						;   R9  = Y1;
												;   RAX = 前景色;
		xcall	draw_line, rcx, rdx, r8, r9, rax;   draw_line();
.13E:											; }

		; 上線を描画
		mov		rax, [colors]					; 
		mov		rax, [rax + (8 * 2)]			; RAX = colors[2];
		cmp		rax, 0x01_000000				; if (RAX < 0x01_000000)
		jnc		.14E							; {
		mov		rcx, [x0]						;   RCX = X0;
		mov		rdx, [y0]						;   RDX = Y0;
		mov		r8,  [x1]						;   R8  = X1;
		mov		r9,  rdx						;   R9  = Y0;
												;   RAX = 前景色;
		xcall	draw_line, rcx, rdx, r8, r9, rax;   draw_line();
.14E:											; }

		; 右線を描画
		mov		rax, [colors]					; 
		mov		rax, [rax + (8 * 3)]			; RAX = colors[3];
		cmp		rax, 0x01_000000				; if (RAX < 0x01_000000)
		jnc		.15E							; {
		mov		rcx, [x1]						;   RCX = X1;
		dec		rcx								;   RCX--; // 右線は1ドット左に描画
		mov		rdx, [y0]						;   RDX = Y0;
		inc		rdx								;   RDX++;
		mov		r8,  rcx						;   R8  = RCX;
		mov		r9,  [y1]						;   R9  = Y1;
												;   RAX = 前景色;
		xcall	draw_line, rcx, rdx, r8, r9, rax;   draw_line();
.15E:											; }

		; 下線を描画
		mov		rax, [colors]					; 
		mov		rax, [rax + (8 * 4)]			; RAX = colors[4];
		cmp		rax, 0x01_000000				; if (RAX < 0x01_000000)
		jnc		.16E							; {
		mov		rcx, [x0]						;   RCX = X0;
		inc		rcx								;   RCX++;
		mov		rdx, [y1]						;   RDX = Y0;
		dec		rdx								;   RDX--; // 下線は1ドット上に描画
		mov		r8,  [x1]						;   R8  = X1;
		mov		r9,  rdx						;   R9  = RDX;
												;   RAX = 前景色;
		xcall	draw_line, rcx, rdx, r8, r9, rax;   draw_line();
.16E:											; }

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		FRAME_END								; // フレームの終了
