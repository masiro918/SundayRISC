.section .text
.global _start
_start:
    li sp, 8192
    call main

1:
    ebreak
    j 1b
  
	.file	"test7.c"


	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.globl	response
	.bss
	.align	2
	.type	response, @object
	.size	response, 8000
response:
	.zero	8000
	.text
	.align	2
	.globl	mem_write
	.type	mem_write, @function
mem_write:
	addi	sp,sp,-32
	sw	s0,28(sp)
	addi	s0,sp,32
	sw	a0,-20(s0)
	mv	a5,a1
	sb	a5,-21(s0)
	lw	a5,-20(s0)
	lbu	a4,-21(s0)
 #APP
# 13 "test7.c" 1
	sb a4, 0(a5)
# 0 "" 2
 #NO_APP
	nop
	lw	s0,28(sp)
	addi	sp,sp,32
	jr	ra
	.size	mem_write, .-mem_write
	.align	2
	.globl	mem_read
	.type	mem_read, @function
mem_read:
	addi	sp,sp,-48
	sw	s0,44(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	lw	a5,-36(s0)
 #APP
# 23 "test7.c" 1
	lb a5, 0(a5)
# 0 "" 2
 #NO_APP
	sb	a5,-17(s0)
	lbu	a5,-17(s0)
	mv	a0,a5
	lw	s0,44(sp)
	addi	sp,sp,48
	jr	ra
	.size	mem_read, .-mem_read
	.align	2
	.globl	putc
	.type	putc, @function
putc:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	mv	a5,a0
	sb	a5,-17(s0)
	lbu	a5,-17(s0)
	mv	a1,a5
	li	a0,2097152
	call	mem_write
	nop
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	putc, .-putc
	.align	2
	.globl	puts
	.type	puts, @function
puts:
	addi	sp,sp,-48
	sw	ra,44(sp)
	sw	s0,40(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	sw	zero,-20(s0)
	j	.L6
.L9:
	lw	a4,-20(s0)
	li	a5,8192
	addi	a5,a5,-194
	bgt	a4,a5,.L10
	lw	a5,-20(s0)
	lw	a4,-36(s0)
	add	a5,a4,a5
	lbu	a5,0(a5)
	mv	a0,a5
	call	putc
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
.L6:
	lw	a5,-20(s0)
	lw	a4,-36(s0)
	add	a5,a4,a5
	lbu	a5,0(a5)
	bne	a5,zero,.L9
	j	.L11
.L10:
	nop
.L11:
	nop
	lw	ra,44(sp)
	lw	s0,40(sp)
	addi	sp,sp,48
	jr	ra
	.size	puts, .-puts
	.align	2
	.globl	puts_raw
	.type	puts_raw, @function
puts_raw:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	sw	a0,-20(s0)
	j	.L13
.L14:
	lw	a5,-20(s0)
	addi	a4,a5,1
	sw	a4,-20(s0)
	lbu	a5,0(a5)
	mv	a0,a5
	call	putc
.L13:
	lw	a5,-20(s0)
	lbu	a5,0(a5)
	bne	a5,zero,.L14
	nop
	nop
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	puts_raw, .-puts_raw
	.local	heap
	.comm	heap,10240,4
	.local	heap_ptr
	.comm	heap_ptr,4,4
	.align	2
	.globl	malloc
	.type	malloc, @function
malloc:
	addi	sp,sp,-48
	sw	s0,44(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	lw	a5,-36(s0)
	addi	a5,a5,7
	andi	a5,a5,-8
	sw	a5,-20(s0)
	lui	a5,%hi(heap_ptr)
	lw	a4,%lo(heap_ptr)(a5)
	lw	a5,-20(s0)
	add	a4,a4,a5
	li	a5,12288
	addi	a5,a5,-2048
	bleu	a4,a5,.L16
	li	a5,3
	j	.L17
.L16:
	lui	a5,%hi(heap_ptr)
	lw	a4,%lo(heap_ptr)(a5)
	lui	a5,%hi(heap)
	addi	a5,a5,%lo(heap)
	add	a5,a4,a5
	sw	a5,-24(s0)
	lui	a5,%hi(heap_ptr)
	lw	a4,%lo(heap_ptr)(a5)
	lw	a5,-20(s0)
	add	a4,a4,a5
	lui	a5,%hi(heap_ptr)
	sw	a4,%lo(heap_ptr)(a5)
	lw	a5,-24(s0)
.L17:
	mv	a0,a5
	lw	s0,44(sp)
	addi	sp,sp,48
	jr	ra
	.size	malloc, .-malloc
	.align	2
	.globl	strcpy
	.type	strcpy, @function
strcpy:
	addi	sp,sp,-48
	sw	s0,44(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	sw	a1,-40(s0)
	lw	a5,-36(s0)
	sw	a5,-20(s0)
	nop
.L19:
	lw	a4,-40(s0)
	addi	a5,a4,1
	sw	a5,-40(s0)
	lw	a5,-36(s0)
	addi	a3,a5,1
	sw	a3,-36(s0)
	lbu	a4,0(a4)
	sb	a4,0(a5)
	lbu	a5,0(a5)
	bne	a5,zero,.L19
	lw	a5,-20(s0)
	mv	a0,a5
	lw	s0,44(sp)
	addi	sp,sp,48
	jr	ra
	.size	strcpy, .-strcpy
	.align	2
	.globl	strcmp
	.type	strcmp, @function
strcmp:
	addi	sp,sp,-32
	sw	s0,28(sp)
	addi	s0,sp,32
	sw	a0,-20(s0)
	sw	a1,-24(s0)
	j	.L22
.L24:
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
	lw	a5,-24(s0)
	addi	a5,a5,1
	sw	a5,-24(s0)
.L22:
	lw	a5,-20(s0)
	lbu	a5,0(a5)
	beq	a5,zero,.L23
	lw	a5,-20(s0)
	lbu	a4,0(a5)
	lw	a5,-24(s0)
	lbu	a5,0(a5)
	beq	a4,a5,.L24
.L23:
	lw	a5,-20(s0)
	lbu	a5,0(a5)
	mv	a4,a5
	lw	a5,-24(s0)
	lbu	a5,0(a5)
	sub	a5,a4,a5
	mv	a0,a5
	lw	s0,28(sp)
	addi	sp,sp,32
	jr	ra
	.size	strcmp, .-strcmp
	.align	2
	.globl	strcat
	.type	strcat, @function
strcat:
	addi	sp,sp,-48
	sw	s0,44(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	sw	a1,-40(s0)
	lw	a5,-36(s0)
	sw	a5,-20(s0)
	j	.L27
.L28:
	lw	a5,-36(s0)
	addi	a5,a5,1
	sw	a5,-36(s0)
.L27:
	lw	a5,-36(s0)
	lbu	a5,0(a5)
	bne	a5,zero,.L28
	nop
.L29:
	lw	a4,-40(s0)
	addi	a5,a4,1
	sw	a5,-40(s0)
	lw	a5,-36(s0)
	addi	a3,a5,1
	sw	a3,-36(s0)
	lbu	a4,0(a4)
	sb	a4,0(a5)
	lbu	a5,0(a5)
	bne	a5,zero,.L29
	lw	a5,-20(s0)
	mv	a0,a5
	lw	s0,44(sp)
	addi	sp,sp,48
	jr	ra
	.size	strcat, .-strcat
	.align	2
	.globl	memcpy
	.type	memcpy, @function
memcpy:
	addi	sp,sp,-48
	sw	s0,44(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	sw	a1,-40(s0)
	sw	a2,-44(s0)
	lw	a5,-36(s0)
	sw	a5,-20(s0)
	lw	a5,-40(s0)
	sw	a5,-24(s0)
	j	.L32
.L33:
	lw	a4,-24(s0)
	addi	a5,a4,1
	sw	a5,-24(s0)
	lw	a5,-20(s0)
	addi	a3,a5,1
	sw	a3,-20(s0)
	lbu	a4,0(a4)
	sb	a4,0(a5)
.L32:
	lw	a5,-44(s0)
	addi	a4,a5,-1
	sw	a4,-44(s0)
	bne	a5,zero,.L33
	lw	a5,-36(s0)
	mv	a0,a5
	lw	s0,44(sp)
	addi	sp,sp,48
	jr	ra
	.size	memcpy, .-memcpy
	.align	2
	.globl	atoi
	.type	atoi, @function
atoi:
	addi	sp,sp,-48
	sw	s0,44(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	sw	zero,-20(s0)
	li	a5,1
	sw	a5,-24(s0)
	j	.L36
.L37:
	lw	a5,-36(s0)
	addi	a5,a5,1
	sw	a5,-36(s0)
.L36:
	lw	a5,-36(s0)
	lbu	a4,0(a5)
	li	a5,32
	beq	a4,a5,.L37
	lw	a5,-36(s0)
	lbu	a4,0(a5)
	li	a5,9
	beq	a4,a5,.L37
	lw	a5,-36(s0)
	lbu	a4,0(a5)
	li	a5,10
	beq	a4,a5,.L37
	lw	a5,-36(s0)
	lbu	a4,0(a5)
	li	a5,45
	bne	a4,a5,.L38
	li	a5,-1
	sw	a5,-24(s0)
	lw	a5,-36(s0)
	addi	a5,a5,1
	sw	a5,-36(s0)
	j	.L40
.L38:
	lw	a5,-36(s0)
	lbu	a4,0(a5)
	li	a5,43
	bne	a4,a5,.L40
	lw	a5,-36(s0)
	addi	a5,a5,1
	sw	a5,-36(s0)
	j	.L40
.L42:
	lw	a4,-20(s0)
	mv	a5,a4
	slli	a5,a5,2
	add	a5,a5,a4
	slli	a5,a5,1
	mv	a4,a5
	lw	a5,-36(s0)
	lbu	a5,0(a5)
	addi	a5,a5,-48
	add	a5,a4,a5
	sw	a5,-20(s0)
	lw	a5,-36(s0)
	addi	a5,a5,1
	sw	a5,-36(s0)
.L40:
	lw	a5,-36(s0)
	lbu	a4,0(a5)
	li	a5,47
	bleu	a4,a5,.L41
	lw	a5,-36(s0)
	lbu	a4,0(a5)
	li	a5,57
	bleu	a4,a5,.L42
.L41:
	lw	a4,-24(s0)
	lw	a5,-20(s0)
	mul	a5,a4,a5
	mv	a0,a5
	lw	s0,44(sp)
	addi	sp,sp,48
	jr	ra
	.size	atoi, .-atoi
	.align	2
	.globl	int_to_str
	.type	int_to_str, @function
int_to_str:
	addi	sp,sp,-48
	sw	s0,44(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	li	a5,11
	sw	a5,-20(s0)
	sw	zero,-28(s0)
	lui	a5,%hi(buf.0)
	addi	a4,a5,%lo(buf.0)
	lw	a5,-20(s0)
	add	a5,a4,a5
	sb	zero,0(a5)
	lw	a5,-36(s0)
	bne	a5,zero,.L45
	lw	a5,-20(s0)
	addi	a5,a5,-1
	sw	a5,-20(s0)
	lui	a5,%hi(buf.0)
	addi	a4,a5,%lo(buf.0)
	lw	a5,-20(s0)
	add	a5,a4,a5
	li	a4,48
	sb	a4,0(a5)
	lw	a4,-20(s0)
	lui	a5,%hi(buf.0)
	addi	a5,a5,%lo(buf.0)
	add	a5,a4,a5
	j	.L46
.L45:
	lw	a5,-36(s0)
	bge	a5,zero,.L47
	li	a5,1
	sw	a5,-28(s0)
	lw	a5,-36(s0)
	neg	a5,a5
	sw	a5,-24(s0)
	j	.L49
.L47:
	lw	a5,-36(s0)
	sw	a5,-24(s0)
	j	.L49
.L51:
	lw	a4,-24(s0)
	li	a5,10
	remu	a5,a4,a5
	andi	a5,a5,0xff
	lw	a4,-20(s0)
	addi	a4,a4,-1
	sw	a4,-20(s0)
	addi	a5,a5,48
	andi	a4,a5,0xff
	lui	a5,%hi(buf.0)
	addi	a3,a5,%lo(buf.0)
	lw	a5,-20(s0)
	add	a5,a3,a5
	sb	a4,0(a5)
	lw	a4,-24(s0)
	li	a5,10
	divu	a5,a4,a5
	sw	a5,-24(s0)
.L49:
	lw	a5,-24(s0)
	beq	a5,zero,.L50
	lw	a5,-20(s0)
	bgt	a5,zero,.L51
.L50:
	lw	a5,-28(s0)
	beq	a5,zero,.L52
	lw	a5,-20(s0)
	ble	a5,zero,.L52
	lw	a5,-20(s0)
	addi	a5,a5,-1
	sw	a5,-20(s0)
	lui	a5,%hi(buf.0)
	addi	a4,a5,%lo(buf.0)
	lw	a5,-20(s0)
	add	a5,a4,a5
	li	a4,45
	sb	a4,0(a5)
.L52:
	lw	a4,-20(s0)
	lui	a5,%hi(buf.0)
	addi	a5,a5,%lo(buf.0)
	add	a5,a4,a5
.L46:
	mv	a0,a5
	lw	s0,44(sp)
	addi	sp,sp,48
	jr	ra
	.size	int_to_str, .-int_to_str
	.align	2
	.globl	memset
	.type	memset, @function
memset:
	addi	sp,sp,-48
	sw	s0,44(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	sw	a1,-40(s0)
	sw	a2,-44(s0)
	lw	a5,-36(s0)
	sw	a5,-20(s0)
	lw	a5,-40(s0)
	sb	a5,-21(s0)
	j	.L54
.L55:
	lw	a5,-20(s0)
	addi	a4,a5,1
	sw	a4,-20(s0)
	lbu	a4,-21(s0)
	sb	a4,0(a5)
.L54:
	lw	a5,-44(s0)
	addi	a4,a5,-1
	sw	a4,-44(s0)
	bne	a5,zero,.L55
	lw	a5,-36(s0)
	mv	a0,a5
	lw	s0,44(sp)
	addi	sp,sp,48
	jr	ra
	.size	memset, .-memset
	.section	.rodata
	.align	2
.LC0:
	.string	"\377\377\377\377\377\377"
	.string	""
	.string	""
	.string	""
	.string	""
	.string	""
	.string	"\b"
	.string	"E"
	.string	""
	.string	"Y"
	.string	"\001"
	.string	""
	.string	"@\006|\234\177"
	.string	""
	.string	"\001\177"
	.string	""
	.string	"\001"
	.string	"\024\037@"
	.string	""
	.string	""
	.string	""
	.string	""
	.string	""
	.string	""
	.string	""
	.string	"P\002 "
	.string	"\242Q"
	.string	""
	.ascii	"GET /get?foo=bar HTTP/1.1\nHost: postman-echo.com\n\r\n\r\n"
	.text
	.align	2
	.globl	network_http_get_readme
	.type	network_http_get_readme, @function
network_http_get_readme:
	addi	sp,sp,-160
	sw	ra,156(sp)
	sw	s0,152(sp)
	addi	s0,sp,160
	sw	a0,-148(s0)
	lui	a5,%hi(.LC0)
	addi	a4,a5,%lo(.LC0)
	addi	a5,s0,-132
	mv	a3,a4
	li	a4,107
	mv	a2,a4
	mv	a1,a3
	mv	a0,a5
	call	memcpy
	sw	zero,-20(s0)
	j	.L58
.L59:
	lw	a5,-20(s0)
	addi	a4,s0,-16
	add	a5,a4,a5
	lbu	a5,-116(a5)
	mv	a1,a5
	li	a5,2097152
	addi	a0,a5,4
	call	mem_write
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
.L58:
	lw	a4,-20(s0)
	li	a5,106
	bleu	a4,a5,.L59
	sw	zero,-24(s0)
	j	.L60
.L64:
	li	a5,2097152
	addi	a0,a5,8
	call	mem_read
	mv	a5,a0
	sb	a5,-25(s0)
	lbu	a4,-25(s0)
	li	a5,31
	bleu	a4,a5,.L61
	lbu	a4,-25(s0)
	li	a5,126
	bleu	a4,a5,.L62
.L61:
	lbu	a4,-25(s0)
	li	a5,10
	beq	a4,a5,.L62
	lbu	a4,-25(s0)
	li	a5,13
	beq	a4,a5,.L62
	lbu	a4,-25(s0)
	li	a5,9
	bne	a4,a5,.L63
.L62:
	lui	a5,%hi(response)
	addi	a4,a5,%lo(response)
	lw	a5,-24(s0)
	add	a5,a4,a5
	lbu	a4,-25(s0)
	sb	a4,0(a5)
.L63:
	lw	a5,-24(s0)
	addi	a5,a5,1
	sw	a5,-24(s0)
.L60:
	lw	a5,-148(s0)
	addi	a5,a5,-1
	lw	a4,-24(s0)
	blt	a4,a5,.L64
	lui	a5,%hi(response)
	addi	a4,a5,%lo(response)
	lw	a5,-24(s0)
	add	a5,a4,a5
	sb	zero,0(a5)
	lw	a5,-24(s0)
	mv	a0,a5
	lw	ra,156(sp)
	lw	s0,152(sp)
	addi	sp,sp,160
	jr	ra
	.size	network_http_get_readme, .-network_http_get_readme
	.section	.rodata
	.align	2
.LC1:
	.string	"OK\n"
	.align	2
.LC2:
	.string	"[proc2] network error\n"
	.text
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	li	a5,8192
	addi	a0,a5,-192
	call	network_http_get_readme
	sw	a0,-24(s0)
	lui	a5,%hi(.LC1)
	addi	a0,a5,%lo(.LC1)
	call	puts_raw
	lw	a5,-24(s0)
	bge	a5,zero,.L67
	lui	a5,%hi(.LC2)
	addi	a0,a5,%lo(.LC2)
	call	puts_raw
	j	.L71
.L67:
	sw	zero,-20(s0)
	j	.L69
.L70:
	lui	a5,%hi(response)
	addi	a4,a5,%lo(response)
	lw	a5,-20(s0)
	add	a5,a4,a5
	lbu	a5,0(a5)
	mv	a0,a5
	call	putc
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
.L69:
	lw	a4,-20(s0)
	li	a5,8192
	addi	a5,a5,-194
	ble	a4,a5,.L70
.L71:
	nop
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	main, .-main
	.local	buf.0
	.comm	buf.0,12,4
	.ident	"GCC: () 10.2.0"
