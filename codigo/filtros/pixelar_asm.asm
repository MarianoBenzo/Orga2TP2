; void pixelar_asm (
; 	unsigned char *src,
; 	unsigned char *dst,
; 	int cols,
; 	int filas,
; 	int src_row_size,
; 	int dst_row_size
; );

; Parámetros:
; 	rdi = src
; 	rsi = dst
; 	rdx = cols
; 	rcx = filas
; 	r8 = src_row_size
; 	r9 = dst_row_size

%define filaSize 

extern pixelar_c

section .rodata
val4: dd 4.0, 4.0, 4.0, 4.0

global pixelar_asm

section .text

pixelar_asm:
	;; TODO: Implementar

	push rbp
	mov rbp, rsp
	movdqu xmm6, [val4]		; xmm6 = | 4.0 | 4.0 | 4.0 | 4.0 |
	xor r8, r8
	mov r8d, edx
	shl r8, 2				; tamaño de una fila
	shr edx, 2				; itero de a 4 pixels (dentro de las columnas)
	shr ecx, 1				; solo recorro la mitad de las filas
	xor rax, rax			; copio el valor de las columnas porque itero sobre ese valor
	mov eax, edx

	.ciclo:
		cmp ecx, 0 			; si no hay mas filas por recorrer, termine
		je .fin
		dec edx	
		movdqu xmm0, [rdi]			; xmm0: | p4a | p3a | p4b | p3b |
		movdqu xmm1, [rdi + r8] 	; xmm1: | p2a | p1a | p2b | p1b |
		movdqu xmm2, xmm0			; xmm2: | p4a | p3a | p4b | p3b |
		movdqu xmm3, xmm1			; xmm3: | p2a | p1a | p2b | p1b |
		
		pxor xmm7, xmm7				; xmm7 = | 0 | 0 | 0 | 0 |
		punpckhbw xmm0, xmm7		; xmm0 = | p4a | p3a |
		punpckhbw xmm1, xmm7		; xmm1 = | p2a | p1a |
		punpcklbw xmm2, xmm7		; xmm2 = | p4b | p3b | 
		punpcklbw xmm3, xmm7		; xmm3 = | p2b | p1b | 

		paddusw xmm0, xmm1			; xmm0 = | p4a + p2a | p3a + p1a |
		movdqu xmm1, xmm0			; xmm1 = | p4a + p2a | p3a + p1a |
		psrldq xmm1, 8				; xmm1 = |     0     | p4a + p2a |
		paddusw xmm0, xmm1			; xmm0 = | ? | p3a + p1a + p4a + p2a |
		punpcklwd xmm0, xmm7		; xmm0 = | p3a + p1a + p4a + p2a |
		
		psrld xmm0, 2				; xmm0 = | (p3a + p1a + p4a + p2a) / 4 |

		paddusw xmm2, xmm3			; xmm2 = | p4b + p2b | p3b + p1b |
		movdqu xmm3, xmm2			; xmm3 = | p4b + p2b | p3b + p1b |
		psrldq xmm3, 8				; xmm3 = |     0     | p4b + p2b |
		paddusw xmm2, xmm3			; xmm2 = | ? | p3b + p1b + p4b + p2b|
		punpcklwd xmm2, xmm7		; xmm2 = | p3b + p1b + p4b + p2b |

		psrld xmm2, 2				; xmm2 = | (p3b + p1b + p4b + p2b) / 4 |
		
		; empaqueto cada pixel a 4 bytes
		packusdw xmm0, xmm0			; xmm0 = | (p3a + p1a + p4a + p2a) / 4 | (p3a + p1a + p4a + p2a) / 4 |
		packusdw xmm2, xmm2			; xmm2 = | (p3b + p1b + p4b + p2b) / 4 | (p3b + p1b + p4b + p2b) / 4 |
		packuswb xmm2, xmm0			; xmm2 = | (p3a + p1a + p4a + p2a) / 4 | (p3a + p1a + p4a + p2a) / 4 | (p3b + p1b + p4b + p2b) / 4 | (p3b + p1b + p4b + p2b) / 4 |
		
		movdqu [rsi], xmm2
		movdqu [rsi + r8], xmm2
			
		cmp edx, 0
		jne .seguir
		mov edx, eax				; terminé de recorrer una fila
		dec ecx
		add rdi, 16
		add rsi, 16
		add rdi, r8
		add rsi, r8
		jmp .ciclo

		.seguir:
			add rdi, 16
			add rsi, 16
			jmp .ciclo

		.fin:
			pop rbp
			ret