;************************************************************************
;	割り込み処理：#NM(DNA:デバイス使用不可)
;************************************************************************
int_nm:
		;---------------------------------------
		; 【レジスタの保存】
		;---------------------------------------
		push_all								; // レジスタの保存

		;---------------------------------------
		; タスクスイッチフラグをクリア
		;---------------------------------------
		clts									; CR0.TS = 0;

		;---------------------------------------
		; SSEの利用をチェック
		;---------------------------------------
												; do
												; {
		mov		rax, [Task.UsedSse]				;   RAX = 前回SSEを使用したタスク;
		cmp		rax, 0							;   if (0 == Task.UsedSse)
		je		.10E							;     break; // 初回使用
												;   
		cmp		[Task.Current], rax				;   if (Task.Current == Task.UsedSse)
		je		.10E							;     break; // 同じタスク
												;   
		mov		rcx, TCTRL(rax, .sse_context)	;   // 前回使用したタスクのコンテキストを保存
		fxsave	[rcx]							;   fxsave();
		mov		qword TCTRL(rax, .sse_saved), 1	;   sse_saved = 1;
												;   
		mov		rax, [Task.Current]				;   // 今回使用するタスクのコンテキストを復帰
		cmp		qword TCTRL(rax, .sse_saved), 0 ;   if (0 == sse_saved)
		je		.10E							;     break; // コンテキスト未保存
												;     
		mov		rcx, TCTRL(rax, .sse_context)	;   // コンテキストを復帰
		fxrstor	[rcx]							;   fxrstor();
.10E:											; } while (0);

		;---------------------------------------
		; SSEを使用したタスクを更新
		;---------------------------------------
		mov		rax, [Task.Current]				; 
		mov		[Task.UsedSse], rax				; Task.UsedSse = Task.Current;

		;---------------------------------------
		; 【レジスタの復帰】
		;---------------------------------------
		pop_all									; // レジスタの復帰
		iretq
