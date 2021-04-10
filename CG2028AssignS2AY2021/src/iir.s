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
	MUL R4, R3
initloop:
	MOV R12, R0
	LDR R6, =XSTORE
	LDR R7, =YSTORE
	MOV R8, R1
	ADD R8, #0x4
	MOV R9, R2
	ADD R9, #0x4
loopynvalue:
	@b(j+1)*x_store[j]
	LDR R5, [R6], #0x4
	@get b[j+1]
	LDR R10, [R8], #0x4
	@times b and x_store
	MUL R5, R10
	@add y_n with b*x_store
	ADD R4, R5
	@a[j+1]*y_store[j]
	LDR R5, [R7], #0x4
	LDR R10, [R9], #0x4
	MUL R5, R10
	@calculate (b[j+1]*x_store[j]-a[j+1]*y_store[j])
	SUB R4, R5
	SUBS R12, #1
	BNE loopynvalue
divideynbya:
	LDR R6, [R2]
	SDIV R4, R6
initloopshift:
	MOV R12, R0
	MOV R7, #0x4
	@initialize registers
	LDR R5, =XSTORE
	LDR R6, =YSTORE
	@increment address at xstore to the index at the end
	MLA R5, R0, R7, R5
	@increment address at ystore to the index at the end
	MLA R6, R0, R7, R6
loopshift:
	@decrement index of xstore by 1 (j-1)
	SUB R5, #0x4
	@load value at xstore[j-1] into R7
	LDR R7, [R5]
	@store value at j-1 to j
	STR R7, [R5,#0x4]
	@decrement index of ystore by 1 (j-1)
	SUB R6, #0x4
	@load value at ystore[j-1] into R7
	LDR R7, [R6]
	@store value at j-1 to j
	STR R7, [R6,#0x4]
	@decrement iterator by 1
	SUBS R12, #1
	BNE loopshift
store:
	LDR R7, =XSTORE
	STR R3, [R7]
	LDR R7, =YSTORE
	STR R4, [R7]
div:
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
