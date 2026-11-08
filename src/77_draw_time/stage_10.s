;************************************************************************
;	ステージ10
;========================================================================
;■書式		: void stage_10(void);
;
;■引数		: 無し
;
;■戻り値	: 無し
;************************************************************************
stage_10:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
		FRAME_BEGIN								; // フレームの開始

		; ローカル変数の定義
		%local	info:qword						; EFI_GRAPHICS_OUTPUT_MODE_INFORMATION* info;

		FRAME_STACK								; // スタック領域の確保

		;---------------------------------------
		; テキスト画面をクリア
		;---------------------------------------
		mov		rcx, [gTOP]						; RCX = TOPインスタンス
		xcall	TOP(rcx, .ClearScreen), rcx		; ClearScreen();

		;---------------------------------------
		; 現在のGOPモードを保存
		;---------------------------------------
		xcall	get_gop_mode					; get_gop_mode();

		mov		rax, [gGOP]						; RAX = GOP;
		mov		rax, GOP(rax, .Mode)
		mov		rcx, GOPM(rax, .Info)
		xcall	get_gop_info, rcx				; get_gop_info();

		;---------------------------------------
		; 現在のGOPモード情報を表示
		;---------------------------------------
		xcall	put_gop_info					; put_gop_info();

		;---------------------------------------
		; GOPモードを選択
		;---------------------------------------
.10L:											; for (;;)
												; {
		; キー入力
		xcall	puts, [.s0]						;   puts();
		xcall	read_key						;   read_key();
		shr		rax, 16							;   RAX >>= 16;

		; 数値のみを判定
		cmp		rax, '0'						;   if (key < '0')
		jb		.10E							;     break;
		cmp		rax, '9'						;   if ('9' < key)
		ja		.10E							;     break;

		; 入力された数値を保存
		mov		[.key], al						;   // 入力された文字を保存
		sub		rax, '0'						;   RAX -= '0';
		mov		[Video.Mode], rax				;   Video.Mode = RAX;

		; 入力された数値を表示
		xcall	puts, [.key]					;   puts();

		; GOPモード情報の取得
		mov		rcx, [Video.Mode]				;   RCX = Video.Mode;
		xcall	query_gop_info, rcx				;   RAX = query_gop_info();
		cmp		rax, 0							;   if (RAX != 0)
		je		.12E							;     continue;

		; モード情報の保存
		mov		[info], rax						;   info = RAX;
		xcall	get_gop_info, rax				;   get_gop_info();
		xcall	free_pool, qword [info]			;   free_pool();

		; テキスト画面をクリア
		mov		rcx, [gTOP]						;   RCX = TOPインスタンス
		xcall	TOP(rcx, .ClearScreen), rcx		;   ClearScreen();

		; GOPモード情報を表示
		xcall	put_gop_info					;   put_gop_info();
.12E:											;   
		jmp		.10L							;   
.10E:											; }

		;---------------------------------------
		; キー入力待ち
		;---------------------------------------
		xcall	puts, [Const.ClearMessage]		; puts();
		xcall	puts, [Const.PressAnyKey]		; puts();
		xcall	read_key						; read_key();

		;---------------------------------------
		; テキスト画面をクリア
		;---------------------------------------
		mov		rcx, [gTOP]						; RCX = TOPインスタンス
		xcall	TOP(rcx, .ClearScreen), rcx		; ClearScreen();

		;---------------------------------------
		; モードを設定
		;---------------------------------------
		mov		rcx, [Video.Mode]				; RCX = Video.Mode;
		xcall	set_gop_mode					; set_gop_mode();

		;---------------------------------------
		; 現在のGOPモードを保存
		;---------------------------------------
		xcall	get_gop_mode					; get_gop_mode();

		mov		rax, [gGOP]						; RAX = GOP;
		mov		rax, GOP(rax, .Mode)
		mov		rcx, GOPM(rax, .Info)
		xcall	get_gop_info, rcx				; get_gop_info();

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		FRAME_END								; // フレームの終了

.s0:	db	"Input mode number:", 0

;========================================================================
[section .data]
ALIGN 16, db 0
.key:	db	" ", 0x0D, 0x0A, 0

;========================================================================
[section .text]
