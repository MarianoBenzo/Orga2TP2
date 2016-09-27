DEFAULT REL

section .text
global rotar_asm
rotar_asm:
; rdi = *src, rsi = *dst, edx = columnas (en pixels), ecx = filas (en pixels)
	push rbp
	mov rbp, rsp

	shr edx, 2				; itero de a 4 pixels (dentro de las columnas)
	xor rax, rax			; copio el valor de las columnas porque itero sobre ese valor
	mov eax, edx			

	
	; xmm0: | a b r g | a b r g | a b r g | a b r g |
	.ciclo:
		cmp ecx, 0 			; si no hay mas filas por recorrer, termine
		je .fin
		dec edx				
		movdqu xmm0, [rdi]	; xmm0: | a4 r4 g4 b4 | a3 r3 g3 b3 | a2 r2 g2 b2 | a1 r1 g1 b1 | 
		pxor xmm7, xmm7				; xmm7 = | 0 | 0 | 0 | 0 |
		
		;///////////////////Pixel 1
		movdqu xmm8, xmm0	; xmm8: | a r g b | a r g b | a r g b | a r g b |
		
		punpcklbw xmm8, xmm7		; xmm8 = | a2 r2 | g2 b2 | a1 r1 | g1 b1 |
		punpcklwd xmm8, xmm7		; xmm8 = | a1 | r1 | g1 | b1 |

		movdqu xmm6, xmm8			; xmm6 = | a1 | r1 | g1 | b1 |
		punpckhbw xmm6, xmm7		; xmm6 = | a1 | r1 |
		punpckhwd xmm6, xmm7		; xmm6 = | a1 |

		movdqu xmm5, xmm8			; xmm5 = | a1 | r1 | g1 | b1 |
		punpcklbw xmm5, xmm7		; xmm5 = | g1 | b1 |
		punpcklwd xmm5, xmm7		; xmm5 = | b1 |

		movdqu xmm4, xmm5		
		packusdw xmm4, xmm6			; xmm4 = | a1 | b1 |

		movdqu xmm6, xmm8			; xmm6 = | a1 | r1 | g1 | b1 |
		punpckhbw xmm6, xmm7		; xmm6 = | a1 | r1 |
		punpcklwd xmm6, xmm7		; xmm6 = | r1 |

		movdqu xmm5, xmm8			; xmm5 = | a1 | r1 | g1 | b1 |
		punpcklbw xmm5, xmm7		; xmm5 = | g1 | b1 |
		punpckhwd xmm5, xmm7		; xmm5 = | g1 |

		packusdw xmm5, xmm6			; xmm5 = | r1 | g1 |

		packuswb xmm5, xmm4			; xmm5 = | a1 | r1 | g1 | b1 |
		movdqu xmm1, xmm5			; xmm1 = | a1 | r1 | g1 | b1 |

		;///////////////////Pixel 2
		movdqu xmm8, xmm0	; xmm8: | a r g b | a r g b | a r g b | a r g b |
		
		punpcklbw xmm8, xmm7		; xmm8 = | a2 r2 | g2 b2 | a1 r1 | g1 b1 |
		punpckhwd xmm8, xmm7		; xmm8 = | a2 | r2 | g2 | b2 |

		movdqu xmm6, xmm8			; xmm6 = | a2 | r2 | g2 | b2 |
		punpckhbw xmm6, xmm7		; xmm6 = | a2 | r2 |
		punpckhwd xmm6, xmm7		; xmm6 = | a2 |

		movdqu xmm5, xmm8			; xmm5 = | a2 | r2 | g2 | b2 |
		punpcklbw xmm5, xmm7		; xmm5 = | g2 | b2 |
		punpcklwd xmm5, xmm7		; xmm5 = | b2 |

		movdqu xmm4, xmm5		
		packusdw xmm4, xmm6			; xmm4 = | a2 | b2 |

		movdqu xmm6, xmm8			; xmm6 = | a2 | r2 | g2 | b2 |
		punpckhbw xmm6, xmm7		; xmm6 = | a2 | r2 |
		punpcklwd xmm6, xmm7		; xmm6 = | r2 |

		movdqu xmm5, xmm8			; xmm5 = | a2 | r2 | g2 | b2 |
		punpcklbw xmm5, xmm7		; xmm5 = | g2 | b2 |
		punpckhwd xmm5, xmm7		; xmm5 = | g2 |

		packusdw xmm5, xmm6			; xmm5 = | r2 | g2 |

		packuswb xmm5, xmm4			; xmm5 = | a2 | r2 | g2 | b2 |
		movdqu xmm2, xmm5			; xmm2 = | a2 | r2 | g2 | b2 |

		;///////////////////Pixel 3
		movdqu xmm8, xmm0	; xmm8: | a r g b | a r g b | a r g b | a r g b |
		
		punpckhbw xmm8, xmm7		; xmm8 = | a4 r4 | g4 b4 | a3 r3 | g3 b3 |
		punpcklwd xmm8, xmm7		; xmm8 = | a3 | r3 | g3 | b3 |

		movdqu xmm6, xmm8			; xmm6 = | a3 | r3 | g3 | b3 |
		punpckhbw xmm6, xmm7		; xmm6 = | a3 | r3 |
		punpckhwd xmm6, xmm7		; xmm6 = | a3 |

		movdqu xmm5, xmm8			; xmm5 = | a3 | r3 | g3 | b3 |
		punpcklbw xmm5, xmm7		; xmm5 = | g3 | b3 |
		punpcklwd xmm5, xmm7		; xmm5 = | b3 |

		movdqu xmm4, xmm5		
		packusdw xmm4, xmm6			; xmm4 = | a3 | b3 |

		movdqu xmm6, xmm8			; xmm6 = | a3 | r3 | g3 | b3 |
		punpckhbw xmm6, xmm7		; xmm6 = | a3 | r3 |
		punpcklwd xmm6, xmm7		; xmm6 = | r3 |

		movdqu xmm5, xmm8			; xmm5 = | a3 | r3 | g3 | b3 |
		punpcklbw xmm5, xmm7		; xmm5 = | g3 | b3 |
		punpckhwd xmm5, xmm7		; xmm5 = | g3 |

		packusdw xmm5, xmm6			; xmm5 = | r3 | g3 |

		packuswb xmm5, xmm4			; xmm5 = | a3 | r3 | g3 | b3 |
		movdqu xmm3, xmm5			; xmm3 = | a3 | r3 | g3 | b3 |
		
		;///////////////////Pixel 4
		movdqu xmm8, xmm0	; xmm8: | a r g b | a r g b | a r g b | a r g b |
		
		punpckhbw xmm8, xmm7		; xmm8 = | a4 r4 | g4 b4 | a3 r3 | g3 b3 |
		punpckhwd xmm8, xmm7		; xmm8 = | a4 | r4 | g4 | b4 |

		movdqu xmm6, xmm8			; xmm6 = | a4 | r4 | g4 | b4 |
		punpckhbw xmm6, xmm7		; xmm6 = | a4 | r4 |
		punpckhwd xmm6, xmm7		; xmm6 = | a4 |

		movdqu xmm5, xmm8			; xmm5 = | a4 | r4 | g4 | b4 |
		punpcklbw xmm5, xmm7		; xmm5 = | g4 | b4 |
		punpcklwd xmm5, xmm7		; xmm5 = | b4 |

		movdqu xmm4, xmm5		
		packusdw xmm4, xmm6			; xmm4 = | a4 | b4 |

		movdqu xmm6, xmm8			; xmm6 = | a4 | r4 | g4 | b4 |
		punpckhbw xmm6, xmm7		; xmm6 = | a4 | r4 |
		punpcklwd xmm6, xmm7		; xmm6 = | r4 |

		movdqu xmm5, xmm8			; xmm5 = | a4 | r4 | g4 | b4 |
		punpcklbw xmm5, xmm7		; xmm5 = | g4 | b4 |
		punpckhwd xmm5, xmm7		; xmm5 = | g4 |

		packusdw xmm5, xmm6			; xmm5 = | r4 | g4 |

		packuswb xmm5, xmm4			; xmm5 = | a4 | r4 | g4 | b4 |
		movdqu xmm4, xmm5			; xmm4 = | a4 | r4 | g4 | b4 |

		;////////////////// Acomodo
		; xmm1 = | a1 | r1 | g1 | b1 |
		; xmm2 = | a2 | r2 | g2 | b2 |
		; xmm3 = | a3 | r3 | g3 | b3 |
		; xmm4 = | a4 | r4 | g4 | b4 |

		packusdw xmm1, xmm2			; xmm1 = | a2 r2 g2 b2 | a1 r1 g1 b1 |
		packusdw xmm3, xmm4			; xmm3 = | a4 r4 g4 b4 | a3 r3 g3 b3 |
		packuswb xmm1, xmm3			; xmm1 = | a4 r4 g4 b4 | a3 r3 g3 b3 | a2 r2 g2 b2 | a1 r1 g1 b1 |


		movdqu [rsi], xmm1

		cmp edx, 0
		jne .seguir
		mov edx, eax		; terminé de recorrer una fila
		dec ecx
		.seguir:
			add rdi, 16
			add rsi, 16
			jmp .ciclo
	.fin:
		pop rbp
		ret
