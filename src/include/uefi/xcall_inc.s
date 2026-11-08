;************************************************************************
; 関数呼び出し用マクロ
;************************************************************************
;---------------------------------------
; 第1～4引数の設定用マクロ
;---------------------------------------
%macro rparam 1-2
	%if 2 <= %0
		%ifnidni %1, %2
			%ifid %2
				mov		%1, %2
			%elifnum %2
				mov		%1, %2
			%else
				lea		%1, %2
			%endif
		%endif
	%endif
%endmacro

;---------------------------------------
; 第5～6引数の設定用マクロ
;---------------------------------------
%macro mparam 1-2
	%if 2 <= %0
		%ifid %2
			%iftoken %2
				mov		%1, %2
			%else
				xchg	rax, %1
				mov		rax, %2
				xchg	rax, %1
			%endif
		%elifnum %2
			mov		qword %1, %2
		%else
			xchg	rax, %1
			lea		rax, %2
			xchg	rax, %1
		%endif
	%endif
%endmacro

;---------------------------------------
; 関数呼び出し用マクロ
;---------------------------------------
%macro  xcall 1-7.nolist
	%if 2 <= %0
		rparam rcx, %2
	%endif
	%if 3 <= %0
		rparam rdx, %3
	%endif
	%if 4 <= %0
		rparam r8, %4
	%endif
	%if 5 <= %0
		rparam r9, %5
	%endif
	%if 6 <= %0
		mparam [rsp + 32], %6
	%endif
	%if 7 <= %0
		mparam [rsp + 40], %7
	%endif
	call	%1
%endmacro

;---------------------------------------
; syscall呼び出し用マクロ
;---------------------------------------
%macro  scall 1-7.nolist
	mov		rax, %1
	%if 2 <= %0
		rparam	rdi, %2
	%endif
	%if 3 <= %0
		rparam	rsi, %3
	%endif
	%if 4 <= %0
		rparam	rdx, %4
	%endif
	%if 5 <= %0
		rparam	r10, %5
	%endif
	%if 6 <= %0
		rparam	r8, %6
	%endif
	%if 7 <= %0
		rparam	r9, %7
	%endif
	syscall
%endmacro
