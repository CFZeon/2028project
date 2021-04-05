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
	LDR R4, [R1]        @0x05914000
	MUL R4, R4, R3      @0x00004314
initloop:
	MOV R12, R0         @0x01A0C000
	LDR R6, =XSTORE     @ idk lol
	LDR R7, =YSTORE     @ idk lol
	MOV R8, R1          @0x01A08001
	ADD R8, #0x4        @0x02888004
	MOV R9, R2          @0x01A09002
	ADD R9, #0x4        @0x02899004
loopynvalue:
	@b(j+1)*x_store[j]
	LDR R5, [R6], #0x4  @0x05965004
	@get b[j+1]
	LDR R10, [R8], #0x4 @0x0598A004
	@times b and x_store
	MUL R5, R5, R10     @0x00005A15
	@add y_n with b*x_store
	ADD R4, R5          @0x00854000
	@a[j+1]*y_store[j]
	LDR R5, [R7], #0x4  @0x05975004
	LDR R10, [R9], #0x4 @0x0599A004
	MUL R5, R5, R10     @0x00005A15
	@calculate (b[j+1]*x_store[j]-a[j+1]*y_store[j])
	SUB R4, R5          @0x00454000
	SUBS R12, #1        @0x025CC001
	BNE loopynvalue     @0x18000028
divideynbya:
	LDR R6, [R2]        @0x05926000
	SDIV R4, R6         @unrequired
initloopshift:
	MOV R12, R0         @0x01A0C000
	@initialize registers
	LDR R5, =XSTORE     @ idk lol
	LDR R6, =YSTORE     @ idk lol
	@get value of current index (x[j])and then add index by 1
	LDR R7, [R5], #0x4  @0x05957004
	@get value of current index (y[j])and then add index by 1
	LDR R8, [R6], #0x4  @0x05968004
loopshift:
	@get val at next j+1 of x
	LDR R9, [R5]        @0x05959000
	@store prev val to current and change address to j+1
	STR R7, [R5], #0x4  @0x05857004
	@change x[j] value stored to x[j+1]
	MOV R7, R9          @0x01A07009
	@get value of current index (j) and then add index by 1
	LDR R10, [R6]       @0x0596A000
	@get val at next j+1
	STR R8, [R6], #0x4  @0x05868004
	@change y[j] value stored to y[j+1]
	MOV R8, R10         @0x01A0800A
	SUBS R12, #1        @0x025CC001
	BNE loopshift       @0x18000020
store:
	LDR R7, =XSTORE     @ idk lol
	STR R3, [R7]        @0x05073000
	LDR R7, =YSTORE     @ idk lol
	STR R4, [R7]        @0x05074000
div:
	MOV R5, 0x64        @0x03A05064
	SDIV R0, R4, R5     @unrequired

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
