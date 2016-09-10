section .rodata
swap: db 0x00, 0x03, 0x01, 0x02, 0x04, 0x07, 0x05, 0x06, 0x08, 0x0B, 0x09, 0x0A, 0x0C, 0x0F, 0x0D, 0x0E
DEFAULT REL

section .text
global rotar_asm
rotar_asm:
; rdi = *src, rsi = *dst, edx = filas (en pixels), ecx = columnas (en pixels)
	push rbp
	mov rbp, rsp

	shr ecx, 2				; itero de a 4 pixels (dentro de las columnas)
	xor rax, rax			; copio el valor de las columnas porque itero sobre ese valor
	mov eax, ecx			

	movdqu xmm8, [swap]
	.ciclo:
		cmp edx, 0 			; si no hay mas filas por recorrer, termine
		je .fin
		dec ecx				
		movdqu xmm0, [rdi]	; xmm0: | b g r a | b g r a | b g r a | b g r a |
		pshufb xmm0, xmm8	; xmm0: | g r b a | g r b a | g r b a | g r b a |
		movdqu [rsi], xmm0

		cmp ecx, 0
		jne .seguir
		mov ecx, eax		; terminé de recorrer una fila
		dec edx
		.seguir:
			add rdi, 16
			add rsi, 16
			jmp .ciclo

	pop rbp
	ret
