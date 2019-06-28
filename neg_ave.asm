TITLE Negative Average     (neg_ave.asm)

; Author: Zach Reed						reedz@oregonstate.edu
; CS271-400 / Program 3                 Date: 5/6/2018
; Description: Gets negative integers within the range [-100, 1] from user until user enters a positive number. The rounded average of the negative integers is calculated and displayed

INCLUDE Irvine32.inc

; constants for range [-100, -1]
neg_min EQU <-100>	
neg_max EQU <-1>

.data
; Constant Definitions ---------------------------------

	line_sep	BYTE	"------------------------------------------", 0
	prog_titl	BYTE	"Program: Negative Input Average Calculator", 0
	prog_auth	BYTE	"Author: Zach Reed", 0
	prompt_1	BYTE	"Please enter your name: ", 0
	prompt_2	BYTE	"Please enter an integer: ", 0
	greet		BYTE	"Welcome to the program, ", 0
	period		BYTE	'.',0
	instruct_1	BYTE	"Enter a negative number from the range [-100, -1] to add", 0
	instruct_2	BYTE	"to the average or, enter a positive number to end loop.", 0
	error_1		BYTE	"The input is out of range. Integers must be greater than or equal to -100.", 0
	error_2		BYTE	"The input is out of range. Integers must be less than or equal to -1.", 0
	sp_msg_1	BYTE	", you didn't enter any negative values. You aren't very good at this.", 0
	bye_1		BYTE	"Well ", 0
	bye_2		BYTE	", this is the end of the program. Farewell.", 0
	ave_msg		BYTE	"The rounded average of the integers is: ", 0
	sum_msg		BYTE	"The sum of the integers is: ", 0
	num_ent_1	BYTE	"You entered ", 0
	num_ent_2	BYTE	" negative integers.", 0
	neg_ch		BYTE	"-", 0

; Variable Definitions ---------------------------------
	usr_nme		BYTE	50 DUP(0)	; name allocated with 50 characters
	input		SDWORD	?			; input from user
	avg_q		SDWORD	?			; quotient from average calculation
	avg_r		SDWORD	?			; remainder from average calculation
	avg_dec		DWORD	?			; decimal point remainder of average
	adj_ave		SDWORD	?			; rounded average
	accum_v		DWORD	0			; accumulator
	total_v		SDWORD	0			; running sum

.code
main PROC

; Introduction ---------------------------------
intro:
	call	CrLf						;
	mov		edx, OFFSET		line_sep	;
	call	WriteString					;
	call	CrLf						;
	mov		edx, OFFSET		prog_titl	;
	call	WriteString					;
	call	CrLf						;
	mov		edx, OFFSET		prog_auth	;
	call	WriteString					;
	call	CrLf						;
	mov		edx, OFFSET		line_sep	;
	call	WriteString					;
	call	CrLf						;

	; Get User Name ---------------------
	mov		edx, OFFSET		prompt_1	;
	call	WriteString					;
	mov		ecx, 50						;
	mov		edx, OFFSET		usr_nme		;
	call	ReadString					;
	call	CrLf						;

	; Greet User ------------------------
	mov		edx, OFFSET		greet		;
	call	WriteString					;
	mov		edx, OFFSET		usr_nme		;
	call	WriteString					;
	mov		al, period					;
	call	WriteChar					;
	call	CrLf						;

	; Instructions ----------------------
	mov		edx, OFFSET		instruct_1	;
	call	WriteString					;
	call	CrLf						;
	mov		edx, OFFSET		instruct_2	;
	call	WriteString					;
	call	CrLf						;


; Get Negative/Positive Integer ----------------
get_int:
	mov		edx, OFFSET		prompt_2	;
	call	WriteString					;
	mov		eax, input					;
	call	ReadInt						;
	mov		input, eax					;

	; Compare to positive value ---------
	test	eax, eax					; check sign flag
	js		min_check					; if negative
	jmp		check_acc					; if positive

; Check Minimum Negative Value -----------------
min_check:
	mov		eax, input					;
;	neg		eax							;
	cmp		eax, neg_min				;
	jae		max_check					;

	; Error in negative int -------------
	mov		edx, OFFSET error_1			;
	call	WriteString					;
	call	CrLf						;
	jmp		get_int						;

; Check Maximum Negative Value -----------------
max_check:
	mov		eax, input					;
;	neg		eax							;
	cmp		eax, neg_max				;
	jbe		add_val						;

	; Error in negative int -------------
	mov		edx, OFFSET error_2			;
	call	WriteString					;
	call	CrLf						;
	jmp		get_int						;

; Adds value to Total Input and Increments Accumulator
add_val:
	mov		eax, input					;
	neg		eax							;
	add		eax, total_v				; add input to total
	mov		total_v, eax				;
	inc		accum_v						; increment accum_v
	jmp		get_int						;

; Check Accumulator for Special Case -----------
check_acc:
	mov		eax, accum_v				;
	cmp		eax, 0						; compare to zero
	je		sp_msg						; jump to special message

	jmp		calc_ave					; calculate average

; Special Message if Accumulator is Zero -------
sp_msg:
	mov		edx, OFFSET		usr_nme		;
	call	WriteString					;
	mov		edx, OFFSET		sp_msg_1	;
	call	WriteString					;
	call	CrLf						;
	jmp		bye							;

; Calculate Average	----------------------------
calc_ave:
	mov		eax, total_v				; average is stored as a positive value
	cdq									; extend sign to edx
	mov		ebx, accum_v				;
	div		ebx							; divide total_v by accum_v
	mov		avg_q, eax					; quotient in eax
	mov		avg_r, edx					; remainder in edx
	mov		adj_ave, eax				;

	; calculate remainder in decimal value -----
	mov		eax, avg_r					;
	imul	eax, accum_v				;
	mov		avg_dec, eax				;
		
	; compare average remainder for rounding ---
	cmp		avg_dec, 5					; compare remainder to 5
	ja		rem_above					; jump if above 5

	jmp		disp_val					;

; Increment Adjusted Average -------------------
; Average is stored in a positive value --------
rem_above:
	inc		adj_ave						; value is incremented to represent the number decreasing negatively

; Display Values -------------------------------
disp_val:	
	; number of values entered-----------
	call	CrLf						;
	mov		edx, OFFSET		num_ent_1	;
	call	WriteString					;
	mov		eax, accum_v				;
	call	WriteDec					;
	mov		edx, OFFSET		num_ent_2	;
	call	WriteString					;
	call	CrLf						;

	; sum of values ---------------------
	mov		edx, OFFSET		sum_msg		;
	call	WriteString					;
	mov		edx, OFFSET		neg_ch		;
	call	WriteString					;
	mov		eax, total_v				;
	call	WriteDec					;
	call	CrLf						;

	; average of values -----------------
	mov		edx, OFFSET		ave_msg		;
	call	WriteString					;
	mov		edx, OFFSET		neg_ch		;
	call	WriteString					;
	mov		eax, adj_ave				;
	call	WriteDec					;
	call	CrLf						;


; Good-bye Message -----------------------------
bye:
	call	CrLf						;
	mov		edx, OFFSET		bye_1		;
	call	WriteString					;
	mov		edx, OFFSET		usr_nme		;
	call	WriteString					;
	mov		edx, OFFSET		bye_2		;
	call	WriteString					;
	call	CrLf						;

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
