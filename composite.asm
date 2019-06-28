TITLE composite     (composite.asm)

; Author: Zach Reed						reedz@oregonstate.edu
; CS271-400 / Program 3                 Date: 5/14/2018
; Description: calculates composite values up to the user-entered value
INCLUDE Irvine32.inc

; (insert constant definitions here)
max_input	EQU	<400>
min_input	EQU	<1>

.data
	line_sep	BYTE	"------------------------------------------", 0
	prog_titl	BYTE	"Program: Composite List Calculator", 0
	prog_auth	BYTE	"Author: Zach Reed", 0
	prompt		BYTE	"Please enter an integer: ", 0
	greet		BYTE	"Welcome to the program. ", 0
	period		BYTE	'.', 0
	spc_1		BYTE	' ', 0 
	spc_2		BYTE	'  ', 0
	spc_3		BYTE	'   ', 0
	instruct_1	BYTE	"Enter a negative number from the range [1, 400].", 0
	instruct_2	BYTE	"The value will determine how many composite numbers will be displayed", 0
	instruct_3	BYTE	"The composite output values will be aligned.", 0
	error_1		BYTE	"The input is out of range. Integers must be greater than or equal to 1.", 0
	error_2		BYTE	"The input is out of range. Integers must be less than or equal to 400.", 0
	bye		BYTE		"Well, this is the end of the program. Farewell.", 0

	; Variable Definitions ---------------------------------
	bool_input	DWORD	?			; bool for input value validation
	bool_isComp	DWORD	0			; bool for isComposite proc
	input		DWORD	?			; input from user
	quot_count  DWORD	?			; keeps count of number of divisible primes
	comp_num	DWORD	4			; number to be written in window, dividend
	iter_div	DWORD	2			; number to be divisor, loops up to comp_num
	comp_rem	DWORD	?			; remainder of division
	wr_size		DWORD	5			; write size


; (insert variable definitions here)

.code
; made up of procedure calls
main PROC
	call	introduction
	call	getUserData
	call	showComposites
	call	farewell

	exit	; exit to operating system
main ENDP

; Introduction ------------------------
introduction	PROC
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

	; Greet User ------------------------
	mov		edx, OFFSET		greet		;
	call	WriteString					;
	call	CrLf						;

	; Instructions ----------------------
	mov		edx, OFFSET		instruct_1	;
	call	WriteString					;
	call	CrLf						;
	mov		edx, OFFSET		instruct_2	;
	call	WriteString					;
	call	CrLf						;
	mov		edx, OFFSET		instruct_3	;
	call	WriteString					;
	call	CrLf						;

	ret
introduction	ENDP

; Get Data ----------------------------
getUserData	PROC

	get_input:
		mov		bool_input, 0				;
		mov		edx, OFFSET		prompt		;
		call	WriteString					;
		mov		eax, input					;
		call	ReadInt						;
		mov		input, eax					;

		call	validate					;
		cmp		bool_input, 1				;
		je		get_input					;

	ret
getUserData	ENDP

; validate Input -------------------------
validate	PROC

		mov		eax, input					;
		cmp		eax, max_input				;
		jbe		check_min					;

		mov		edx, OFFSET		error_2		;
		call	WriteString					;
		call	CrLf						;
		mov		bool_input, 1				;
		jmp		continue					;


	check_min:
		cmp		eax, min_input				;
		jae		continue					;

		mov		edx, OFFSET		error_1		;
		call	WriteString					;
		call	CrLf						;
		mov		bool_input, 1				;
		jmp		continue					;
	
	continue:

	ret
validate	ENDP

; Show Composites -------------------------------
showComposites PROC

	mov		ecx, input					; input to loop

	; start loop ------------------------
	start:
		call	isComposite				; 

	; check isComposite -----------------
	check_isComp:
		cmp		bool_isComp, 1			; if true
		je		print					;

		jmp		reset					;

	; print if composite ----------------
	print:
		mov		eax, comp_num			;
		call	WriteDec				; 
		cmp		eax, 100				; if 3 digits
		jge		wr_spc_1				;

		cmp		eax, 10					; if 2 digits
		jge		wr_spc_2				;

		mov		edx, OFFSET spc_3		; if 1 digits
		call	WriteString				;
		jmp		check_wr_size			;

	; write 1 space char ----------------
	wr_spc_1:
		mov		edx, OFFSET spc_1		; 
		call	WriteString				;
		jmp		check_wr_size			;
	
	; write 2 space chars ---------------
	wr_spc_2:
		mov		edx, OFFSET spc_2		; 
		call	WriteString				;
		jmp		check_wr_size			;
		
	; check write size ------------------
	check_wr_size:
		dec		wr_size					; decrease for each written value in line
		cmp		wr_size, 0				; compare values left to write on each line
		jg		reset					; call if no newline neeeded

		call	CrLf					; new line once 5 values are written
		add		wr_size, 5				; reset value
		jmp		reset					; jmp to loop
	
	
	; reset -----------------------------
	reset:
		mov		iter_div, 2				;
		inc		comp_num				;
		cmp		bool_isComp, 0			;
		je		start					;

		loop	start					; loop if composite value true

	ret
showComposites ENDP

; Is Composite Value -----------------------------
isComposite	PROC
	
	; Calculate if Composite
	calculate_new:
		mov		edx, 00000000h			; clear registers
		mov		ebx, 00000000h			; precalculation reqs
		mov		eax, 00000000h			;
		cdq

		mov		eax, comp_num			; divide
		mov		ebx, iter_div			;
		div		ebx						;
		mov		comp_rem, edx			;

		mov		bool_isComp, 0			; check remainder
		cmp		comp_rem, 0				;
		ja		next_check				;

		mov		bool_isComp, 1			;
		jmp		end_loop				;		

	;

	; next check ------------------------
	next_check:
		mov		eax, comp_num			; check that divisor is 
		inc		iter_div				; less than dividend 
		cmp		eax, iter_div			; 
		ja		continue				;
		jmp		end_loop				;

	; continue next iteration -----------
	continue:
		jmp		calculate_new			;

	; end the process -------------------
	end_loop:							

	ret
isComposite ENDP

; Farewell -------------------------------
farewell	PROC

	call	CrLf						;
	mov		edx, OFFSET		bye			;
	call	WriteString					;
	call	CrLf						;


	ret
farewell	ENDP

; (insert additional procedures here)

END main
