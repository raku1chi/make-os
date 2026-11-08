;************************************************************************
;	APICタイマー用定義
;************************************************************************
;---------------------------------------
; レジスタアクセス用構造体
;---------------------------------------
struc LOCAL_APIC
		DWORD 4,							Reserved_00					; 0000:Reserved
		DWORD 4,							Reserved_01					; 0010:Reserved
		DWORD 4,							ID							; 0020:Local APIC ID Register
		DWORD 4,							Version						; 0030:Local APIC Version Register
		DWORD 4,							Reserved_02					; 0040:(Reserved)
		DWORD 4,							Reserved_03					; 0050:(Reserved)
		DWORD 4,							Reserved_04					; 0060:(Reserved)
		DWORD 4,							Reserved_05					; 0070:(Reserved)
		DWORD 4,							TPR							; 0080:Task Priority Register (TPR)
		DWORD 4,							APR							; 0090:Arbitration Priority Register (APR)
		DWORD 4,							PPR							; 00A0:Processor Priority Register (PPR)
		DWORD 4,							EOI							; 00B0:EOI Register
		DWORD 4,							RRD							; 00C0:Remote Read Register (RRD)
		DWORD 4,							LDR							; 00D0:Logical Destination Register
		DWORD 4,							DFR							; 00E0:Destination Format Register
		DWORD 4,							SIVR						; 00F0:Spurious Interrupt Vector Register

		DWORD 4,							ISR_0						; 0100:In-Service Register (ISR[ 31:  0])
		DWORD 4,							ISR_1						; 0110:In-Service Register (ISR[ 63: 32])
		DWORD 4,							ISR_2						; 0120:In-Service Register (ISR[ 95: 64])
		DWORD 4,							ISR_3						; 0130:In-Service Register (ISR[127: 96])
		DWORD 4,							ISR_4						; 0140:In-Service Register (ISR[159:128])
		DWORD 4,							ISR_5						; 0150:In-Service Register (ISR[191:160])
		DWORD 4,							ISR_6						; 0160:In-Service Register (ISR[223:192])
		DWORD 4,							ISR_7						; 0170:In-Service Register (ISR[255:224])
		DWORD 4,							TMR_0						; 0180:Trigger Mode Register (TMR[ 31:  0])
		DWORD 4,							TMR_1						; 0190:Trigger Mode Register (TMR[ 63: 32])
		DWORD 4,							TMR_2						; 01A0:Trigger Mode Register (TMR[ 95: 64])
		DWORD 4,							TMR_3						; 01B0:Trigger Mode Register (TMR[127: 96])
		DWORD 4,							TMR_4						; 01C0:Trigger Mode Register (TMR[159:128])
		DWORD 4,							TMR_5						; 01D0:Trigger Mode Register (TMR[191:160])
		DWORD 4,							TMR_6						; 01E0:Trigger Mode Register (TMR[223:192])
		DWORD 4,							TMR_7						; 01F0:Trigger Mode Register (TMR[255:224])

		DWORD 4,							IRR_0						; 0200:Interrupt Request Register (IRR[ 31:  0])
		DWORD 4,							IRR_1						; 0210:Interrupt Request Register (IRR[ 63: 32])
		DWORD 4,							IRR_2						; 0220:Interrupt Request Register (IRR[ 95: 64])
		DWORD 4,							IRR_3						; 0230:Interrupt Request Register (IRR[127: 96])
		DWORD 4,							IRR_4						; 0240:Interrupt Request Register (IRR[159:128])
		DWORD 4,							IRR_5						; 0250:Interrupt Request Register (IRR[191:160])
		DWORD 4,							IRR_6						; 0260:Interrupt Request Register (IRR[223:192])
		DWORD 4,							IRR_7						; 0270:Interrupt Request Register (IRR[255:224])
		DWORD 4,							ESR							; 0280:Error Status Register
		DWORD 4,							Reserved_29					; 0290:-
		DWORD 4,							Reserved_2A					; 02A0:-
		DWORD 4,							Reserved_2B					; 02B0:-
		DWORD 4,							Reserved_2C					; 02C0:-
		DWORD 4,							Reserved_2D					; 02D0:-
		DWORD 4,							Reserved_2E					; 02E0:-
		DWORD 4,							CMCI						; 02F0:LVT Corrected Machine Check Interrupt (CMCI) Register

		DWORD 4,							ICR_0						; 0300:Interrupt Command Register (ICR); bits 0-31
		DWORD 4,							ICR_1						; 0310:Interrupt Command Register (ICR); bits 32-63
		DWORD 4,							LVT_TR						; 0320:LVT Timer Register
		DWORD 4,							LVT_TSR						; 0330:LVT Thermal Sensor Register
		DWORD 4,							LVT_PMCR					; 0340:LVT Performance Monitoring Counters Register
		DWORD 4,							LVT_LINT0					; 0350:LVT LINT0 Register
		DWORD 4,							LVT_LINT1					; 0360:LVT LINT1 Register
		DWORD 4,							LVT_ER						; 0370:LVT Error Register
		DWORD 4,							ICR							; 0380:Initial Count Register (for Timer)
		DWORD 4,							CCR							; 0390:Current Count Register (for Timer)
		DWORD 4,							Reserved_3A					; 03A0:-
		DWORD 4,							Reserved_3B					; 03B0:-
		DWORD 4,							Reserved_3C					; 03C0:-
		DWORD 4,							Reserved_3D					; 03D0:-
		DWORD 4,							DCR							; 03E0:Divide Configuration Register (for Timer)
		DWORD 4,							Reserved_3F					; 03F0:-
endstruc

;---------------------------------------
; 構造体要素へのアクセス
;---------------------------------------
%define	LAPIC(adr, ofs)		dword [adr + LOCAL_APIC %+ ofs]
