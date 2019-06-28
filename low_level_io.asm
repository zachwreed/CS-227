TITLE low_level_io     (low_level_io.asm)

; Author: Zach Reed
; CS271 / Program 6a              Date: 6/10/2018
; Description: User-inputed string is converted to dword, then placed in an array to calculate sum and average. 
;              The calculations and array are then converted back to strings to be written.

INCLUDE Irvine32.inc

; (insert constant definitions here)

; -------------------------------------
; Get String Macro 
;   String prompt and str as parameter		
;   Register effected: ecx, edx
; -------------------------------------
getString		MACRO	prompt, str, size
	push	ecx						;
	push	edx						;
	mov		edx, prompt				;
	call	WriteString				;	
	mov		ecx, size				;
	mov		edx, str				;
	call	ReadString				;
	pop		edx						;
	pop		ecx						;

ENDM 

; -------------------------------------
; Display String Macro 
;   String str as parameter		
;   Register effected: edx
; -------------------------------------
displayString	MACRO	str
	push	edx						;
	mov		edx, str				;
	call	WriteString				;
	pop		edx						;

ENDM



.data
	descript	BYTE	"Assignment 6: I/O Procedures", 0
	author		BYTE	"Author: Zach Reed", 0
	str_prompt	BYTE	"Please enter a string: ", 0							; 24 bits
	instruct_1	BYTE	"You will provide 10 unsigned decimal integers. ", 0	; 48 bits
	instruct_2  BYTE	"Each value needs to be small enough to fit inside a 32-bit register.   ", 0	; 72 bits
	instruct_3  BYTE	"After the values have been validated, the average, sum, and entries will be displayed  ",0 ; 88 bits
	error_1		BYTE	"The value entered contained non-digits or the value entered is too larger for a 32-bit register", 0
	sum_msg		BYTE	"The sum of the values is: ", 0
	ave_msg		BYTE	"The average of the values is: ", 0
	str_enter	BYTE	"You entered the following: ", 0
	input_count	DWORD	10
	input_buff	BYTE	300 DUP(?)
	input_dword	DWORD	?
	input_buff_z DWORD	300
	array		DWORD	10 DUP(0)
	str_arr		BYTE	20 DUP(?)
	ave			DWORD   ?
	sum			DWORD	?
	thr_spc		BYTE	", ", 0
	spc			BYTE	"  ", 0


.code
main PROC
	
	; Call Introduction -------------
	push	OFFSET instruct_3		;
	push	OFFSET instruct_2		;
	push	OFFSET instruct_1		;
	call	Introduction			;

	mov		ecx, input_count		;
	mov		edi, OFFSET array		;

	; Read Values to Array ----------
	read_loop:
		push	OFFSET input_dword		;
		push	input_buff_z			;
		push	OFFSET error_1			;
		push	OFFSET str_prompt		;
		push	OFFSET input_buff		;
		call	ReadVal					;

		mov		ebx, input_dword		;
		mov		[edi], ebx				;
		add		edi, 4					;
		loop	read_loop				;

	

	; Calculate Sum and Average -----------
	sum_ave:
		push	OFFSET array			;
		push	OFFSET sum_msg			;
		push	OFFSET ave_msg			;
		push	input_count				;
		push	OFFSET ave				;	
		push	OFFSET sum				;				
		call	Ave_Sum					;

		mov		edi, OFFSET array		;
		mov		ecx, input_count		;
		displayString OFFSET str_enter	;

	; Write Values to Str_arr ----------------
	write_loop:
		mov		eax, [edi]				;
		push	OFFSET str_arr			;
		push	eax						;
		push	OFFSET thr_spc			;
		call	writeVal				;
		add		edi, 4					;
		loop	write_loop				;
		call	CrLf					;

	; Write Sum and Average -------------------
	wr_sum_ave:
		displayString OFFSET sum_msg	;
		push	OFFSET sum_msg			;
		push	sum						;
		push	OFFSET spc				;
		call	writeVal				;
		call	CrLf					;

		displayString OFFSET ave_msg
		push	OFFSET ave_msg			;
		push	ave						;
		push	OFFSET spc				;
		call	writeVal				;
		call	CrLf					;

exit	; exit to operating system
main ENDP

; Introduction --------------------------------
;
; Registers Modified: none
; -------------------------------------------------
Introduction	PROC
	push	ebp					; create stack frame
	mov		ebp, esp			;
	displayString	[ebp + 8]	;
	call	CrLf				;
	displayString	[ebp + 12]	;
	call	CrLf				;
	displayString	[ebp + 16]	;
	call	CrLf				;

	pop		ebp					;

ret				12
Introduction	ENDP

; Read Value ----------------------------------
;
; Registers Modified: eax, ebx, , edx, esi, edi
; -------------------------------------------------
ReadVal		PROC
	push	ebp						; create stack frame
	mov		ebp, esp				;
	pushad							;
	mov		edx, [ebp + 8]			; edx = str

	; Get string --------------------
	get_str_loop:
		mov			eax, 0			;
		mov			ebx, 10			;
		mov			ecx, 0			;
		getString	[ebp + 12], [ebp + 8], [ebp + 20]
		mov			edx, [ebp + 8]	;
		mov			esi, edx		; for lobsb

	; Load string byte --------------
	byte_load:
		lodsb						;
		cmp		ax, 0				;
		je		byte_load_fin		;

	; Check ASCII value low -------------
	byte_ascii_check_h:
		cmp			ax, 57				;
		ja			byte_error			;
	
	; Check ASCII value low -------------
	byte_ascii_check_l:
		cmp			ax, 48				;
		jb			byte_error			;

	; BYTE to DWORD ---------------------
	byte_to_dword:					
		sub			ax, 48				;
		xchg		ecx, eax			;
		mul			ebx					;
		jnc			byte_add_dig		; 

	; Error in input --------------------
	byte_error:
		displayString [ebp + 16]		;
		call	CrLf					;
		jmp		get_str_loop			;

	; Add Digit to total ----------------
	byte_add_dig:
		add		eax, ecx				;
		xchg	ecx, eax				;
		jmp		byte_load				; load next byte

	; Move on to next element in array --
	byte_load_fin:
		xchg	eax, ecx				;
		mov		esi, [ebp + 24] 		;
		mov		[esi], eax				;

	popad						;
	pop		ebp					;

ret			24
ReadVal		ENDP	

; Average & Sum Array -----------------------------
;
; Registers Modified: eax, ebx, , edx, esi, edi
; -------------------------------------------------
Ave_Sum		PROC
	push	ebp					; create stack frame
	mov		ebp, esp			;
	pushad						;

	mov		ecx, [ebp + 16]		;
	mov		eax, 0				;
	mov		edi, [ebp + 28]		;

	; calculate Sum -----------------
	sum_loop:
		mov		ebx, [edi]			;
		add		eax, ebx			;
		add		edi, 4				;
		loop	sum_loop			;
		mov		esi, [ebp + 8]		;
		mov		[esi], eax			;

	; calculate Average -------------
	ave_calc:
		mov		ebx, [ebp + 16]		;
		mov		edx, 0				;
		cdq							;
		div		ebx					;
		cmp		edx, 0				;
		jne		rem_above			; if rem >= 5, round up
		jmp		continue			; else continue

	; if remainder is above 5 -------
	rem_above:
		inc		eax					; round up
		jmp		continue			;
	
	; Store value in address --------
	continue:
		mov		esi, [ebp + 12]		;
		mov		[esi], eax			;

	popad
	pop		ebp					;

ret			24
Ave_Sum		ENDP


; Write Value to String Array ---------------------
;
; Registers Modified: eax, ebx, , edx, esi, edi
; -------------------------------------------------
writeVal	PROC				;
	push	ebp					;
	mov		ebp, esp			;
	pushad						;
	push	0					; for string stack
	mov		esi, [ebp + 12]		;
	mov		eax, esi			; eax = array[index]		
	mov		esi, [ebp + 16]		;
	mov		edi, esi			; edi = temp_str
	mov		ebx, 10				;
	mov		edx, 0				;

	; Convert digit to a byte ---
	byte_convert:
		cdq						;
		div		ebx				;
		add		edx, 48			;
		mov		esi, edx		;
		push	esi				; push last digit onto stack
		cmp		eax, 0			;
		je		byte_pop		;
		mov		ebx, 10			;
		mov		edx, 0			;
		jmp		byte_convert	;
	
	; Pop each byte off stack ---
	byte_pop:
		pop		[edi]			; reverse off stack for correct order
		mov		esi, [edi]		;	
		mov		eax, esi		;
		inc		edi				;
		cmp		eax, 0			; check if the end
		je		disp_str		;
		mov		eax, 0			;
		jmp		byte_pop		;
	
	; display each value ------------
	disp_str:
		displayString [ebp + 16]	;
		displayString [ebp + 8]		;

		popad
		pop	ebp

ret			12
writeVal	ENDP
END main
