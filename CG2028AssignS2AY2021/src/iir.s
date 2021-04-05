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
initloop:
	MOV R11, R0
	MOV R12, #0x00
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
	SUBS R11, #1
	BNE loopynvalue
divideynbya:
	LDR R6, [R2]
	SDIV R4, R6
initloopshift:
	MOV R11, R0
	@initialize registers
	LDR R5, =XSTORE
	LDR R6, =YSTORE
	@get value of current index (x[j])and then add index by 1
	LDR R7, [R5], #0x4
	@get value of current index (y[j])and then add index by 1
	LDR R8, [R6], #0x4
loopshift:
	@get val at next j+1 of x
	LDR R9, [R5]
	@store prev val to current and change address to j+1
	STR R7, [R5], #0x4
	@change x[j] value stored to x[j+1]
	MOV R7, R9
	@get value of current index (j) and then add index by 1
	LDR R10, [R6]
	@get val at next j+1
	STR R8, [R6], #0x4
	@change y[j] value stored to y[j+1]
	MOV R8, R10
	SUBS R11, #1
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
