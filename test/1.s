	.file	"1.c"
	.text
	.align	2
	.globl	main
	.type	main, @function
main:
.LFB0 = .
	.cfi_startproc
	addi.d	$r3,$r3,-16
	.cfi_def_cfa_offset 16
	st.d	$r1,$r3,8
	st.d	$r22,$r3,0
	.cfi_offset 1, -8
	.cfi_offset 22, -16
	addi.d	$r22,$r3,16
	.cfi_def_cfa 22, 0
	bl	%plt(test_tr8x16b)
	nop
	ld.d	$r1,$r3,8
	.cfi_restore 1
	ld.d	$r22,$r3,0
	.cfi_restore 22
	addi.d	$r3,$r3,16
	.cfi_def_cfa_register 3
	jr	$r1
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.ident	"GCC: (Loongnix 8.3.0-6.lnd.vec.37) 8.3.0"
	.section	.note.GNU-stack,"",@progbits
