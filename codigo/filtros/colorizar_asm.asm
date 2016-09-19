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
negar: DW 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF
val1W: DW 1, 1, 1, 1, 1, 1, 1, 1
val1F: DD 1.0, 1.0, 1.0, 1.0
val255F: DD 255.0, 255.0, 255.0, 255.0

global colorizar_asm

section .text

colorizar_asm:
	push rbp		
	mov rbp, rsp
	push rbx	
	push r12		
	push r13		
	push r14		

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
	movdqu xmm8, [negar]		; xmm8 = | 0xFFFF | 0xFFFF | 0xFFFF | 0xFFFF | 0xFFFF | 0xFFFF | 0xFFFF | 0xFFFF |
	movdqu xmm9, [val1W]		; xmm9 = | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 
	movdqu xmm10, [val1F]		; xmm10= | 1.0 | 1.0 | 1.0 | 1.0 |
	movdqu xmm11, [val255F]		; xmm11= | 255.0 | 255.0 | 255.0 | 255.0 | 
	.ciclo:
		cmp ecx, 0	 				; si no hay mas filas por recorrer, termine
		je .fin
		dec edx	

		; los pixeles en mayuscula son los que estoy procesando
		movdqu xmm1, [rdi]			; xmm1 = | px3_a | px2_a | px1_a | px0_a |
		movdqu xmm2, [rbx]			; xmm2 = | px3_b | PX2_b | PX1_b | px0_b |
		movdqu xmm3, [r12]			; xmm3 = | px3_c | px2_c | px1_c | px0_c |
		; obtengo el maximo de cada color 
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
		pshuflw xmm1, xmm3, 132		; xmm1 = | maxA_2 | maxR_2 | maxG_2 | maxB_2 | maxR_1 | maxB_1 | maxG_1 | maxB_1 |
		; copio a xmm1, porque el shuffle high me reemplaza la parte low
		movdqu xmm3, xmm1			; xmm3 = | maxA_2 | maxR_2 | maxG_2 | maxB_2 | maxR_1 | maxB_1 | maxG_1 | maxB_1 |
		pshufhw xmm1, xmm3, 132		; xmm1 = | maxR_2 | maxB_2 | maxG_2 | maxB_2 | maxR_1 | maxB_1 | maxG_1 | maxB_1 |
		; 31 = 00 01 11 11
		; copio al maxB, pero esa columna no me importa
		pshuflw xmm3, xmm1, 31		; xmm3 = | maxR_2 | maxB_2 | maxG_2 | maxB_2 | maxB_1 | maxG_1 | maxR_1 | maxR_1 |
		; uso a xmm4 de auxiliar para no perder la parte baja en el shuffle
		movdqu xmm4, xmm3			; xmm4 = | maxR_2 | maxB_2 | maxG_2 | maxB_2 | maxB_1 | maxG_1 | maxR_1 | maxR_1 |
		pshufhw xmm3, xmm4, 31		; xmm3 = | maxB_2 | maxG_2 | maxR_2 | maxR_2 | maxB_1 | maxG_1 | maxR_1 | maxR_1 |
		; ahora tengo los datos alineados según las comparaciones que quiero hacer
		pcmpgtw xmm1, xmm3			; xmm1 = | ? | (maxB_2 > maxG_2)? | (maxG_2 > maxR_2)? | (maxB_2 > maxR_2)? | ? | (maxB_1 > maxG_1)? | (maxG_1 > maxR_1)? | (maxB_1 > maxR_1)? |
		movdqu xmm3, xmm1			; xmm3 = | ? | (maxB_2 > maxG_2)? | (maxG_2 > maxR_2)? | (maxB_2 > maxR_2)? | ? | (maxB_1 > maxG_1)? | (maxG_1 > maxR_1)? | (maxB_1 > maxR_1)? |
		; obtengo el complemento de las comparaciones
		pxor xmm3, xmm8				; xmm3 = | ? | (maxG_2 >= maxB_2)? | (maxR_2 >= maxG_2)? | (maxR_2 >= maxB_2)? | ? | (maxG_1 >= maxB_1)? | (maxR_1 >= maxG_1)? | (maxR_1 >= maxB_1)? |
		; extraigo (maxB > maxR)? para insertarlo en xmm3
		pextrw r13d, xmm1, 0 		; r13w = (maxB_1 > maxR_1)?
		pextrw r14d, xmm1, 4		; r14w = (maxB_2 > maxR_2)?
		pinsrw xmm3, r13d, 3 		; xmm3 = | ? | (maxG_2 >= maxB_2)? | (maxR_2 >= maxG_2)? | (maxR_2 >= maxB_2)? | (maxB_1 > maxR_1)? | (maxG_1 >= maxB_1)? | (maxR_1 >= maxG_1)? | (maxR_1 >= maxB_1)? |
		pinsrw xmm3, r14d, 7		; xmm3 = | (maxB_2 > maxR_2)? | (maxG_2 >= maxB_2)? | (maxR_2 >= maxG_2)? | (maxR_2 >= maxB_2)? | (maxB_1 > maxR_1)? | (maxG_1 >= maxB_1)? | (maxR_1 >= maxG_1)? | (maxR_1 >= maxB_1)? |
		; extraigo (maxR >= maxB)? para insertarlo en xmm1
		pextrw r13d, xmm3, 0 		; r13w = (maxR_1 >= maxB_1)?
		pextrw r14d, xmm3, 4		; r14w = (maxR_2 >= maxB_2)?
		pinsrw xmm1, r13d, 0   		; xmm1 = | ? | (maxB_2 > maxG_2)? | (maxG_2 > maxR_2)?  | (maxB_2 > maxR_2)?  | ? | (maxB_1 > maxG_1)? | (maxG_1 > maxR_1)?  | (maxR_1 >= maxB_1)? |
		pinsrw xmm1, r14d, 4 		; xmm1 = | ? | (maxB_2 > maxG_2)? | (maxG_2 > maxR_2)?  | (maxR_2 >= maxB_2)? | ? | (maxB_1 > maxG_1)? | (maxG_1 > maxR_1)?  | (maxR_1 >= maxB_1)? |
		; acomodo los datos
		psrldq xmm3, 2   			; xmm3 = | ? | (maxB_2 > maxR_2)? | (maxG_2 >= maxB_2)? | (maxR_2 >= maxG_2)? | ? | (maxB_1 > maxR_1)? | (maxG_1 >= maxB_1)? | (maxR_1 >= maxG_1)? |
		pand xmm1, xmm3				; xmm1 = | ? | condicion(phiB_2) | condicion(phiG_2) | condicion(phiR_2) | ? | condicion(phiB_1) | condicion(phiG_1) | condicion(phiR_1) |
		movdqu xmm7, xmm1			; xmm7 = | ? | condicion(phiB_2) | condicion(phiG_2) | condicion(phiR_2) | ? | condicion(phiB_1) | condicion(phiG_1) | condicion(phiR_1) |
		movdqu xmm3, xmm1			; xmm3 = | ? | condicion(phiB_2) | condicion(phiG_2) | condicion(phiR_2) | ? | condicion(phiB_1) | condicion(phiG_1) | condicion(phiR_1) |
		; genero la mascara con el valor uno donde la condicion dio true
		pand xmm7, xmm9
		; niego las condiciones originales y sumo
		pxor xmm3, xmm8		
		paddw xmm3, xmm7			; xmm3 = 0x0001 donde dio true y 0xFFFF donde dio false
		; ahora resta extender a dword, convertirlo a float y multiplicarlo por alpha
		pxor xmm7, xmm7
		pcmpgtw xmm7, xmm3 			; obtengo la mascara para extender con signo
		movdqu xmm1, xmm3			; xmm1 = 0x0001 donde dio true y 0xFFFF donde dio false
		punpcklwd xmm1, xmm7		; xmm1 = 0x0001 donde dio true y 0xFFFF donde dio false (PX1)
		punpckhwd xmm3, xmm7		; xmm3 = 0x0001 donde dio true y 0xFFFF donde dio false (PX2)
		cvtdq2ps xmm1, xmm1
		cvtdq2ps xmm3, xmm3
		mulps xmm1, xmm0			; xmm1 = alpha donde dio true y -alpha donde dio false (PX1)
		mulps xmm3, xmm0			; xmm3 = alpha donde dio true y -alpha donde dio false (PX2)
		movdqu xmm4, xmm10			; xmm4 = | 1.0 | 1.0 | 1.0 | 1.0 |
		movdqu xmm5, xmm10 			; xmm5 = | 1.0 | 1.0 | 1.0 | 1.0 |
		addps xmm4, xmm1 			; xmm4 = | ? | phiB_1 | phiG_1 | phiR_1 |
		addps xmm5, xmm3 			; xmm5 = | ? | phiB_2 | phiG_2 | phiR_2 |
		; acomodo los resultados
		; 102 = 11 00 01 10
		shufps xmm4, xmm4, 102 		; xmm4 = | ? | phiR_1 | phiG_1 | phiB_1 |
		shufps xmm5, xmm5, 102 		; xmm5 = | ? | phiR_2 | phiG_2 | phiB_2 |
		; extiendo los pixeles originales a float
		psrldq xmm2, 4				; xmm2 = | ? | ? | PX2 | PX1 |
		movdqu xmm3, xmm2 			; xmm3 = | ? | ? | PX2 | PX1 |
		pxor xmm7, xmm7 			; xmm7 = | 0 | 0 | 0 | 0 |
		punpcklbw xmm3, xmm7  		; xmm3 = | PX2 | PX1 |
		movdqu xmm1, xmm3			; xmm1 = | PX2 | PX1 |
		punpcklwd xmm1, xmm7 		; xmm1 = | PX1 |
		punpckhwd xmm3, xmm7 		; xmm3 = | PX2 |
		cvtdq2ps xmm1, xmm1 		; xmm1 = | A_1 | R_1 | G_1 | B_1 |
		cvtdq2ps xmm3, xmm3 		; xmm3 = | A_2 | R_2 | G_2 | B_2 |
		mulps xmm1, xmm4 			; xmm1 = | ? | R_1 * phiR_1 | G_1 * phiG_1 | B_1 * phiB_1 |
		mulps xmm3, xmm5 			; xmm3 = | ? | R_2 * phiR_2 | G_2 * phiG_2 | B_2 * phiB_2 |
		; hago la mascara con aquellos numeros mayores y menores a 255
		movdqu xmm4, xmm11			; xmm4 = | 255.0 | 255.0 | 255.0 | 255.0 | 
		movdqu xmm5, xmm11			; xmm5 = | 255.0 | 255.0 | 255.0 | 255.0 |
		movdqu xmm12, xmm11			; xmm11= | 255.0 | 255.0 | 255.0 | 255.0 | 
		movdqu xmm13, xmm11			; xmm12= | 255.0 | 255.0 | 255.0 | 255.0 |
		cmpps xmm12, xmm1, 6 		; compare less or equal -> tengo en true aquellos menores o iguales a 255.0
		cmpps xmm13, xmm3, 6
		movdqu xmm6, xmm12
		movdqu xmm7, xmm13
		xorps xmm6, xmm8			; niego y tengo en true aquellos mayores a 255
		xorps xmm7, xmm8
		andps xmm1, xmm12			; valores menores o iguales a 255 con phi*_1
		andps xmm4, xmm6			; 255.0 en las posiciones de los phi*_1 mayores a 255
		andps xmm3, xmm13			; valores menores a 255 con phi*_2
		andps xmm5, xmm7 			; 255.0 en las posiciones de los phi*_2 mayores a 255
		; obtengo el resultado final
		addps xmm1, xmm4 			; xmm1 = | ? | min(R_1 * phiR_1, 255.0) | min(G_1 * phiG_1, 255.0) | min(B_1 * phiB_1, 255.0) |
		addps xmm3, xmm5 			; xmm3 = | ? | min(R_2 * phiR_2, 255.0) | min(G_2 * phiG_2, 255.0) | min(B_2 * phiB_2, 255.0) |
		; convierto a entero
		cvtps2dq xmm1, xmm1
		cvtps2dq xmm3, xmm3
		; empaqueto a byte
		packusdw xmm1, xmm3 		; xmm1 = | ? | min(R_2 * phiR_2, 255) | min(G_2 * phiG_2, 255) | min(B_2 * phiB_2, 255) | ? | min(R_1 * phiR_1, 255) | min(G_1 * phiG_1, 255) | min(B_1 * phiB_1, 255) |		
		pxor xmm7, xmm7
		packuswb xmm1, xmm7
		; copio el valor alpha original del pixel
		pextrb r13d, xmm2, 3
		pextrb r14d, xmm2, 7
		pinsrb xmm1, r13d, 3
		pinsrb xmm1, r14d, 7
		
		movq [rsi], xmm1

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
	.fin:
		pop r14
		pop r13
		pop r12
		pop rbx
		pop rbp
		ret