; void colorizar_asm (
; 	unsigned char *src,
; 	unsigned char *dst,
; 	int cols,
; 	int filas,
; 	int src_row_size,
; 	int dst_row_size,
;   float alpha
; );

; Parámetros:
; 	rdi = src
; 	rsi = dst
; 	rdx = cols
; 	rcx = filas
; 	r8 = src_row_size
; 	r9 = dst_row_size
;   xmm0 = alpha

section .rodata
intercambiar: DB 0x00, 0x01, 0x02, 0x03, 0x08, 0x09, 0x0A, 0x0B, 0x04, 0x05, 0x06, 0x07, 0x0C, 0x0D, 0x0E, 0x0F
acercar: DB 0x00, 0x01, 0x02, 0x03, 0x0C, 0x0D, 0x0E, 0x0F, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B

global colorizar_asm

section .text

colorizar_asm:
	push rbp
	mov rbp, rsp
	push rbx
	push r12

	xor r8, r8
	mov r8d, edx
	shl r8, 2					; tamaño de una fila
								; rdi tiene el puntero a la fila anterior a procesar
	lea rbx, [rdi + r8]			; rbx tiene el puntero a la fila a procesar
	lea r12, [rdi + r8 * 2]		; r12 tiene el puntero a la fila posterior a procesar

	lea rsi, [rsi + r8 + 4]		; salteo la primera fila y la primera columna

	shr edx, 1					; itero de a 2 pixeles
	dec edx						; la ultima columna no la proceso
	xor rax, rax
	mov eax, edx

	sub ecx, 2					; la primera y última fila no las proceso

	xorps xmm3, xmm3			; xmm3 = | 0 | 0 | 0 | 0 |
	addss xmm3, xmm0			; xmm3 = | 0 | 0 | 0 | alpha |
	pslldq xmm0, 4				; xmm0 = | 0 | 0 | alpha | 0 |
	addss xmm0, xmm3 			; xmm0 = | 0 | 0 | alpha | alpha |
	movups xmm3, xmm0			; xmm3 = | 0 | 0 | alpha | alpha |
	pslldq xmm3, 8				; xmm3 = | alpha | alpha | 0 | 0 |
	addps xmm0, xmm3 			; xmm0 = | alpha | alpha | alpha | alpha |
	.ciclo:
		cmp ecx, 0	 				; si no hay mas filas por recorrer, termine
		je .fin
		dec edx	

		; los pixeles en mayuscula son los que estoy procesando
		movdqu xmm1, [rdi]			; xmm1 = | px3_a | px2_a | px1_a | px0_a |
		movdqu xmm2, [rbx]			; xmm2 = | px3_b | PX2_b | PX1_b | px0_b |
		movdqu xmm3, [r12]			; xmm3 = | px3_c | px2_c | px1_c | px0_c |

		pmaxub xmm1, xmm2			; xmm1 = | max(px3_a, px3_b) | max(px2_a, PX2_b) | max(px1_a, PX1_b) | max(px0_a, px0_b) |
		pmaxub xmm1, xmm3			; xmm1 = | max(col_3) | max(col_2) | max(col_1) | max(col_0) |
		movdqu xmm3, xmm1			; xmm3 = | max(col_3) | max(col_2) | max(col_1) | max(col_0) |
		pshufb xmm3, [intercambiar]	; xmm3 = | max(col_3) | max(col_1) | max(col_2) | max(col_0) |
		pmaxub xmm3, xmm1			; xmm3 = | max(col_3) | max(max(col_2), max(col_1)) | max(max(col_2), max(col_1)) | max(col_0) |
		psrldq xmm3, 4				; xmm3 = | 0 | max(col_3) | max(max(col_2), max(col_1)) | max(max(col_2), max(col_1)) |
		pshufb xmm1, [acercar]		; xmm1 = | max(col_2) | max(col_1) | max(col_3) | max(col_0) |
		pmaxub xmm1, xmm3			; xmm1 = | ? | ? | max_PX2_b | max_PX1_b | 
		; las comparaciones son con signo, entonces extiendo a word con ceros
		pxor xmm7, xmm7				; xmm7 = | 0 | 0 | 0 | 0 |
		punpcklbw xmm1, xmm7		; xmm1 = | maxA_2 | maxR_2 | maxG_2 | maxB_2 | maxA_1 | maxR_1 | maxG_1 | maxB_1 | 
		movdqu xmm3, xmm1			; xmm3 = | maxA_2 | maxR_2 | maxG_2 | maxB_2 | maxA_1 | maxR_1 | maxG_1 | maxB_1 | 
		; 132 = 10 00 01 00
		; copio al maxR para usarlo en el shuffle de xmm3, pero esa columna no me importa
		pshuflw xmm1, xmm3, 132		; xmm1 = | maxA_2 | maxR_2 | maxG_2 | maxB_2 | maxA_1 | maxB_1 | maxG_1 | maxB_1 |
		pshufhw xmm1, xmm3, 132		; xmm1 = | maxR_2 | maxB_2 | maxG_2 | maxB_2 | maxR_1 | maxB_1 | maxG_1 | maxB_1 |
		; 31 = 00 01 11 11
		; copio al maxB para no perder datos, pero esa columna no me importa
		pshuflw xmm3, xmm1, 31		; xmm3 = | maxA_2 | maxR_2 | maxG_2 | maxB_2 | maxB_1 | maxG_1 | maxR_1 | maxR_1 |
		pshufhw xmm3, xmm1, 31		; xmm3 = | maxB_2 | maxG_2 | maxR_2 | maxR_2 | maxB_1 | maxG_1 | maxR_1 | maxR_1 |
		; ahora tengo los datos alineados según las comparaciones que quiero hacer
		pcmpgtw xmm1, xmm3			; xmm1 = | ? | (maxB_2 > maxG_2)? | (maxG_2 > maxR_2)? | (maxB_2 > maxR_2)? | ? | (maxB_1 > maxG_1)? | (maxG_1 > maxR_1)? | (maxB_1 > maxR_1)? |

		cmp edx, 0
		jne .seguir
		mov edx, eax				; terminé de recorrer una fila
		dec ecx
		add rdi, 8					; me salteo la ultima columna
		add rbx, 8
		add r12, 8
		add rsi, 8
		.seguir:
			add rdi, 8
			add rbx, 8
			add r12, 8
			add rsi, 8
			jmp .ciclo

	ret

