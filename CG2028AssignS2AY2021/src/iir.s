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
@R1 - b
@R2 - a
@R3 - x_n
@R4 - <use(s)>
@R5 - <use(s)>
@....

iir:
@ PUSH / save (only those) registers which are modified by your function
@ parameter registers need not be saved.

@ write asm function body here

@ prepare value to return (y_n) to C program in R0

@ POP / restore original register values. DO NOT save or restore R0. Why?

@ return to C program
		BX	LR

@label: .word value
.equ N_MAX, 10
@.lcomm label num_bytes
