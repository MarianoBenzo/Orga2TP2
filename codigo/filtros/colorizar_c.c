
#include "../tp2.h"


void colorizar_c (
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

	for (int f = 1; f < filas-1; f++) {
		for (int c = 1; c < cols-1; c++) {


            bgra_t *p_s = (bgra_t*) &src_matrix[f][c * 4];
			bgra_t *p_d = (bgra_t*) &dst_matrix[f][c * 4];

			int maxB = 0;
		    int maxG = 0;
		    int maxR = 0;

			for (int i = -1; i <= 1; i++) {
				for (int j = -1; j <= 1; j++) {


		            bgra_t *p_aux = (bgra_t*) &src_matrix[f+i][(c+j) * 4];
		        
		            if(maxR < p_aux->r){
		            	maxR = p_aux->r;
		            }
		        
		           	if(maxG < p_aux->g){
		            	maxG = p_aux->g;
		            }
		        
		            if(maxB < p_aux->b){
		            	maxB = p_aux->b;
		            }

				}
			}

		    float phiR;
		    float phiG;
			float phiB;
            
            if(maxR >= maxG && maxR >= maxB){
            	phiR = 1 + alpha;
            }else{
            	phiR = 1 - alpha;
            }
        
            if(maxR < maxG && maxG >= maxB){
            	phiG = 1 + alpha;
            }else{
            	phiG = 1 - alpha;
            }
        
            if(maxR < maxB && maxG < maxB){
            	phiB = 1 + alpha;
            }else{
            	phiB = 1 - alpha;
            }

			
            if(255 > phiR * p_s->r){
            	p_d->r = phiR * p_s->r;
            }else{
            	p_d->r = 255;
            }
        
            if(255 > phiG * p_s->g){
            	p_d->g = phiG * p_s->g;
            }else{
            	p_d->g = 255;
            }
        
            if(255 > phiB * p_s->b){
            	p_d->b = phiB * p_s->b;
            }else{
            	p_d->b = 255;
            }

			p_d->a = p_s->a;

		}
	}

}
