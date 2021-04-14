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
@ PUSH / save (only those) registers
@ which are modified by your function
@ parameter registers need not be saved.
PUSH {R4-R12}
@ write asm function body here
@ calculate y_n value
ynvalue:
	LDR R4, [R1]        @0x05914000
	MUL R4, R4, R3      @0x00004314
initloop:
	MOV R12, R0         @0x01A0C000
	LDR R6, =XSTORE		@0x059F609C
	LDR R7, =YSTORE		@0x059F709C
	MOV R8, R1          @0x01A08001
	ADD R8, #0x4        @0x02888004
	MOV R9, R2          @0x01A09002
	ADD R9, #0x4        @0x02899004
loopynvalue:
	LDR R5, [R6], #0x4  @0x05965004
	LDR R10, [R8], #0x4 @0x0598A004
	MUL R5, R5, R10     @0x00005A15
	ADD R4, R5          @0x00854000
	LDR R5, [R7], #0x4  @0x05975004
	LDR R10, [R9], #0x4 @0x0599A004
	MUL R5, R5, R10     @0x00005A15
	SUB R4, R5          @0x00454000
	SUBS R12, #1        @0x025CC001
	BNE loopynvalue     @0x18000028
divideynbya:
	LDR R6, [R2]        @0x05926000
	SDIV R4, R6         @unrequired
initloopshift:
	MOV R12, R0         @0x01A0C000
	MOV R7, #0x4 		@0x03A07004
	LDR R5, =XSTORE		@0x059F504C
	LDR R6, =YSTORE		@0x059F604C
	MLA R5, R0, R7, R5	@0x00255710
	MLA R6, R0, R7, R6	@0x00266710
loopshift:
	SUB R5, #0x4		@0x02455004
	LDR R7, [R5]		@0x05957000
	STR R7, [R5,#0x4]	@0x05857004
	SUB R6, #0x4		@0x02466004
	LDR R7, [R6]		@0x05967000
	STR R7, [R6,#0x4]	@0x05867004
	SUBS R12, #1		@0x025CC001
	BNE loopshift		@0x18000020
store:
	LDR R7, =XSTORE		@0x059F701C
	STR R3, [R7]        @0x05073000
	LDR R7, =YSTORE		@0x059F7018
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
