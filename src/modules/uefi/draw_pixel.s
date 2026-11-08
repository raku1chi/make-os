;************************************************************************
;	ピクセルの描画
;========================================================================
;■書式		: void draw_pixel(x, y, color);
;
;■引数
;	x		: X座標
;	y		: Y座標
;	color	: 描画色
;
;■戻り値	: 無し
;************************************************************************
draw_pixel:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
		FRAME_BEGIN								; // フレームの開始

		; 引数の定義
		%arg	x:qword							; // 引数の定義
		%arg	y:qword							; // 引数の定義
		%arg	color:qword						; // 引数の定義

		FRAME_STACK								; // スタック領域の確保

		; 引数の保存
		mov		[x], rcx						; // 引数の保存
		mov		[y], rdx						; // 引数の保存
		mov		[color], r8						; // 引数の保存

		;---------------------------------------
		; 座標計算
		;---------------------------------------
													; do
													; {
		mov		rdx, [Video.FrameBufferBase]		;   RDX = 描画バッファの先頭;
		cmp		rdx, 0								;   if (0 == FrameBufferBase)
		je		.10E								;     break;
													;   
		mov		rcx, [x]							;   // X座標は範囲内か？
		cmp		rcx, [Video.HorizontalResolution]	;   if (x >= HorizontalResolution)
		jae		.10E								;     break;
													;   
		mov		rcx, [Video.BytesPerPixel]			;   RCX  = ピクセルのバイト数;
		imul	rcx, [x]							;   RCX *= X位置のバイト数;
		add		rdx, rcx							;   RDX += RCX
													;   
		mov		rcx, [Video.BytesPerPixel]			;   RCX  = ピクセルのバイト数
		imul	rcx, [Video.PixelsPerScanLine]		;   RCX *= 1行分のバイト数;
		imul	rcx, [y]							;   RCX *= Y位置のバイト数;
		add		rdx, rcx							;   RDX += RCX
													;   
		mov		rcx, [Video.FrameBufferBase]		;   RCX = 描画バッファの先頭;
		add		rcx, [Video.FrameBufferSize]		;   RCX += 描画バッファのサイズ;
		cmp		rcx, rdx							;   if (RCX <= RDX)
		jbe		.10E								;     break;
													;   
		;---------------------------------------
		; ピクセルのバイト数分転送
		;---------------------------------------
		mov		rcx, [color]						;   RCX = 描画色;
		mov		r8, 0								;   R8 = 0;
.12L:	cmp		r8, [Video.BytesPerPixel]			;   while (R8 < ピクセルのバイト数)
		jae		.12E								;   {
													;     
		mov		[rdx], cl							;     *RDX = CL; // 1バイト分の色情報
		inc		rdx									;     RDX++;
		shr		rcx, 8								;     RCX >>= 8;   // 1バイト分シフト
													;     
		inc		r8									;     R8++;
		jmp		.12L								;   
.12E:												;   }
.10E:												; } while (0);

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		FRAME_END								; // フレームの終了
