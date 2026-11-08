;************************************************************************
;	文字情報の表示
;========================================================================
;■書式		: void put_glyph(char);
;
;■引数
;	char	: 文字コード
;
;■戻り値	: 無し
;************************************************************************
put_glyph:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
		FRAME_BEGIN								; // フレームの開始

		; 引数の定義
		%arg	char:qword						; // 引数の定義

		; ローカル変数の定義
		%local	width:qword						; int width;
		%local	height:qword					; int height;
		%local	bitmap:qword					; EFI_GRAPHICS_OUTPUT_BLT_PIXEL* bitmap;
		%local	ofs_x:qword						; int ofs_x;
		%local	ofs_y:qword						; int ofs_y;

		FRAME_STACK								; // スタック領域の確保

		; 引数の保存
		mov		[char], rcx						; // 引数の保存

		;---------------------------------------
		; 文字（GLYPH）情報を取得
		;---------------------------------------
		; EFI_IMAGE_OUTPUTへのポインタを取得
		mov		rax, [FONT]						; RAX = FONT
		movzx	rcx, byte [char]				; RCX = 文字コード;
		mov		rax, [rax + rcx * 8]			; RAX = FONT[char];

		; 幅
		movzx	rcx, word [rax + EFI_IMAGE_OUTPUT.Width]
		mov		[width], rcx					; width = EFI_IMAGE_OUTPUT.Width;

		; 高さ
		movzx	rcx, word [rax + EFI_IMAGE_OUTPUT.Height]
		mov		[height], rcx					; height = EFI_IMAGE_OUTPUT.Height;

		; ビットマップイメージ
		mov		rcx, [rax + EFI_IMAGE_OUTPUT.Bitmap]
		mov		[bitmap], rcx					; bitmap = EFI_IMAGE_OUTPUT.Bitmap;

		;---------------------------------------
		; 文字サイズの表示
		;---------------------------------------
		mov		rcx, [width]					; RCX = width;
		xcall	itoa, rcx, [.width], 2, 10, 0	; itoa();
												;   
		mov		rcx, [height]					; RCX = height;
		xcall	itoa, rcx, [.height], 2, 10, 0	; itoa();
												;   
		xcall	puts, [.s0]						; puts();

		;---------------------------------------
		; ビットマップの表示
		;---------------------------------------
		mov		qword [ofs_y], 0				; ofs_y = 0;
.10L:	mov		rcx, [ofs_y]					; 
		cmp		rcx, [height]					; while (ofs_y < height)
		jge		.10E							; {
												;   
		mov		qword [ofs_x], 0				;   ofs_x = 0;
.12L:	mov		rcx, [ofs_x]					;   
		cmp		rcx, [width]					;   while (ofs_x < width)
		jge		.12E							;   {
												;   
		mov		rcx, [bitmap]					;     RCX = bitmap;
		mov		rcx, [rcx]						;     
		xcall	htoa, rcx, [.bitmap], 8			;     htoa();
		xcall	puts, [.s1]						;     puts();
												;   
		add		qword [bitmap], 4				;     bitmap++;
		inc		qword [ofs_x]					;     ofs_x++;
		jmp		.12L							;   
.12E:											;   }
												;   
		xcall	puts, [.crlf]					;   puts();
												;   
		inc		qword [ofs_y]					;   ofs_y++;
		jmp		.10L							;   
.10E:											; }

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		FRAME_END								; // フレームの終了

;========================================================================
[section .data]
ALIGN 16, db 0
.s0:		db	"GLYPH("
.width:		db	"12", " x "
.height:	db	"12", ")", 0x0D, 0x0A, 0
.s1:		db	" "
.bitmap:	db	"12345678", 0
.crlf:		db	0x0D, 0x0A, 0

;========================================================================
[section .text]
