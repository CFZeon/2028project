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
@initloop:
@	MOV R9, R0

loopynvalue:
	@get compare value
	@MOV R10, #4
	@MUL R11, R0, R10
	@get value of X and Y at index 0
	LDR R6, =XSTORE
	ADD R6, R12
	LDR R6, [R6]
	LDR R7, =YSTORE
	ADD R7, R12
	LDR R7, [R7]
	@increment iterator
	ADD R12, #4
	@get a[j+1]
	MOV R8, R1
	ADD R8, R12 @increments the address value by 1 integer(4bytes)
	LDR R8, [R8]
	@get b[j+1]
	MOV R9, R2
	ADD R9, R12 @increments the address value by 1 integer(4bytes)
	LDR R9, [R9]
	@calculate a portion and b portion
	MUL R5, R6, R8
	MUL R6, R7, R9
	@calculate (b[j+1]*x_store[j]-a[j+1]*y_store[j])
	SUB R5, R6
	@ load value of a[0] into R6
	LDR R6, [R2]
	SDIV R5, R6
	ADD R4, R5
	SUBS R11, #1
	BNE loopynvalue


initloopshift:
	@decrements iterator to N*4 times from (N-1)*4 times
	@SUB R12, #4
	@sets value of iterator to N again and decrement it by 1
	MOV R11, R0
	@SUB R11, #1
	@initialize registers
	LDR R5, =XSTORE
	ADD R5, R12
	LDR R6, =YSTORE
	ADD R6, R12

loopshift:
	@decrement iterator to 4 bytes lower
	SUB R12, #4
	@load address of XSTORE
	LDR R7, =XSTORE
	@increment by (loop-1)*4 bytes
	ADD R7, R12
	@get value at that address
	@assign value to XSTORE
	LDR R7, [R7]
	STR R7, [R5]
	SUB R5, #4
	@load address of YSTORE
	LDR R7, =YSTORE
	@increment by (loop-1)*4 bytes
	ADD R7, R12
	@get value at that address
	@LDR R7, [R7]
	@assign value to YSTORE
	LDR R7, [R7]
	STR R7, [R6]
	SUB R6, #4
	@decrement loop iterator by 1
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
.lcomm XPTR 4
.lcomm YPTR 4
