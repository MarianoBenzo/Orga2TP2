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

global combinar_asm

extern combinar_c

section .text

combinar_asm:
	push rbp
	mov rbp, rsp
	push rbx
	sub rsp, 8

	shr edx, 2				; itero de a 4 pixels (dentro de las columnas)
	xor rax, rax			; copio el valor de las columnas porque itero sobre ese valor
	mov eax, edx		

	; en rbx tengo el puntero a la imagen pero en reflejo vertical (leo de der. a izq.)

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
		movdqu xmm2, [rbx]		; xmm2 = | px3_b | px2_b | px1_b | px0_b |
		psubusb xmm1, xmm2		; xmm1 = | px3_a - px3_b | px2_a - px2_b | px1_a - px1_b | px0_a - px0_b |
		; desempaqueto cada pixel a 16 bytes
		movdqu xmm3, xmm1		; xmm3 = | px3_a - px3_b | px2_a - px2_b | px1_a - px1_b | px0_a - px0_b |
		pxor xmm7, xmm7			; xmm7 = | 0 | 0 | 0 | 0 |
		punpcklbw xmm1, xmm7	; xmm1 = | px1_a - px1_b | px0_a - px0_b |
		punpckhbw xmm3, xmm7	; xmm3 = | px3_a - px3_b | px2_a - px2_b | 
		movdqu xmm4, xmm1		; xmm4 = | px1_a - px1_b | px0_a - px0_b |
		movdqu xmm5, xmm3		; xmm5 = | px3_a - px3_b | px2_a - px2_b | 
		punpcklwd xmm1, xmm7	; xmm1 = | px0_a - px0_b |
		punpckhwd xmm4, xmm7 	; xmm4 = | px1_a - px1_b |
		punpcklwd xmm3, xmm7 	; xmm3 = | px2_a - px2_b | 
		punpckhwd xmm5, xmm7	; xmm5 = | px3_a - px3_b |
		; convierto cada color del pixel de entero a float 
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
		; convierto cada color del pixel de float a entero
		cvtps2dq xmm1, xmm1
		cvtps2dq xmm4, xmm4
		cvtps2dq xmm3, xmm3
		cvtps2dq xmm5, xmm5
		; empaqueto cada pixel a 4 bytes
		packusdw xmm1, xmm4		; xmm1 = | ((px1_a - px1_b) * alpha ) / 255.0 | ((px0_a - px0_b) * alpha ) / 255.0 |
		packusdw xmm3, xmm5		; xmm3 = | ((px3_a - px3_b) * alpha ) / 255.0 | ((px2_a - px2_b) * alpha ) / 255.0 |
		packuswb xmm1, xmm3		; xmm1 = | ((px3_a - px3_b) * alpha ) / 255.0 | ((px2_a - px2_b) * alpha ) / 255.0 | ((px1_a - px1_b) * alpha ) / 255.0 | ((px0_a - px0_b) * alpha ) / 255.0 |
		; hago la suma final
		; xmm2 = | px3_b | px2_b | px1_b | px0_b |
		paddusb xmm1, xmm2		; xmm1 = | px3 | px2 | px1 | px0 |

		movdqu [rsi], xmm1

		cmp edx, 0
		jne .seguir
		mov edx, eax			; terminé de recorrer una fila
		dec ecx
		.seguir:
			add rdi, 16
			add rsi, 16
			sub rbx, 16
			jmp .ciclo
	.fin:
		call combinar_c

		add rsp, 8
		pop rbx
		pop rbp
		ret
