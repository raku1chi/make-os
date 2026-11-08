;************************************************************************
;	メモリマップの取得
;========================================================================
;■書式		: void get_memory_map();
;
;■引数		: 無し
;
;■戻り値	: 無し
;************************************************************************
get_memory_map:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
		FRAME_BEGIN								; // フレームの開始
		FRAME_STACK								; // スタック領域の確保

		;---------------------------------------
		; メモリマップを取得
		;---------------------------------------
												; do
.10L:											; { 
		mov		rcx, [MemoryMap.AllocBytes]		;   // 確保したメモリのバイト数
		mov		[MemoryMap.Size], rcx			;   Size = AllocBytes;

		; メモリマップの取得
		mov		rax, [gBS]						;   // メモリマップを取得
		xcall	BS(rax, .GetMemoryMap), \
					[MemoryMap.Size], \
					qword [MemoryMap.AllocPtr], \
					[MemoryMap.MapKey], \
					[MemoryMap.DescSize], \
					[MemoryMap.DescVer]			;   GetMemoryMap();

		cmp		rax, EFI_SUCCESS				;   if (RAX == EFI_SUCCESS)
		je		.10E							;     break;

		mov		rcx, EFI_BUFFER_TOO_SMALL		;   // バッファが少ないか？
		cmp		rcx, rax						;   if (RAX != EFI_BUFFER_TOO_SMALL)
		jne		.10E							;     break;

		; メモリ領域が足りなかったので再確保
		; 既に確保したメモリ領域があれば解放
		mov		rcx, [MemoryMap.AllocPtr]		;   RCX = 確保したメモリのアドレス;
		cmp		rcx, 0							;   if (0 != RCX)
		je		.12E							;   {
												;     RCX = アドレス;
		xcall	free_pool, rcx					;     free_pool();
.12E:											;   }
												;   
		mov		qword [MemoryMap.AllocPtr], 0	;   AllocPtr = 0;
		mov		qword [MemoryMap.AllocBytes], 0	;   AllocBytes = 0;

		; 必要なメモリを再確保
		mov		rcx, [MemoryMap.Size]			;   RCX = 関数が要求したバイト数;
		xcall	allocate_pool, rcx				;   // メモリの確保

		cmp		rax, 0							;   if (0 == ptr)
		je		.10E							;     break;

		mov		[MemoryMap.AllocPtr], rax		;   AllocPtr = アドレス;
		mov		rcx, [MemoryMap.Size]			;   RCX = 確保したバイト数;
		mov		[MemoryMap.AllocBytes], rcx		;   AllocBytes = RCX;

		jmp		.10L							;   
.10E:											; } while (true);

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		FRAME_END								; // フレームの終了

;************************************************************************
;	メモリマップの表示
;========================================================================
;■書式		: void put_memory_map();
;
;■引数		: 無し
;
;■戻り値	: 無し
;************************************************************************
put_memory_map:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
		FRAME_BEGIN								; // フレームの開始

		; ローカル変数の定義
		%local	begin:qword						; EFI_MEMORY_DESCRIPTOR* begin;
		%local	end:qword						; EFI_MEMORY_DESCRIPTOR* end;
		%local	index:qword						; int index;

		FRAME_STACK								; // スタック領域の確保

		;---------------------------------------
		; メモリマップを表示
		;---------------------------------------
		xcall	puts, [.s0]						; puts();

		mov		rcx, [MemoryMap.AllocPtr]		; // メモリマップの先頭
		mov		[begin], rcx					; begin = MemoryMap.AllocPtr
												; 
		mov		rdx, rcx						; // メモリマップの終端
		add		rdx, [MemoryMap.Size]			; end = begin + MemoryMap.Size;
		mov		[end], rdx						; 
												; 
		mov		qword [index], 0				; index = 0;
.10L:	mov		rcx, [begin]					; 
		cmp		rcx, [end]						; for (; begin < end ;)
		jae		.10E							; {
												;   
		mov		rcx, [index]					;   // インデックス
		xcall	htoa, rcx, [.index], 2			;   
												;   
		mov		rax, [begin]					;   // タイプ
		mov		rcx, MD(rax, .Type)				;   
		xcall	htoa, rcx, [.type], 4			;   
												;   
		mov		rax, [begin]					;   // 開始アドレス
		mov		ecx, MD(rax, .PhysicalStart)	;   
		xcall	htoa, rcx, [.start], 17			;   

		mov		rax, [begin]					;   // ページ数
		mov		rcx, MD(rax, .NumberOfPages)	;   
		xcall	htoa, rcx, [.pages], 17			;   

		mov		rax, [begin]					;   // 属性
		mov		rcx, MD(rax, .Attribute)		;   
		xcall	htoa, rcx, [.attrb], 8			;   
												;   
		xcall	puts, [.mem_map]				;   puts();
												;
		mov		rcx, [MemoryMap.DescSize]		;   // 次の情報
		add		[begin], rcx					;   begin++;
		inc		qword [index]					;   index++;

		;---------------------------------------
		; キー入力待ち（16行毎）
		;---------------------------------------
		mov		rcx, [index]					;   
		and		rcx, 0x0F						;   if (0 == (index & 0x0F))
		jnz		.14E							;   {
												;   
		xcall	puts, [.s1]						;     puts();
		xcall	read_key						;     read_key();

		cmp		rax, 0x00200000					;     if (key == SPACE)
		jne		.12E							;     {
		xcall	puts, [.s2]						;       puts();
		jmp		.10E							;       break;
.12E:											;     }

		xcall	puts, [.s2]						;     puts();
		xcall	puts, [.s0]						;     puts();
.14E:											;   }
		jmp		.10L							;   
.10E:											; }

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		FRAME_END								; // フレームの終了

.s0:	db	" No _ Type ____PhysicalStart ____NumberOfPages Attribute", 0x0D, 0x0A, 0
.s1:	db	"Press any key to continue...(SPACE key to exit)", 0
.s2:	db	0x0D
		times (.s2 - .s1 - 1) db ' '
		db	0x0D, 0

;========================================================================
[section .data]
.mem_map:	db	" "
.index:		db	"12", " : "
.type:		db	"1234", " "
.start:		db	"12345678_12345678", " "
.pages:		db	"12345678_12345678", " "
.attrb:		db	"12345678", 0x0D, 0x0A, 0

;========================================================================
[section .text]
