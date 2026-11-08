;************************************************************************
;	ステージ6
;========================================================================
;■書式		: void stage_6(void);
;
;■引数		: 無し
;
;■戻り値	: 無し
;************************************************************************
stage_6:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
		FRAME_BEGIN								; // フレームの開始
		FRAME_STACK								; // スタック領域の確保

		;---------------------------------------
		; グラフィックス出力プロトコルを取得
		;---------------------------------------
		xcall	get_protocol, [EFI_GRAPHICS_OUTPUT_PROTOCOL_GUID]
		mov		[gGOP], rax						; gHFP = get_protocol();

		mov		rcx, [gGOP]						; RXC = gGOP;
		xcall	htoa, rcx, [.proto], 17			; htoa();
		xcall	puts, [.s0]						; puts();

		;---------------------------------------
		; 現在のGOPモードを保存
		;---------------------------------------
		xcall	get_gop_mode					; get_gop_mode();

		mov		rax, [gGOP]						; RAX = GOP;
		mov		rax, GOP(rax, .Mode)			; RAX = GOP.Mode;
		mov		rcx, GOPM(rax, .Info)			; RCX = GOP.Mode.Info;
		xcall	get_gop_info, rcx				; // モード情報の保存

		;---------------------------------------
		; 現在のGOPモードを表示
		;---------------------------------------
		xcall	put_gop_info					; // GOPモード情報の表示
		xcall	put_gop_mode					; // フレームバッファ情報の表示

		;---------------------------------------
		; ピクセルの描画
		;---------------------------------------
		xcall	draw_pixel,  8,  4, 0xFF0000
		xcall	draw_pixel,  9,  5, 0xFF0000
		xcall	draw_pixel, 10,  6, 0x00FF00
		xcall	draw_pixel, 11,  7, 0x00FF00
		xcall	draw_pixel, 12,  8, 0x0000FF
		xcall	draw_pixel, 13,  9, 0x0000FF
		xcall	draw_pixel, 14, 10, 0xFF00FF
		xcall	draw_pixel, 15, 11, 0xFF00FF

		xcall	draw_pixel, 15,  4, 0x0000FF
		xcall	draw_pixel, 14,  5, 0x0000FF
		xcall	draw_pixel, 13,  6, 0xFF00FF
		xcall	draw_pixel, 12,  7, 0xFF00FF
		xcall	draw_pixel, 11,  8, 0xFF0000
		xcall	draw_pixel, 10,  9, 0xFF0000
		xcall	draw_pixel,  9, 10, 0x00FF00
		xcall	draw_pixel,  8, 11, 0x00FF00

		;---------------------------------------
		; 線の描画
		;---------------------------------------
		xcall	draw_line, 100, 100,   0,   0, 0xFF0000
		xcall	draw_line, 100, 100, 200,   0, 0x00FF00
		xcall	draw_line, 100, 100, 200, 200, 0x0000FF
		xcall	draw_line, 100, 100,   0, 200, 0xFFFFFF

		xcall	draw_line, 100, 100,  50,   0, 0x7F0000
		xcall	draw_line, 100, 100, 150,   0, 0x007F00
		xcall	draw_line, 100, 100, 150, 200, 0x00007F
		xcall	draw_line, 100, 100,  50, 200, 0x7F7F7F

		xcall	draw_line, 100, 100,   0,  50, 0x3F0000
		xcall	draw_line, 100, 100, 200,  50, 0x003F00
		xcall	draw_line, 100, 100, 200, 150, 0x00003F
		xcall	draw_line, 100, 100,   0, 150, 0x3F3F3F

		xcall	draw_line, 100, 100, 100,   0, 0x3F0000
		xcall	draw_line, 100, 100, 200, 100, 0x003F00
		xcall	draw_line, 100, 100, 100, 200, 0x00003F
		xcall	draw_line, 100, 100,   0, 100, 0x3F3F3F

		;---------------------------------------
		; 矩形の描画
		;---------------------------------------
		xcall	draw_rect,  50,  50, 150, 150, 0x00FFFF
		xcall	draw_rect, 400, 250, 150, 150, 0xFFFF00
		xcall	draw_rect, 350, 400, 300, 100, 0xFF00FF

		;---------------------------------------
		; 塗りつぶし矩形の描画
		;---------------------------------------
		xcall	fill_rect, 200, 50, 250, 100, 0x00FF00
		xcall	fill_rect, 250, 50, 300, 100, 0x007F00
		xcall	fill_rect, 300, 50, 350, 100, 0x003F00

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

;========================================================================
[section .data]
ALIGN 16, db 0
.s0:		db	"PROTOCOL", 0x0D, 0x0A
			db	" GOP = "
.proto:		db	"12345678_12345678", 0x0D, 0x0A, 0

;========================================================================
[section .text]
