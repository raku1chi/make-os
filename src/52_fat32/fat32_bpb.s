;************************************************************************
;	FAT32
;************************************************************************
.TOP:
		;---------------------------------------
		; BPB(BIOS Parameter Block)
		;---------------------------------------
		jmp		.ipl							; 0x00( 3) ブートコードへのジャンプ命令
		db		0x90							; 
		db		'OEM-NAME'						; 0x03( 8) OEM名
												; -------- --------------------------------
		dw		512								; 0x0B( 2) セクタのバイト数
		db		8								; 0x0D( 1) クラスタのセクタ数
		dw		FAT32_RESERVED_SECT				; 0x0E( 2) 予約セクタ数
		db		2								; 0x10( 1) FAT数
		dw		0								;*0x11( 2) ルートエントリ数
		dw		0								;*0x13( 2) 総セクタ数16
		db		0xF8							; 0x15( 1) メディアタイプ
		dw		0								;*0x16( 2) FATのセクタ数
		dw		0								;*0x18( 2) トラックのセクタ数
		dw		0								;*0x1A( 2) ヘッド数
		dd		FAT32_HIDDEN_SECT				; 0x1C( 4) 隠されたセクタ数
		dd		FAT32_TOTAL_SECT				; 0x20( 4) 総セクタ数32

		dd		FAT32_FAT_SECT					; 0x24( 4) FATのセクタ数
		dw		0			 					; 0x28( 2) BPB_ExtFlags
		dw		0								; 0x2A( 2) BPB_FSVer
		dd		2					 			; 0x2C( 4) BPB_RootClus
		dw		FAT32_FSINFO_SECT				; 0x30( 2) BPB_FSInfo
		dw		FAT32_BACKUP_SECT				; 0x32( 2) BPB_BkBootSec
		times 12 db 0							; 0x34(12) 予約
												; -------- --------------------------------
		db		0x80							; 0x44( 1) ドライブ番号
		db		0								; 0x45( 1) （予約）
		db		0x29							; 0x46( 1) ブートフラグ
		dd		0xdeadbeef						; 0x47( 4) シリアルナンバー
		db		'BOOTABLE   '					; 0x4B(11) ボリュームラベル
		db		'FAT32   '						; 0x56( 8) FATタイプ

		;---------------------------------------
		; エラーメッセージの表示
		;---------------------------------------
.ipl	push	cs								; 
		pop		ds								; DS = CS;
		mov		si, 0x7C00 + (.s0 - .TOP)		; SI = .s0; // 出力文字列
.10L:	lodsb									; while (AL = *SI++)
		and		al, al							; {
		je		.10E							;   
		push	si								;   // SIを保存
		mov		ah, 0x0E						;   AH = 0x0E; // 1文字出力 
		mov		bx, 0x0007						;   BX = 0x07; // 文字色
		int		0x10							;   int10(); // 1文字出力 
		pop		si								;   // SIを復帰
		jmp		.10L							;  
.10E:											; }
		xor		ah, ah							; AH = 0;
		int		0x16							; int16(); // キー入力
		int		0x19							; int19(); // 再起動
		jmp		$								; while (1) ; // 無限ループ

.s0:	db	"This is not a bootable disk.  "
		db	"Please insert a bootable floppy and"
		db	0x0D, 0x0A
		db	"press any key to try again ... "
		db	0x0D, 0x0A

		;---------------------------------------
		; ブートフラグ
		;---------------------------------------
		times	510 - ($ - .TOP) db 0
		db	0x55, 0xAA
