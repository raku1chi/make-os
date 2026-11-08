;************************************************************************
;	文字の描画
;========================================================================
;■書式		: int draw_char(x, y, fg_color, bg_color, char);
;
;■引数
;	x			: X座標
;	y			: Y座標
;	fg_color	: 前景色
;	bg_color	: 背景色
;	char		: 文字コード
;
;■戻り値	: 文字幅
;************************************************************************
draw_char:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
		FRAME_BEGIN								; // フレームの開始

		; 引数の定義
		%arg	x:qword							; // 引数の定義
		%arg	y:qword							; // 引数の定義
		%arg	fg_color:qword					; // 引数の定義
		%arg	bg_color:qword					; // 引数の定義
		%arg	char:qword						; // 引数の定義

		; ローカル変数の定義
		%local	width:qword						; int width;
		%local	height:qword					; int height;
		%local	image:oword						; EFI_IMAGE_OUTPUT image;
		%local	save_r12:qword					; void* save_r12;
		%local	save_r13:qword					; void* save_r13;
		%local	save_r14:qword					; void* save_r14;
		%local	save_r15:qword					; void* save_r15;

		FRAME_STACK								; // スタック領域の確保

		; レジスタの保存
		mov		[save_r12], r12					; save_r12 = R12;
		mov		[save_r13], r13					; save_r13 = R13;
		mov		[save_r14], r14					; save_r14 = R14;
		mov		[save_r15], r15					; save_r15 = R15;

		; 引数の保存
		mov		r12, rcx						; x = RCX;
		mov		r13, rdx						; y = RDX;
		mov		[fg_color], r8					; fg_color = R8;
		mov		[bg_color], r9					; bg_color = R9;

		;---------------------------------------
		; 文字情報を取得
		;---------------------------------------
		movzx	rcx, byte [char]				; RCX = 文字コード;
		lea		rdx, [image]					; RDX = &image;
		xcall	get_font_image, rcx, rdx		; get_font_image();

		; 幅
		movzx	rcx, word [image + EFI_IMAGE_OUTPUT.Width]
		mov		[width], rcx					; width = EFI_IMAGE_OUTPUT.Width;

		; 高さ
		movzx	rcx, word [image + EFI_IMAGE_OUTPUT.Height]
		mov		[height], rcx					; height = EFI_IMAGE_OUTPUT.Height;

		;---------------------------------------
		; ビットマップの表示
		;---------------------------------------
		mov		r15, 0							; ofs_y = 0;
.10L:	cmp		r15, [height]					; while (ofs_y < height)
		jge		.10E							; {
												;   
		mov		r14, 0							;   ofs_x = 0;
.12L:	cmp		r14, [width]					;   while (ofs_x < width)
		jge		.12E							;   {
												;     
		mov		rcx, r14						;     RCX = ofs_x;
		mov		rdx, r15						;     RDX = ofs_y;
		xcall	get_font_pixel, rcx, rdx, [image]
												;     
		mov		rcx, r12						;     // X座標
		add		rcx, r14						;     RCX = x + ofs_x;
		mov		rdx, r13						;     // Y座標
		add		rdx, r15						;     RDX = y + ofs_y;
		mov		r8, [fg_color]					;     R8 = 前景色;
												;     
		cmp		eax, 0							;     if (0 != EAX) // ピクセルの描画あり
		jz		.14F							;     {
												;       // 前景色で描画
		xcall	draw_pixel, rcx, rdx, r8		;       draw_pixel();
												;     }
		jmp		.14E							;     else
.14F:											;     {
		test	r8, 0x01_000000					;       if (fg_color & 0x01_000000)
		jnz		.14E							;       {
												;         // 背景色で描画
		mov		r8, [bg_color]					;         R8 = 背景色;
		xcall	draw_pixel, rcx, rdx, r8		;         draw_pixel();
												;       }
.14E:											;     }
		inc		r14								;     ofs_x++;
		jmp		.12L							;   
.12E:											;   }
		inc		r15								;   ofs_y++;
		jmp		.10L							;   
.10E:											; }

		mov		rax, [width]					; return width;

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		mov		r12, [save_r12]					; R12 = save_r12;
		mov		r13, [save_r13]					; R13 = save_r13;
		mov		r14, [save_r14]					; R14 = save_r14;
		mov		r15, [save_r15]					; R15 = save_r15;
		FRAME_END								; // フレームの終了
