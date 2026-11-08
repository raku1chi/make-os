;************************************************************************
;	アプリケーション用定義
;************************************************************************
		COLOR_TRANSPARENT	equ		0x01_000000

		COLOR_WHITE			equ		0x00_FFFFFF
		COLOR_RED			equ		0x00_FF0000
		COLOR_GREEN			equ		0x00_00FF00
		COLOR_BLUE			equ		0x00_0000FF
		COLOR_GRAY			equ		0x00_C0C0C0
		COLOR_DISPLAY_BG	equ		0x00_018281
		COLOR_TASK_BAR_BG	equ		0x00_C7C7C7
		COLOR_TASK_BAR_TOP	equ		0x00_F7F7F7
		COLOR_TB_RECT_FG	equ		0x00_333333
		COLOR_TB_RECT_BG	equ		COLOR_TASK_BAR_BG

		CHAR_WIDTH			equ		8
		CHAR_HEIGHT			equ		19
		TASK_BAR_H			equ		(CHAR_HEIGHT + 7)

%define	COL(n)				(CHAR_WIDTH  * (n))
%define	ROW(n)				(CHAR_HEIGHT * (n))
