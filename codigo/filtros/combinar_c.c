#include "../tp2.h"

void combinar_c (
	unsigned char *src, 
	unsigned char *dst, 
	int cols, 
	int filas, 
	int src_row_size,
	int dst_row_size,
	float alpha
) {
	unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
	unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;

	int d = cols - 1;
	float val255 = 255.0;
	float aux = 0.0;
	for (int f = 0; f < filas; f++) {
		for (int c = 0; c < cols; c++) {
            bgra_t *p_s_a = (bgra_t*) &src_matrix[f][c * 4];
			bgra_t *p_s_b = (bgra_t*) &src_matrix[f][d * 4];
			bgra_t *p_d = (bgra_t*) &dst_matrix[f][c * 4];
			
			aux = (float) ((int) p_s_a->b - (int) p_s_b->b);							
			aux = aux * alpha;
			aux = aux / val255;
			aux = aux + p_s_b->b; 
			p_d->b = (unsigned char) aux;					
			aux = (float) ((int) p_s_a->g - (int) p_s_b->g);
			aux = aux * alpha;
			aux = aux / val255;
			aux = aux + p_s_b->g;
			p_d->g = (unsigned char) aux;			
			aux = (float) ((int) p_s_a->r - (int) p_s_b->r);
			aux = aux * alpha;
			aux = aux / val255;
			aux = aux + p_s_b->r;
			p_d->r = (unsigned char) aux;
			aux = (float) ((int) p_s_a->a - (int) p_s_b->a);
			aux = aux * alpha;
			aux = aux / val255;
			aux = aux + p_s_b->a;
			p_d->a = (unsigned char) aux;
			
			d--;
			}
		d = cols - 1;
	}
}