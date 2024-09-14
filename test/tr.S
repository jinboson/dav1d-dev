#include "../src/loongarch/loongson_asm.S"
#include "../src/loongarch/loongson_util.S"

	.section .rodata
	.align 4
srcdata:
.byte 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
.byte 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
.byte 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
.byte 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
.byte 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
.byte 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
.byte 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
.byte 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	.size srcdata, . - srcdata

	.text
	.globl test_tr8x16b
test_tr8x16b:

la.local t0, srcdata

vld      vr0, t0, 0
vld      vr1, t0, 16
vld      vr2, t0, 32
vld      vr3, t0, 48
vld      vr4, t0, 64
vld      vr5, t0, 80
vld      vr6, t0, 96
vld      vr7, t0, 112

TRANSPOSE_8x16B vr0, vr1, vr2, vr3, vr4, vr5, vr6, vr7, vr8, vr9

nop

nop

jr ra
	.size test_tr8x16b, . - test_tr8x16b
