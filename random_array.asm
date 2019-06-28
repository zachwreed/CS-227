TITLE Program Template     (random_array.asm)

; Author: Zach Reed			reedz@oregonstate.edu
; Cs271-400 / Program 5      Date: 5/27/2018
; Description: generates a random element array of a size based on user input. Then the array is sorted with a bubble sort as well as median value. 

INCLUDE Irvine32.inc

; constants for range
MIN_SIZE EQU 10
MAX_SIZE EQU 200
LO	EQU 100
HI EQU 999

.data

	arr			DWORD	201			DUP(?)	; array of 200 unitialized elements
	count		DWORD	0					; count for array, will be used in user input

	line_sep	BYTE	"------------------------------------------------------------", 0
	thr_spc		BYTE	"   ", 0
	title_p		BYTE	"Title: Random Array Generator", 0
	author		BYTE	"Author: Zach Reed", 0
	descript_1	BYTE	"You will enter a number that will determine the number of ", 0
	descript_2	BYTE	"elements to be randomly generated, then sorted in the array.", 0
	prompt		BYTE	"Enter a value in the range of [10, 200]: ", 0
	error		BYTE	"Invalid Input. Integer must be in range.", 0
	sorted		BYTE	"Sorted List:", 0
	unsorted	BYTE	"Unsorted List:", 0
	median		BYTE	"Median: ", 0

; (insert variable definitions here)

.code
; Main Procedure ----------------------------------
main		PROC
	
	call	randomize			; seed random
	call	intro				;	
	push	OFFSET count		; send count by reference
	PUSH	MIN_SIZE			;
	push	MAX_SIZE			;
	call	get_data			;

	push	OFFSET arr			; fill_array with random values
	push	count				;
	PUSH	LO					;
	PUSH	HI					;
	call	fill_array			;

	push	OFFSET arr			; call display before sorting
	push	OFFSET thr_spc		;
	push	count				;
	call	disp_list			; 

	push	OFFSET arr			;
	push	count				;
	call	sort_list			;

	push	OFFSET arr			;
	push	count				;
	call	disp_med			;

	mov		edx, OFFSET sorted  ; display sort string
	call	WriteString			;
	call	CrLf				;


	push	OFFSET arr			; call display after sorting	
	push	OFFSET thr_spc		;
	push	count				;
	call	disp_list			; 


	exit	; exit to operating system
main		ENDP

; Introduction ------------------------------------
;
; Registers Modified: edx
; -------------------------------------------------
intro		PROC

	mov		edx, OFFSET line_sep	;
	call	WriteString				;
	call	CrLf					;
	mov		edx, OFFSET title_p		;
	call	WriteString				;
	call	CrLf					;
	mov		edx, OFFSET author		;
	call	WriteString				;
	call	CrLf					;
	mov		edx, OFFSET descript_1	;
	call	WriteString				;
	call	CrLf					;
	mov		edx, OFFSET descript_2	;
	call	WriteString				;
	call	CrLf					;
	mov		edx, OFFSET line_sep	;
	call	WriteString				;
	call	CrLf					;
	call	CrLf					;

ret			
intro		ENDP

; Get Data ----------------------------------------
;	old ebp		ebp
;	ret			ebp + 4
;	max_size	ebp + 8
;	min_size	ebp + 12
;	count		epb + 16
; Registers Modified: eax, edx, 
; -------------------------------------------------

get_data	PROC

	push	EBP				; creat stack frame
	mov		EBP, ESP		;

	; Input Label -------------------
	input:
		mov		eax, 00000000h		; clear eax
		mov		edx, OFFSET prompt	;
		call	WriteString			;
		call	ReadInt				;

	; Check Input to MIN_SIZE -------
	check_min:		
		mov		esi, [ebp + 12]		; mov MIN_SIZE to esi
		cmp		eax, esi			; compare to min
		jge		check_max			;
		
		mov		edx, OFFSET error	; if out of range
		call	WriteString			;
		call	CrLf				;
		jmp		input				;

	; Validate Low Input ------------
	check_max:
		mov		esi, [ebp + 8]		; mo MAX_SIZE to esi
		cmp		eax, esi			; compare to max
		jle		continue			;

		mov		edx, OFFSET error	; if out of range
		call	WriteString			;
		call	CrLf				;
		jmp		input				;

	; Continue out of program
	continue:
		mov		esi, [ebp + 16]		; mov count to esi
		mov		[esi], eax			; mov input to count
		mov		esp, ebp
		pop		ebp

ret			16
get_data	ENDP

; Fill Array --------------------------------------
;	old ebp		ebp
;	ret		ebp + 4
;	hi		ebp + 8
;	lo		ebp + 12
;	count	ebp + 16
;	@ arr	ebp + 20
; Registers Modified: eax, ecx, edx, edi
; ------------------------------------------------

fill_array	PROC

	push	ebp					; create stack frame
	mov		ebp, esp			;
	mov		esi, [ebp + 16]		;
	mov		ecx, esi			; mov count to ecx for loop
	mov		edi, [ebp + 20]		; mov arr offset in edi

	; Generate Random Element ------
	gen_rand_elem:
		mov		eax, 00000000h		;
		mov		esi, [ebp + 8]		; esi = hi
		mov		eax, esi			;
		mov		esi, [ebp + 12]		; esi = lo
		sub		eax, esi			; eax = hi - lo
		inc		eax					; eax = (hi - lo) + 1

		call	randomrange			; use eax for range
		add		eax, esi			; rand val + lo
		mov		[edi], eax			; arr[] = rand val
		add		edi, 4				; move to next pos
		loop	gen_rand_elem		;
		
		mov		esp, ebp			;
		pop		ebp					;

		mov		edx, OFFSET unsorted; display unsort string
		call	WriteString			;
		call	CrLf				;

ret			16
fill_array	ENDP

; Sort List ---------------------------------------
; Modified from bubble sort example in Assembly Language for x86 Processors, pg. 375
;	o_ebp	ebp		
;	ret		ebp + 4
;	count	ebp + 8		
;	@ arr	ebp + 12
;	Registers Modified: eax, ebx, ecx
; -------------------------------------------------

sort_list	PROC

	push	ebp						;
	mov		ebp, esp				; create stack frame
	mov		edx, [ebp + 12]			; arr id edx
	mov		ecx, [ebp + 8]			; count in ecx

	outer_loop:
		push ecx					;
		mov esi, [ebp + 12]			;
		mov eax, esi				; mov starting arr @ to eax

	inner_loop:
		mov		eax, [esi]			; arr[x] 
		mov		ebx, [esi + 4]		; arr[x + 1]
		cmp		ebx, eax			; compare arr[ebx] to arr[eax]
		jl		loop_inc			; if arr[x + 1] < arr[x]

	; Exchange values ---------------
	exchange:
		xchg	eax, [esi + 4]		; exchange arr[x] and arr[x + 1]
		mov		[esi], eax			; 

	; Increment Loops ---------------
	loop_inc:
		add		esi, 4				; inc arr @
		loop	inner_loop			; loop arr count

		pop		ecx					; restore ecx from outer loop
		loop	outer_loop			; loop outer arr size

		pop		ebp					; once finished

ret			8
sort_list	ENDP

; Display Median ----------------------------------
;	old ebp		ebp
;	ret		ebp + 4
;	count		ebp + 8
;	@ arr		ebp + 12
; Registers Modified: eax, ebx, ecx, edx

disp_med	PROC
	
	push	ebp				;
	mov		ebp, esp		; create stack frame

	; Odd or even size ----------
	calc_middle:
		cdq						;
		mov		esi, [ebp + 8]	;
		mov		eax, esi		; eax = count
		mov		ebx, 2			;
		div		ebx				;
		mov		ecx, eax		; quot in ecx for mid_loop
		dec		ecx				; adjust for index
		mov		esi, [ebp + 12]	; esi = arr @

	; Find middle ---------------
	mid_loop:
		add		esi, 4			; next element
		loop	mid_loop		;

		cmp		edx, 0			; even or odd from above
		je		even_			;
		jmp		odd				;

	; If arr count is Even ------
	even_:
		mov		eax, [esi]		; first mid val
		add		esi, 4			;
		add		eax, [esi]		; add second mid val						
		mov		ebx, 2			;
		cdq						;
		div		ebx				;
		cmp		edx, 0			;
		jne		rem_above		; if rem >= 5, round up
		jmp		continue		; else continue

	rem_above:
		inc		eax				; round up
		jmp		continue		;

	; If arr count is Odd -------
	odd:
		add		esi, 4			;
		mov		eax, [esi]		; mid arr to be written

	; Write Value to screen ---------
	continue:
		mov		edx, OFFSET median  ;
		call	WriteString			;
		call	WriteDec			;
		call	CrLf				;
		call	CrLf				;

		pop		ebp					;

ret			8
disp_med	ENDP

; Display Array -----------------------------------
;	wr_size		ebp - 4
;	old ebp		ebp
;	ret			ebp + 4
;	count		ebp + 8
;	thr_spc		ebp + 12
;	@ arr		ebp + 16	
; Registers Modified: eax, ebx, ecx, edx
; -------------------------------------------------

disp_list	PROC
	push	ebp						;
	mov		ebp, esp				;
	sub		esp, 4					; create space for local
	mov		esi, [ebp + 8]			; 
	mov		ecx, esi				; put count in ecx
	mov		esi, [ebp + 12]			; 
	mov		edx, esi				; put @ thr_spc in edx
	mov		esi, [ebp + 16]			; put arr @ in edi
	mov		DWORD PTR [ebp - 4], 0	; used for output size

	; Output Iteration ------------------
	iter:
		mov		eax, [esi]				; eax = arr[edi]
		call	WriteDec				; write arr[edi] in eax
		call	WriteString				; write spc_thr in edx
		add		esi, 4					; next element arr[edi]
		inc		DWORD PTR [ebp - 4]		; + 1 elements written
		mov		eax, DWORD PTR [ebp-4]  ; 
		cmp		eax, 10					; compare elements written
		jl		continue				;

	; If 10 Elements Written ------------
	new_line:
		call	CrLf					; new line
		mov		DWORD PTR [ebp - 4], 0	;

	; Continue Next Loop Iteration ------
	continue:
		loop	iter			; loop arr count in ecx
		mov		esp, ebp		; remove locals
		pop		ebp				;
		call	CrLf

ret			12
disp_list	ENDP

END main
