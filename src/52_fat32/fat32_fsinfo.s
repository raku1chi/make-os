;************************************************************************
;	0000_0200 : FSInfo
;************************************************************************
		dd		0x41615252						; FSI_LeadSig
		times 480 db 0							; 予約
		dd		0x61417272						; FSI_StrucSig
		dd		0xFFFFFFFF						; FSI_Free_Count
		dd		32								; FSI_Nxt_Free
		times 12 db 0							; 予約
		dd		0xAA550000						; FSI_TrailSig
