;************************************************************************
;	タスク用描画領域の設定
;========================================================================
;■書式		: void init_draw_area();
;
;■引数		: 無し
;
;■戻り値	: 無し
;************************************************************************
init_draw_area:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
		FRAME_BEGIN								; // フレームの開始
		FRAME_STACK								; // スタック領域の確保

		;---------------------------------------
		; 右上のエリアを設定
		;---------------------------------------
		mov		rcx, [Video.VerticalResolution]	; RCX = 縦幅;
		sub		rcx, TASK_BAR_H + 30			; RCX -= タスクバーのサイズ分減算;
		shr		rcx, 1							; RCX /= 2;

		mov		r8, [Video.HorizontalResolution]; R8 = 画面の右端;
		sub		r8, rcx							; R8 = 画面の右端 - 描画サイズ;
		mov		r9, [Video.HorizontalResolution]; R9 = 画面の右端;
		sub		r9, 30							; R9 = 画面の右端 - 境界サイズ;
		mov		TPARAM(Task.Param_2, .x0), r8	; X0 = R8;
		mov		TPARAM(Task.Param_2, .x1), r9	; X1 = R9;

		mov		r8, 30							; R8 = 境界サイズ;
		mov		TPARAM(Task.Param_2, .y0), r8	; Y0 = R8;
		mov		TPARAM(Task.Param_2, .y1), rcx	; Y1 = RCX;

		;---------------------------------------
		; 左上のエリアを設定（右上のエリアから計算）
		;---------------------------------------
		mov		rdx, TPARAM(Task.Param_2, .x0)	; Param_1.x0 = Param_2.x0 - 描画サイズ;
		sub		rdx, rcx						; 
		mov		TPARAM(Task.Param_1, .x0), rdx	; 

		mov		rdx, TPARAM(Task.Param_2, .x1)	; Param_1.x1 = Param_2.x0 - 描画サイズ;
		sub		rdx, rcx						; 
		mov		TPARAM(Task.Param_1, .x1), rdx	; 

		mov		rdx, TPARAM(Task.Param_2, .y0)	; Param_1.x0 = Param_2.y0;
		mov		TPARAM(Task.Param_1, .y0), rdx	; 

		mov		rdx, TPARAM(Task.Param_2, .y1)	; Param_1.y1 = Param_2.y1;
		mov		TPARAM(Task.Param_1, .y1), rdx	; 

		;---------------------------------------
		; 右下のエリアを設定（右上のエリアから計算）
		;---------------------------------------
		mov		rdx, TPARAM(Task.Param_2, .x0)	; Param_4.x0 = Param_2.x0;
		mov		TPARAM(Task.Param_4, .x0), rdx	; 

		mov		rdx, TPARAM(Task.Param_2, .x1)	; Param_4.x1 = Param_2.x0;
		mov		TPARAM(Task.Param_4, .x1), rdx	; 

		mov		rdx, TPARAM(Task.Param_2, .y0)	; Param_4.x0 = Param_2.y0 - 描画サイズ;
		add		rdx, rcx						; 
		mov		TPARAM(Task.Param_4, .y0), rdx	; 

		mov		rdx, TPARAM(Task.Param_2, .y1)	; Param_4.y1 = Param_2.y1 - 描画サイズ;
		add		rdx, rcx						; 
		mov		TPARAM(Task.Param_4, .y1), rdx	; 

		;---------------------------------------
		; 左下のエリアを設定（右上のエリアから計算）
		;---------------------------------------
		mov		rdx, TPARAM(Task.Param_2, .x0)	; Param_3.x0 = Param_2.x0 - 描画サイズ;
		sub		rdx, rcx						; 
		mov		TPARAM(Task.Param_3, .x0), rdx	; 

		mov		rdx, TPARAM(Task.Param_2, .x1)	; Param_3.x1 = Param_2.x0 - 描画サイズ;
		sub		rdx, rcx						; 
		mov		TPARAM(Task.Param_3, .x1), rdx	; 

		mov		rdx, TPARAM(Task.Param_2, .y0)	; Param_3.x0 = Param_2.y0 - 描画サイズ;
		add		rdx, rcx						; 
		mov		TPARAM(Task.Param_3, .y0), rdx	; 

		mov		rdx, TPARAM(Task.Param_2, .y1)	; Param_3.y1 = Param_2.y1 - 描画サイズ;
		add		rdx, rcx						; 
		mov		TPARAM(Task.Param_3, .y1), rdx	; 

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		FRAME_END								; // フレームの終了
