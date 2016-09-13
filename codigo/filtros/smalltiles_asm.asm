
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
	push r15
	
	mov r12, rsi								;guardo la dir del dst en R12
	shr edx, 1									; RDX = RDX/2
	shr ecx, 1									; RCX = RCX/2
	xor rax, rax
	xor rbx, rbx
	xor r13, r13
	xor r14, r14
	
	mov r13d, edx              					;r13d = cols/2 
	mov r14d, ecx								;r14d = filas/2
	mov eax, r13d
	mov ebx, r14d
	mov r15d, 0
	mul r14
	mov ecx, eax 
	.ciclo:
		movdqu xmm1, [rdi]
		;movdqu xmm2, [rdi + 16]
		;pshuf
		movdqu [rsi], xmm1
		movdqu [rsi + 8*rax], xmm1
		add rdi, 16
		add rsi, 8
		inc r15d
		cmp r15d,r13d
		jl .cont
		add r12, r9
		mov rsi, r12
		mov r15d, 0
	.cont:	
		loop .ciclo
	
		
	pop r15	
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret
