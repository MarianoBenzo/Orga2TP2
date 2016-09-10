
#include "../tp2.h"

void pixelar_c (
	unsigned char *src, 
	unsigned char *dst, 
	int cols, 
	int filas, 
	int src_row_size, 
	int dst_row_size
) {
	unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
	unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;

	//COMPLETAR

	for (int f = 0; f < filas; f=f+2) {
		for (int c = 0; c < cols; c=c+2) {

			bgra_t *p_s1 = (bgra_t*) &src_matrix[f][c*4];
            bgra_t *p_s2 = (bgra_t*) &src_matrix[f][(c+1)*4];
            bgra_t *p_s3 = (bgra_t*) &src_matrix[f+1][c*4];
            bgra_t *p_s4 = (bgra_t*) &src_matrix[f+1][(c+1)*4];

			bgra_t *p_d1 = (bgra_t*) &dst_matrix[f][c*4];
			bgra_t *p_d2 = (bgra_t*) &dst_matrix[f][(c+1)*4];
			bgra_t *p_d3 = (bgra_t*) &dst_matrix[f+1][c*4];
			bgra_t *p_d4 = (bgra_t*) &dst_matrix[f+1][(c+1)*4];

            bgra_t p_prom;

            p_prom.b = (p_s1->b + p_s2->b + p_s3->b + p_s4->b) / 4 ;
			p_prom.g = (p_s1->g + p_s2->g + p_s3->g + p_s4->g) / 4 ;
			p_prom.r = (p_s1->r + p_s2->r + p_s3->r + p_s4->r) / 4 ;
			p_prom.a = (p_s1->a + p_s2->a + p_s3->a + p_s4->a) / 4 ;

			p_d1->b = p_prom.b;
			p_d1->g = p_prom.g;
			p_d1->r = p_prom.r;
			p_d1->a = p_prom.a;

			p_d2->b = p_prom.b;
			p_d2->g = p_prom.g;
			p_d2->r = p_prom.r;
			p_d2->a = p_prom.a;

			p_d3->b = p_prom.b;
			p_d3->g = p_prom.g;
			p_d3->r = p_prom.r;
			p_d3->a = p_prom.a;

			p_d4->b = p_prom.b;
			p_d4->g = p_prom.g;
			p_d4->r = p_prom.r;
			p_d4->a = p_prom.a;

		}
	}

}
