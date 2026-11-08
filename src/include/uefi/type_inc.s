;************************************************************************
; データ型定義用マクロ
;************************************************************************
%macro  INT8 1-2
        %if %0 < 2
            .%{1}: resb 1
        %else
            .%{2}: resb %1
        %endif
%endmacro

%macro  INT16 1-2
        %if %0 < 2
            .%{1}: resw 1
        %else
            .%{2}: resw %1
        %endif
%endmacro

%macro  INT32 1-2
        %if %0 < 2
            .%{1}: resd 1
        %else
            .%{2}: resd %1
        %endif
%endmacro

%macro  INT64 1-2
        %if %0 < 2
            .%{1}: resq 1
        %else
            .%{2}: resq %1
        %endif
%endmacro

%define     UINT8		INT8
%define     UINT16      INT16
%define     UINT32      INT32
%define     UINT64      INT64
%define     INTN        INT64
%define     UINTN       INTN
%define     PTR         INT64

%define     BYTE        UINT8
%define     WORD        UINT16
%define     DWORD       UINT32
%define     QWORD       UINT64
