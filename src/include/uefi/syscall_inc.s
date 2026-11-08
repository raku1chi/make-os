;************************************************************************
;	システムコール用定義
;************************************************************************
		SYS_DRAW_STR				equ		0
		SYS_ITOA					equ		1
		SYS_DRAW_PIXEL				equ		2
		SYS_DRAW_LINE				equ		3
		SYS_DRAW_FRAME				equ		4
%ifdef USE_SYS_WAIT_TICK
		SYS_WAIT_TICK				equ		5
%endif
