
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
	int maxB_col2 = 0;
	int maxG_col2 = 0;
	int maxR_col2 = 0;
    int maxB_col1 = 0;
	int maxG_col1 = 0;
	int maxR_col1 = 0;
	int maxB_col0 = 0;
	int maxG_col0 = 0;
	int maxR_col0 = 0;

	for (int f = 1; f < filas-1; f++) {
		for (int c = 1; c < cols-1; c++) {


            bgra_t *p_s = (bgra_t*) &src_matrix[f][c * 4];
			bgra_t *p_d = (bgra_t*) &dst_matrix[f][c * 4];

			int maxB = 0;
		    int maxG = 0;
		    int maxR = 0;

		    int j = -1;
		    // maximo de la primera columna
		    if (c == 1){
		    	for (int i = -1; i <= 1; i++){
		        	bgra_t *p_aux = (bgra_t*) &src_matrix[f+i][(c+j) * 4];
		        
		            if(maxR < p_aux->r)
		            {
		            	maxR = p_aux->r;
		            	maxR_col0 = maxR;
		            }
		        
		           	if(maxG < p_aux->g)
		           	{
		            	maxG = p_aux->g;
		            	maxG_col0 = maxG;
		            }
		        
		            if(maxB < p_aux->b)
		            {
		            	maxB = p_aux->b;
		            	maxR_col0 = maxR;
		            }
		        }    
		    }
		    j = 0;
		    // maximo segunda columna
		    if (c == 1){
		    	for (int i = -1; i <= 1; i++){
		        	bgra_t *p_aux = (bgra_t*) &src_matrix[f+i][(c+j) * 4];
		        
		            if (maxR < p_aux->r)
					 	maxR = p_aux->r;

					if (maxR_col1 < p_aux->r)
		            	maxR_col1 = p_aux->r;	            
		        
		           	if (maxG < p_aux->g)
		            	maxG = p_aux->g;

		            if (maxG_col1 < p_aux->g)
		            	maxG_col1 = p_aux->g;
		        
		            if (maxB < p_aux->b)
		            	maxB = p_aux->b;

		            if (maxB_col1 < p_aux->b)
		            	maxB_col1 = p_aux->b;
		        }    
		    }
		    j = 1;
		    // maximo tercera columna
		    for (int i = -1; i <= 1; i++){
		            bgra_t *p_aux = (bgra_t*) &src_matrix[f+i][(c+j) * 4];
		        
		            if (maxR < p_aux->r)
		            	maxR = p_aux->r;

		            if (maxR_col2 < p_aux->r)
		            	maxR_col2 = p_aux->r;	            
		        
		           	if (maxG < p_aux->g)
		            	maxG = p_aux->g;

		            if (maxG_col2 < p_aux->g)
		            	maxG_col2 = p_aux->g;
		            
		            if (maxB < p_aux->b)
		            	maxB = p_aux->b;

		            if (maxB_col2 < p_aux->b)
		            	maxB_col2 = p_aux->b;
		    }

		    if (c > 1){
		    	if (maxB_col2 < maxB_col0)
		    	{
		    		if (maxB_col0 > maxB_col1)
		    			maxB = maxB_col0;
		    		else
		    			maxB = maxB_col1;
		    	} else
		    	{
		    		if (maxB_col2 < maxB_col1)
		    			maxB = maxB_col1;
		    		else
		    			maxB = maxB_col2;
		    	}
		    	if (maxG_col2 < maxG_col0)
		    	{
		    		if (maxG_col0 > maxG_col1)
		    			maxG = maxG_col0;
		    		else
		    			maxG = maxG_col1;
		    	} else
		    	{
		    		if (maxG_col2 < maxG_col1)
		    			maxG = maxG_col1;
		    		else
		    			maxG = maxG_col2;
		    	}
		    	if (maxR_col2 < maxR_col0)
		    	{
		    		if (maxR_col0 > maxR_col1)
		    			maxR = maxR_col0;
		    		else
		    			maxR = maxR_col1;
		    	} else
		    	{
		    		if (maxR_col2 < maxR_col1)
		    			maxR = maxR_col1;
		    		else
		    			maxR = maxR_col2;
		    	}

		    	//Ya obtuve los maximos, corro los valores para la proxima iteracion
		    	maxB_col0 = maxB_col1;
		    	maxG_col0 = maxG_col1;
		    	maxR_col0 = maxR_col1;
		    	maxB_col1 = maxB_col2;
		    	maxG_col1 = maxG_col2;
		    	maxR_col1 = maxG_col2;
		    	maxB_col2 = 0;
		    	maxG_col2 = 0;
		    	maxR_col2 = 0;
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
		maxB_col0 = 0;
		maxG_col0 = 0;
		maxR_col0 = 0;
		maxB_col1 = 0;
		maxG_col1 = 0;
		maxR_col1 = 0;
		maxB_col2 = 0;
		maxG_col2 = 0;
		maxR_col2 = 0;
	}

}

