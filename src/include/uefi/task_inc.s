;************************************************************************
;	タスク用定義
;************************************************************************
;-----------------------------------------------
;	タスクパラメータ
;-----------------------------------------------
struc TASK_PARAM
		.id				resq	1				; タスクID
		.title			resb	16				; タイトル

		.col			resq	1				; タスク情報表示位置：列
		.row			resq	1				; タスク情報表示位置：行
		.counter		resq	1				; カウンタ

		.n				resq	1				; n
		.d				resq	1				; d

		.x0				resq	1				; 左上座標：X0
		.y0				resq	1				; 左上座標：Y0
		.x1				resq	1				; 右下座標：X1
		.y1				resq	1				; 右下座標：Y1

		.color_x		resq	1				; X軸描画色
		.color_y		resq	1				; Y軸描画色
		.color_z		resq	1				; 枠描画色
		.color_s		resq	1				; 文字列描画色
		.color_f		resq	1				; 曲線描画色
		.color_b		resq	1				; グラフ背景色
		.color_e		resq	1				; 曲線消去色
endstruc

%define	TPARAM(adr, ofs)	[adr + TASK_PARAM %+ ofs]

