
section .data
DEFAULT REL

section .text
global smalltiles_asm
smalltiles_asm:

;COMPLETAR
	;RDI = src , RSI = dst , EDX = cols , ECX = filas
	;R8D = src_row_size, R9D = dst_row_size
	
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14

	xor rax, rax
	mov rbx, rsi
	mov r14, rdi
	
	shr rdx, 1
	shr rcx, 1
	
	mov r12d, edx 						; r12 = cols
	mov r13d, ecx						; r13 = filas
	
	shr r12, 1
	shr r13, 1
	
	mov eax, r13d
	mul r12d
	mov rcx, rax
	shl rax, 2
	mov r11, rax
	add r11, r12
	mov r15d, 0
	mov r10, r12
	shr r12d, 1

	.ciclo:
		movups xmm1, [rdi]								;xmm1 = |  p3  |  p2  |  p1  |  p0  |
		movups xmm2, [rdi + 16]							;xmm2 = |  p7  |  p6  |  p5  |  p4  |
		shufps xmm1, xmm2, 0xdd							;xmm1 = |  p6  |  p4  |  p2  |  p0  | 

		movups [rsi], xmm1
		movups [rsi + 8*rax], xmm1
		movups [rsi + 8*r10], xmm1
		movups [rsi + 8*r11], xmm1
		
		inc r15d
		cmp r15d, r12d
		jne .seguir
		lea rsi, [rbx + r9]
		mov rbx, rsi
		lea rdi, [r14 + 2*r8]
		mov r14, rdi
		mov r15d, 0
		jmp .cont
		.seguir:
		add rdi, 32
		add rsi, 16
	.cont:	
		loop .ciclo
	
		
	;pop r15	
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret
