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
	shl rcx, 1
	shl rax, 2
	mov r11, rax
	add r11, r12
	mov r15d, 0
	mov r10, r12
	;shr r12d, 1

	.ciclo:
		movups xmm1, [rdi]				; xmm1 = |  p3  |  p2  |  p1  |  p0  |
		; 216 = 11 01 10 00 
		pshufd xmm1, xmm1, 216			; xmm1 = |  p3  |  p1  |  p2  |  p0  | 

		movq [rsi], xmm1
		movq [rsi + 8*rax], xmm1
		movq [rsi + 8*r10], xmm1
		movq [rsi + 8*r11], xmm1
		
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
			add rdi, 16
			add rsi, 8
	.cont:	
		loop .ciclo
	
		
	;pop r15	
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret