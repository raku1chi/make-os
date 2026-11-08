;************************************************************************
;	線の描画
;========================================================================
;■書式		: void draw_line(x0, y0, x1, y1, color);
;
;■引数
;	x0		: 始点のX座標
;	y0		: 始点のY座標
;	x1		: 終点のX座標
;	y1		: 終点のY座標
;	color	: 描画色
;
;■戻り値	: 無し
;************************************************************************
draw_line:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
		FRAME_BEGIN								; // フレームの開始

		; 引数の定義
		%arg	x0:qword						; int x0;
		%arg	y0:qword						; int y0;
		%arg	x1:qword						; int x1;
		%arg	y1:qword						; int y1;
		%arg	color:qword						; int color;

		; ローカル変数の定義
		%local	save_rsi:qword					; save_rsi; // RSIレジスタの保存領域
		%local	save_rdi:qword					; save_rdi; // RDIレジスタの保存領域
		%local	sum:qword						; sum;      // 相対軸の積算値
		%local	count:qword						; count;    // 描画カウンタ
		%local	cur_x:qword						; x0;       // X座標
		%local	dlt_x:qword						; dx;       // X増分
		%local	inc_x:qword						; inc_x;    // X座標増分(1 or -1)
		%local	cur_y:qword						; y0;       // Y座標
		%local	dlt_y:qword						; dy;       // Y増分
		%local	inc_y:qword						; inc_y;    // Y座標増分(1 or -1)

		FRAME_STACK								; // スタック領域の確保

		; レジスタの保存
		mov		[save_rsi], rsi					; // レジスタの保存
		mov		[save_rdi], rdi					; // レジスタの保存
		mov		[x0], rcx						; // 引数の保存
		mov		[y0], rdx						; // 引数の保存
		mov		[x1], r8						; // 引数の保存
		mov		[y1], r9						; // 引数の保存

		;---------------------------------------
		; 幅を計算（X軸）
		;---------------------------------------
		mov		rcx, [x0]						; RCX = X0;
		mov		rdx, [x1]						; RDX = X1;
		sub		rdx, rcx						; RDX = X1 - X0; // 幅
		jge		.10F							; if (RDX < 0)
												; {
		neg		rdx								;   RDX  *= -1;  // 符号反転
		mov		qword [inc_x], -1				;   inc_x = -1;  // X座標の増分
		jmp		.10E							; }
.10F:											; else
												; {
		mov		qword [inc_x], 1				;   inc_x =  1;  // X軸:増分
.10E:											; }
												; 
		mov		[cur_x], rcx					; cur_x = RCX;   // X軸:開始座標
		mov		[dlt_x], rdx					; dlt_x = RDX;   // X軸:描画幅

		;---------------------------------------
		; 高さを計算（Y軸）
		;---------------------------------------
		mov		rcx, [y0]						; RCX = Y0;
		mov		rdx, [y1]						; RDX = Y1;
		sub		rdx, rcx						; RDX = Y1 - Y0; // 高さ
		jge		.20F							; if (RDX < 0)
												; {
		neg		rdx								;   RDX  *= -1;  // 符号反転
		mov		qword [inc_y], -1				;   inc_y = -1;  // Y軸:増分
		jmp		.20E							; }
.20F:											; else
												; {
		mov		qword [inc_y], 1				;   inc_y =  1;  // Y軸:増分
.20E:											; }
												; 
		mov		[cur_y], rcx					; cur_y = RCX;   // Y軸:開始座標
		mov		[dlt_y], rdx					; dlt_y = RDX;   // Y軸:描画幅

		;---------------------------------------
		; 基準軸を決める
		;---------------------------------------
		mov		rcx, [dlt_x]					; 
		cmp		rcx, [dlt_y]					; if (幅 <= 高さ)
		jg		.30F							; {
												;   
		lea		rsi, [cur_y]					;   // Y軸が基準軸
		lea		rdi, [cur_x]					;   // X軸が相対軸
												;   
		jmp		.30E							; }
.30F:											; else
												; {
		lea		rsi, [cur_x]					;   // X軸が基準軸
		lea		rdi, [cur_y]					;   // Y軸が相対軸
.30E:											; }

		;---------------------------------------
		; 線を描画
		;---------------------------------------
		mov		qword [sum], 0					; sum = 0; // 相対軸の積算値
		mov		qword [count], 0				; count = 0; 
.50L:	mov		rcx, [count]					;      
		cmp		rcx, [rsi - 8]					; while(count < [rsi - 8])
		jae		.50E							; {

		mov		rcx, [cur_x]					;   RCX = X座標;
		mov		rdx, [cur_y]					;   RDX = Y座標;
		mov		r8, [color]						;   R8 = 色;
		xcall	draw_pixel, rcx, rdx, r8		;   draw_pixel();

												;   // 基準軸を更新(1ドット分)
		mov		rcx, [rsi - 16]					;   RCX = 基準軸増分(1 or -1);
		add		[rsi - 0], rcx					;   

												;   // 相対軸を更新
		mov		rcx, [sum]						;   RCX  = sum; // 相対軸の積算値;
		add		rcx, [rdi - 8]					;   RCX += dy;  // 増分(相対軸の描画幅)
		mov		rdx, [rsi - 8]					;   RDX  = dx;  // 増分(基準軸の描画幅)

		cmp		rcx, rdx						;   if (積算値 <= 相対軸の増分)
		jl		.52E							;   {
		sub		rcx, rdx						;     RCX -= RDX; // 積算値から相対軸の増分を減算
												;     
												;     // 相対軸の座標を更新(1ドット分)
		mov		rdx, [rdi - 16]					;     RDX =  相対軸増分;
		add		[rdi - 0], rdx					;     
.52E:											;   }
		mov		[sum], rcx						;   // 積算値を更新
												;   
		inc		qword [count]					;   count++;
												;   
		jmp		.50L							;   
.50E:											; }

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		mov		rsi, [save_rsi]					; // レジスタの復帰
		mov		rdi, [save_rdi]					; // レジスタの復帰
		FRAME_END								; // フレームの終了
