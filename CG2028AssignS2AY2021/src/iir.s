.syntax unified
 	.cpu cortex-m3
 	.thumb
 	.align 2
 	.global	iir
 	.thumb_func

@ CG2028 Assignment, Sem 2, AY 2020/21
@ (c) CG2028 Teaching Team, ECE NUS, 2021

@Register map
@R0 - N, returns y
@R1 - *b
@R2 - *a
@R3 - x_n
@R4 - <use(s)>
@R5 - <use(s)>
@....

iir:
@ PUSH / save (only those) registers which are modified by your function
@ parameter registers need not be saved.
PUSH {R4-R12}
@ write asm function body here
@loadstatic:
@	LDR R4, =XSTORE
@	LDR R5, =YSTORE
@	LDR R6, =XPTR
@	LDR R7, =YPTR

@ calculate y_n value
ynvalue:
	LDR R4, [R1]
	LDR R5, [R2]
	MUL R4, R3
	SDIV R4, R5

initloop:
	MOV R11, R0
	MOV R12, #0x00

@ to note: we can make code faster by diving the final value by a0
loopynvalue:
	@get value of X and Y at index 0
	LDR R6, =XSTORE
	LDR R6, [R6]
	LDR R7, =YSTORE
	LDR R7, [R7]
	@increment iterator
	ADD R12, #4
	@get a[j+1]
	LDR R8, =XSTORE
	ADD R8, R12 @increments the address value by 1 integer(4bytes)
	LDR R8, [R8]
	@get b[j+1]
	LDR R9, =YSTORE
	ADD R9, R12 @increments the address value by 1 integer(4bytes)
	LDR R9, [R9]
	@calculate a portion and b portion
	MUL R5, R6, R8
	MUL R6, R7, R9
	@calculate (b[j+1]*x_store[j]-a[j+1]*y_store[j])
	SUB R5, R6
	@ load value of a[0] into R6
	LDR R6, [R2]
	LDR R6, [R6]
	SDIV R5, R6
	@ iterator, initialized to N value in initloop
	SUBS R11, #1
	BNE loopynvalue

loopshift:


@divide the value by 100
divide:
	MOV R5, 0x64
	SDIV R0, R4, R5

@ prepare value to return (y_n) to C program in R0
@ POP / restore original register values. DO NOT save or restore R0. Why?
POP {R4-R12}
@ return to C program
		BX	LR

@label: .word value
.equ N_MAX, 10
@.lcomm label num_bytes
.lcomm XSTORE 4 * (N_MAX)
.lcomm YSTORE 4 * (N_MAX)
@.lcomm XPTR 4
@.lcomm YPTR 4
