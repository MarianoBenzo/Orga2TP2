; void combinar_asm (
; 	unsigned char *src,
; 	unsigned char *dst,
; 	int cols,
; 	int filas,
; 	int src_row_size,
; 	int dst_row_size,
; 	float alpha
; );

; Parámetros:
; 	rdi = src
; 	rsi = dst
; 	rdx = cols
; 	rcx = filas
; 	r8 = dst_row_size
; 	r9 = dst_row_size
; 	xmm0 = alpha

section .rodata
val255: dd 255.0, 255.0, 255.0, 255.0
invertir: db 0x0C, 0x0D, 0x0E, 0x0F, 0x08, 0x09, 0x0A, 0x0B, 0x04, 0x05, 0x06, 0x07, 0x00, 0x01, 0x02, 0x03

global combinar_asm

extern combinar_c

section .text

combinar_asm:
	push rbp
	mov rbp, rsp
	push rbx
	sub rsp, 8

	xor rax, rax
	mov eax, edx				
	lea rbx, [rdi + rax * 4]	; rbx contiene el puntero al siguiente elemento de la ultima columna
	sub rbx, 16

	shr edx, 2					; itero de a 4 pixels (dentro de las columnas)		

	movdqu xmm8, [invertir]
	movdqu xmm6, [val255]		; xmm6 = | 255.0 | 255.0 | 255.0 | 255.0 |
	xorps xmm3, xmm3
	addss xmm3, xmm0			; xmm3 = | 0 | 0 | 0 | alpha |
	pslldq xmm0, 4				; xmm0 = | 0 | 0 | alpha | 0 |
	addss xmm0, xmm3 			; xmm0 = | 0 | 0 | alpha | alpha |
	movups xmm3, xmm0			; xmm3 = | 0 | 0 | alpha | alpha |
	pslldq xmm3, 8				; xmm3 = | alpha | alpha | 0 | 0 |
	addps xmm0, xmm3 			; xmm0 = | alpha | alpha | alpha | alpha |
	.ciclo:
		cmp ecx, 0	 			; si no hay mas filas por recorrer, termine
		je .fin
		dec edx	

		movdqu xmm1, [rdi]		; xmm1 = | px3_a | px2_a | px1_a | px0_a |
		movdqu xmm2, [rbx]		; xmm2 = | px0_b | px1_b | px2_b | px3_b |
		pshufb xmm2, xmm8		; xmm2 = | px3_b | px2_b | px1_b | px0_b |
		; desempaqueto cada pixel (src_a) a 16 bytes
		movdqu xmm3, xmm1		; xmm3 = | px3_a | px2_a | px1_a | px0_a |
		pxor xmm7, xmm7			; xmm7 = | 0 | 0 | 0 | 0 |
		punpcklbw xmm1, xmm7	; xmm1 = | px1_a | px0_a |
		punpckhbw xmm3, xmm7	; xmm3 = | px3_a | px2_a | 
		movdqu xmm4, xmm1		; xmm4 = | px1_a | px0_a |
		movdqu xmm5, xmm3		; xmm5 = | px3_a | px2_a | 
		punpcklwd xmm1, xmm7	; xmm1 = | px0_a |
		punpckhwd xmm4, xmm7 	; xmm4 = | px1_a |
		punpcklwd xmm3, xmm7 	; xmm3 = | px2_a | 
		punpckhwd xmm5, xmm7	; xmm5 = | px3_a |
		; desempaqueto cada pixel (src_b) a 16 bytes
		movdqu xmm9, xmm2		; xmm9 = | px3_b | px2_b | px1_b | px0_b |
		punpcklbw xmm2, xmm7	; xmm2 = | px1_b | px0_b |
		punpckhbw xmm9, xmm7	; xmm9 = | px3_b | px2_b |
		movdqu xmm10, xmm2		; xmm10= | px1_b | px0_b |
		movdqu xmm11, xmm9		; xmm11= | px3_b | px2_b |
		punpcklwd xmm2, xmm7	; xmm2 = | px0_b |
		punpckhwd xmm10, xmm7 	; xmm10= | px1_b |
		punpcklwd xmm9, xmm7 	; xmm9 = | px2_b | 
		punpckhwd xmm11, xmm7	; xmm11= | px3_b |
		; resto cada pixel como 4 enteros de 32 bits
		psubd xmm1, xmm2		; xmm1 = | px0_a - px0_b |
		psubd xmm4, xmm10		; xmm4 = | px1_a - px1_b |
		psubd xmm3, xmm9		; xmm3 = | px2_a - px2_b | 
		psubd xmm5, xmm11		; xmm5 = | px3_a - px3_b |
		; convierto cada color del pixel (src_a) de entero a float 
		cvtdq2ps xmm1, xmm1
		cvtdq2ps xmm4, xmm4
		cvtdq2ps xmm3, xmm3
		cvtdq2ps xmm5, xmm5
		; multiplico cada valor por el alpha
		mulps xmm1, xmm0		; xmm1 = | (px0_a - px0_b) * alpha |
		mulps xmm4, xmm0		; xmm4 = | (px1_a - px1_b) * alpha |
		mulps xmm3, xmm0		; xmm3 = | (px2_a - px2_b) * alpha |
		mulps xmm5, xmm0		; xmm5 = | (px3_a - px3_b) * alpha |
		; divido por 255.0
		divps xmm1, xmm6		; xmm1 = | ((px0_a - px0_b) * alpha ) / 255.0|
		divps xmm4, xmm6		; xmm4 = | ((px1_a - px1_b) * alpha ) / 255.0|
		divps xmm3, xmm6		; xmm3 = | ((px2_a - px2_b) * alpha ) / 255.0|
		divps xmm5, xmm6		; xmm5 = | ((px3_a - px3_b) * alpha ) / 255.0|
		; convierto cada color del pixel (src_a) de float a entero
		cvtps2dq xmm1, xmm1
		cvtps2dq xmm4, xmm4
		cvtps2dq xmm3, xmm3
		cvtps2dq xmm5, xmm5
		; hago la suma
		paddd xmm1, xmm2
		paddd xmm4, xmm10
		paddd xmm3, xmm9
		paddd xmm5, xmm11
		; empaqueto cada pixel a 4 bytes
		packusdw xmm1, xmm4		; xmm1 = | ((px1_a - px1_b) * alpha ) / 255.0 | ((px0_a - px0_b) * alpha ) / 255.0 |
		packusdw xmm3, xmm5		; xmm3 = | ((px3_a - px3_b) * alpha ) / 255.0 | ((px2_a - px2_b) * alpha ) / 255.0 |
		packuswb xmm1, xmm3		; xmm1 = | ((px3_a - px3_b) * alpha ) / 255.0 | ((px2_a - px2_b) * alpha ) / 255.0 | ((px1_a - px1_b) * alpha ) / 255.0 | ((px0_a - px0_b) * alpha ) / 255.0 |

		movdqu [rsi], xmm1

		cmp edx, 0
		jne .seguir
		mov edx, eax			; terminé de recorrer una fila
		dec ecx
		shr edx, 2				
		lea rbx, [rdi + rax * 4]
		add rbx, 16				; ya estoy posicionado donde quiero, pero despues se lo resto
		.seguir:
			add rdi, 16
			add rsi, 16
			sub rbx, 16
			jmp .ciclo
	.fin:
		add rsp, 8
		pop rbx
		pop rbp
		ret