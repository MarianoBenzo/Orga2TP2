
#include "../tp2.h"

void smalltiles_c (unsigned char *src, unsigned char *dst, int cols, int filas, int src_row_size, int dst_row_size) {
	//COMPLETAR
	unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
	unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;
	
	// ejemplo de uso de src_matrix y dst_matrix (copia la imagen)
/*
	for (int f = 0; f < filas; f++) {
		for (int c = 0; c < cols; c++) {
			bgra_t *p_d = (bgra_t*) &dst_matrix[f][c * 4];
            bgra_t *p_s = (bgra_t*) &src_matrix[f][c * 4];

			p_d->b = p_s->b;
			p_d->g = p_s->g;
			p_d->r = p_s->r;
			p_d->a = p_s->a;

		}
	}*/
	
	for(int f = 0; f < filas/2; f++)
	{
		for(int c = 0; c < cols/2; c++)
		{
			bgra_t* p_sa = (bgra_t*) &src_matrix[2*f][2*(c*4)];
			//bgra_t* p_sb = (bgra_t*) &src_matrix[f + 4][c*4];
			
			bgra_t *p_d = (bgra_t*) &dst_matrix[f][c*4];
			bgra_t *p_e = (bgra_t*) &dst_matrix[f + filas/2][c*4];
			bgra_t *p_f = (bgra_t*) &dst_matrix[f][(c + cols/2)*4];
			bgra_t *p_g = (bgra_t*) &dst_matrix[f + filas/2 ][(c + cols/2)*4];

			p_d->b = p_sa->b;
			p_d->g = p_sa->g;
			p_d->r = p_sa->r;
			p_d->a = p_sa->a;
			
			p_e->b = p_sa->b;
			p_e->g = p_sa->g;
			p_e->r = p_sa->r;
			p_e->a = p_sa->a;
			
			p_f->b = p_sa->b;
			p_f->g = p_sa->g;
			p_f->r = p_sa->r;
			p_f->a = p_sa->a;
			
			p_g->b = p_sa->b;
			p_g->g = p_sa->g;
			p_g->r = p_sa->r;
			p_g->a = p_sa->a;

		}
	}
	
}
