;************************************************************************
;	GOPモード情報を保存
;========================================================================
;■書式		: void get_gop_info(info);
;
;■引数
;	info	: モード情報
;
;■戻り値	: 無し
;************************************************************************
get_gop_info:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
		FRAME_BEGIN								; // フレームの開始
		FRAME_STACK								; // スタック領域の確保

		;---------------------------------------
		; EFI_GRAPHICS_OUTPUT_MODE_INFORMATION
		;---------------------------------------

		; 水平／垂直解像度を保存（32ビット×2）
		mov		r8d, GOMI(rcx, .HorizontalResolution)
		mov		r9d, GOMI(rcx, .VerticalResolution)
		mov		[Video.HorizontalResolution], r8
		mov		[Video.VerticalResolution], r9

		; ピクセルフォーマットを保存（32ビット）
		mov		r8d, GOMI(rcx, .PixelFormat)
		mov		[Video.PixelFormat], r8

		; ピクセルマスクを保存（32ビット×4）
		mov		r8d, GOMI(rcx, .PixelInformation + 0)
		mov		r9d, GOMI(rcx, .PixelInformation + 4)
		mov		r10d, GOMI(rcx, .PixelInformation + 8)
		mov		r11d, GOMI(rcx, .PixelInformation + 12)
		mov		[Video.RedMask], r8
		mov		[Video.GreenMask], r9
		mov		[Video.BlueMask], r10
		mov		[Video.ReservedMask], r11

		; 1行のピクセル数を保存（32ビット）
		mov		r8d, GOMI(rcx, .PixelsPerScanLine)
		mov		[Video.PixelsPerScanLine], r8

		; ピクセルのバイト数
		mov		rax, 4							; RAX = 4; // 仮のバイト数
		cmp		qword [Video.PixelFormat], 2	; if (PixelFormat == PixelBitMask)
		jne		.10E							; {
												;   // 全てのピクセルマスクを合成
		mov		rcx, [Video.RedMask]			;   RCX = RedMask;
		or		rcx, [Video.GreenMask]			;   RCX |= GreenMask;
		or		rcx, [Video.BlueMask]			;   RCX |= BlueMask;
		or		rcx, [Video.ReservedMask]		;   RCX |= ReservedMask;

												;   // 未使用のバイトを減算
		cmp		rcx, 0x01000000					;   CF = RCX - 0x01000000;
		sbb		rax, 0							;   RAX -= CF;
.10E:											; }
		mov		[Video.BytesPerPixel], rax		; BytesPerPixel = RAX;
												; 
		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		FRAME_END								; // フレームの終了
