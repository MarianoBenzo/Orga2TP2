
#include "../tp2.h"

float clamp(float pixel)
{
	float res = pixel < 0.0 ? 0.0 : pixel;
	return res > 255.0 ? 255 : res;
}

unsigned char menor(unsigned char a, unsigned char b)
{
	return a < b ? 1 : 0;
}

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
			

			if (menor(p_s_a->b, p_s_b->b))
				p_d->b = 0;
			else
				p_d->b = p_s_a->b - p_s_b->b;
			if (menor(p_s_a->g, p_s_b->g))
				p_d->g = 0;
			else
				p_d->g = p_s_a->g - p_s_b->g;
			if (menor(p_s_a->r, p_s_b->r))
				p_d->r = 0;
			else
				p_d->r = p_s_a->r - p_s_b->r;
			if (menor(p_s_a->a, p_s_b->a))
				p_d->a = 0;
			else
				p_d->a = p_s_a->a - p_s_b->a;
			
			aux = (float) p_d->b;							
			aux = aux * alpha;
			aux = aux / val255;
			p_d->b = (unsigned char) aux;					
			aux = (float) p_d->g;
			aux = aux * alpha;
			aux = aux / val255;
			p_d->g = (unsigned char) aux;			
			aux = (float) p_d->r;
			aux = aux * alpha;
			aux = aux / val255;
			p_d->r = (unsigned char) aux;
			aux = (float) p_d->a;
			aux = aux * alpha;
			aux = aux / val255;
			p_d->a = (unsigned char) aux;

			p_d->b = p_d->b + p_s_b->b;						// no se puede pasar porque anteriormente le resté este mismo pixel y lo dividi por 255
			p_d->g = p_d->g + p_s_b->g;
			p_d->r = p_d->r + p_s_b->r;
			p_d->a = p_d->a + p_s_b->a;
			
			d--;
			}
		d = cols - 1;
	}
}
