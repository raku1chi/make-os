;************************************************************************
;	GOPモード情報を表示
;========================================================================
;■書式		: void put_gop_info(void);
;
;■引数		: 無し
;
;■戻り値	: 無し
;************************************************************************
put_gop_info:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
		FRAME_BEGIN								; // フレームの開始
		FRAME_STACK								; // スタック領域の確保

		;---------------------------------------
		; モード情報を表示
		;---------------------------------------

		; モード番号を表示
		mov		rcx, [Video.Mode]				; RCX = Video.Mode;
		lea		rdx, [.mode]					; 
		xcall	itoa, rcx, rdx, 1, 10, 0		; itoa();

		; モード数を表示
		mov		rcx, [Video.MaxMode]			; RCX = Video.MaxMode;
		lea		rdx, [.max_mode]				; 
		xcall	itoa, rcx, rdx, 1, 10, 0		; itoa();

		; 水平解像度を10進数で表示
		mov		rcx, [Video.HorizontalResolution] ; RCX = Video.HorizontalResolution;
		lea		rdx, [.hori]					; 
		xcall	itoa, rcx, rdx, 4, 10, 0		; itoa();

		; 垂直解像度を10進数で表示
		mov		rcx, [Video.VerticalResolution]	; RCX = Video.VerticalResolution;
		lea		rdx, [.vert]					; 
		xcall	itoa, rcx, rdx, 4, 10, 0		; itoa();

		; 1行のピクセル数を10進数で表示
		mov		rcx, [Video.PixelsPerScanLine]	; RCX = Video.PixelsPerScanLine;
		lea		rdx, [.pixels]					; 
		xcall	itoa, rcx, rdx, 4, 10, 0		; itoa();

		; ピクセルのフォーマット
		mov		rcx, [Video.PixelFormat]		; RCX = Video.PixelFormat;
		lea		rdx, [.format]					; 
		xcall	itoa, rcx, rdx, 1, 10, 0		; itoa();

		; ピクセルのバイト数
		mov		rcx, [Video.BytesPerPixel]		; RCX = Video.BytesPerPixel;
		lea		rdx, [.bytes]					; 
		xcall	itoa, rcx, rdx, 1, 10, 0		; itoa();

		; ビットマスク（赤）
		mov		rcx, [Video.RedMask]			; RCX = Video.RedMask;
		lea		rdx, [.red_mask]				; 
		xcall	htoa, rcx, rdx, 8				; htoa();

		; ビットマスク（緑）
		mov		rcx, [Video.GreenMask]			; RCX = Video.GreenMask;
		lea		rdx, [.green_mask]				; 
		xcall	htoa, rcx, rdx, 8				; htoa();

		; ビットマスク（青）
		mov		rcx, [Video.BlueMask]			; RCX = Video.BlueMask;
		lea		rdx, [.blue_mask]				; 
		xcall	htoa, rcx, rdx, 8				; htoa();

		; ビットマスク（予約）
		mov		rcx, [Video.ReservedMask]		; RCX = Video.ReservedMask;
		lea		rdx, [.reserved_mask]			; 
		xcall	htoa, rcx, rdx, 8				; htoa();

		xcall	puts, [.s0]						; puts();

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		FRAME_END								; // フレームの終了

;========================================================================
[section .data]
ALIGN 16, db 0
.s0:			db	" Mode / MaxMode       : "
.mode:			db	"1", " / "
.max_mode:		db	"1", 0x0D, 0x0A
				db	" HorizontalResolution : "
.hori:			db	"1234", 0x0D, 0x0A
				db	" VerticalResolution   : "
.vert:			db	"1234", 0x0D, 0x0A
				db	" PixelsPerScanLine    : "
.pixels:		db	"1234", 0x0D, 0x0A
				db	" PixelFormat          : "
.format:		db	"1", 0x0D, 0x0A
				db	" PixelInformation     : "
.red_mask:		db	"12345678", " "
.green_mask:	db	"12345678", " "
.blue_mask:		db	"12345678", " "
.reserved_mask:	db	"12345678", " ", 0x0D, 0x0A
				db	" BytesPerPixel        : "
.bytes:			db	"1", 0x0D, 0x0A
				db	0

;========================================================================
[section .text]
