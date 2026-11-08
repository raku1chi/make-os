;************************************************************************
;	フォントの取得
;========================================================================
;■書式		: void get_font(void);
;
;■引数		: 無し
;
;■戻り値	: 無し
;************************************************************************
get_font:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
		FRAME_BEGIN								; // フレームの開始

		; ローカル変数の定義
		%local	char:qword						; int char;
		%local	ptr:qword						; EFI_IMAGE_OUTPUT* ptr;

		FRAME_STACK								; // スタック領域の確保

		;---------------------------------------
		; メモリ領域の確保
		;---------------------------------------
		mov		rcx, 8 * 128					; RCX = sizeof (void*) * 128;
		xcall	allocate_pool, rcx				; RAX = allocate_pool();
		mov		[FONT], rax						; FONT = RAX;

		;---------------------------------------
		; グリフの取得
		;---------------------------------------
		mov		qword [char], 0					; char = 0;
		mov		rcx, [FONT]						; ptr = FONT;
		mov		[ptr], rcx						; 
.10L:	mov		rcx, [char]						; while (char < 128)
		cmp		rcx, 128						; {
		jge		.10E							;   
												;   
		mov		rax, [ptr]						;   *ptr = NULL;
		mov		qword [rax], 0					;   
												;   
		mov		rax, [gHFP]						; 
		xcall	HFP(rax, .GetGlyph), \
					qword [gHFP], \
					qword [char], 0, \
					qword [ptr], 0				;   RAX = GetGlyph();
												; 
		inc		qword [char]					;   char++;
		add		qword [ptr], 8					;   ptr++;
												; 
		jmp		.10L							;   
.10E:											; }

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		FRAME_END								; // フレームの終了
