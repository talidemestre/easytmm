/* original author ->  Christian James Walder */
/* some changes by Sergey Voronin */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "matrix.h"
#include "mex.h"


#define MALLOC mxMalloc
#define CALLOC mxCalloc
#define REALLOC mxRealloc
#define FREE mxFree
#define PRINTF mexPrintf


/* define MySparse struct */
typedef struct{
    mxArray * theMat;
    mwIndex *ir, *jc;
    double *pr;
    mwSize m, n, nzmax;
} MySparse;


/* define some global vars */
int *sort_data;
int num_times_resized = 0;


/* initialize sparse mat */
void initMySparse(MySparse *sparse_mat, mwSize the_m, mwSize the_n, mwSize the_nzmax){
/*     PRINTF("in initMySparse\n"); */
    int j;
    sparse_mat->m = the_m;
    sparse_mat->n = the_n;
    sparse_mat->nzmax = the_nzmax;
    sparse_mat->theMat = mxCreateSparse(the_m, the_n, the_nzmax, mxREAL);

    sparse_mat->ir = mxGetIr(sparse_mat->theMat);
    sparse_mat->jc = mxGetJc(sparse_mat->theMat);
    sparse_mat->pr = mxGetPr(sparse_mat->theMat);

    for(j = 0; j <= sparse_mat->n; j++){
        sparse_mat->jc[j] = 0;
    }
}


/* destroy sparse mat */
void destroyMySparse(MySparse *sparse_mat){
/*     PRINTF("in destroyMySparse\n"); */
    mxDestroyArray(sparse_mat->theMat);
}



/* resize sparse mat */
bool resizeMySparse(MySparse *sparse_mat, int new_size) {
     int newnzmax;
     if(new_size > (sparse_mat->nzmax-1)){
/*          PRINTF("in resizeMySparse\n"); */
         num_times_resized++;
         
         newnzmax = 2*new_size;

         mxSetNzmax(sparse_mat->theMat, newnzmax);
         sparse_mat->nzmax = newnzmax;
         mxSetPr(sparse_mat->theMat, REALLOC(sparse_mat->pr, newnzmax*sizeof(double)));
         mxSetIr(sparse_mat->theMat, REALLOC(sparse_mat->ir, newnzmax*sizeof(mwIndex)));

         /* make sure to reinit pointers after Realloc call */
         sparse_mat->pr = mxGetPr(sparse_mat->theMat);
         sparse_mat->ir = mxGetIr(sparse_mat->theMat);
         
         return true;
     }
     return false;
}


/* convert sparse mat to matlab form */
mxArray * convertToMatlab(MySparse *sparse_mat) {
/*      PRINTF("in convertToMatlab\n"); */
     return sparse_mat->theMat;
}


int mycompare(const void * a, const void * b) {
     return (int) (*(sort_data+ *((unsigned int *)a)) - *(sort_data+ *((unsigned int *)b)));
}


/* gateway to mex routine */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const  
mxArray*prhs[]) {
     double *a, *b, *c_copy, scal;
     mxArray *A, *B, *C;
     int *ia, *ja, *ib, *jb, *ic_copy;
     int nzmax, nrow, ncol, len, ii, jj, ka, kb, icol, ipos, k, *jw,  
sort_size, max_sort_size, i;
     unsigned int *sorti;

     if ((nrhs < 2)|(nlhs!=1)) {
         PRINTF("mex_amub.cpp: bad args\nusage: mex_mymult (sparse  matrix multiplication) usage: real(A) * real(B) = mex_amub(A,B,nnz);\n");
         return;
     }

     if (!mxIsSparse(prhs[0]) | !mxIsSparse(prhs[1])) {
         PRINTF("mex_amub.cpp: A and B must be sparse, returning");
         return;
     }

     A = (mxArray *) prhs[0];
     B = (mxArray *) prhs[1];
     nzmax = 10;
     if (nrhs == 3) {
         nzmax = ((int) *mxGetPr(prhs[2])+10) > nzmax ? ((int)  
*mxGetPr(prhs[2])+10) : nzmax;
     }
/*      PRINTF("using nzmax = %d\n", nzmax); */

     nrow = mxGetM(A);
     ncol = mxGetN(B);

     if (mxGetN(A)!=mxGetM(B)) {
         PRINTF("mex_amub.cpp: size(A,2) ~= size(B,1), returning\n");
         return;
     }

     MySparse *AB;
     AB = (MySparse *)CALLOC(1,sizeof(MySparse));
     initMySparse(AB, nrow, ncol, nzmax);

     ja = mxGetJc(A);
     ia = mxGetIr(A);
     a = mxGetPr(A);

     jb = mxGetJc(B);
     ib = mxGetIr(B);
     b = mxGetPr(B);

     len = 0;
     AB->jc[0] = 0;
     jw = (int *) MALLOC(nrow * sizeof(int));
     max_sort_size = 0;
     for (jj = 0; jj < nrow; jj++) {
         jw[jj] = -1;
     }
     for (jj = 0; jj < ncol; jj++) {
         for (kb = jb[jj]; kb < jb[jj+1]; kb++) {
             scal = b[kb];
             ii = ib[kb];
             for (ka = ja[ii]; ka < ja[ii+1]; ka++) {
                 icol = ia[ka];
                 ipos = jw[icol];
                 if (ipos == -1) {
                     resizeMySparse(AB, len+1);
                     AB->ir[len] = icol;
                     jw[icol] = len;
                     AB->pr[len] = scal * a[ka];
                     len++;
                 } else {
                     AB->pr[ipos] += scal * a[ka];
                 }
             }
         }
         for (k = AB->jc[jj]; k < len; k++) {
             jw[AB->ir[k]] = -1;
         }
         AB->jc[jj+1] = len;

         sort_size = AB->jc[jj+1]-AB->jc[jj];
         if (sort_size > 1) {
             if (sort_size > max_sort_size) {
                 if (max_sort_size > 0) {
                     FREE(sorti);
                     FREE(ic_copy);
                     FREE(c_copy);
                 }
                 max_sort_size = sort_size * 2;
                 sorti = (unsigned int *) MALLOC(max_sort_size*sizeof
(unsigned int));
                 ic_copy = (int *) MALLOC(max_sort_size*sizeof(int));
                 c_copy = (double *) MALLOC(max_sort_size*sizeof
(double));
             }
             for (k = 0; k < sort_size; k++) {
                 sorti[k] = k;
                 ic_copy[k] = AB->ir[AB->jc[jj]+k];
                 c_copy[k] = AB->pr[AB->jc[jj]+k];
             }
             sort_data = AB->ir + AB->jc[jj];
             qsort(sorti, sort_size, sizeof(int), mycompare);
             for (k = 0; k < sort_size; k++) {
                 AB->ir[k+AB->jc[jj]] = ic_copy[sorti[k]];
                 AB->pr[k+AB->jc[jj]] = c_copy[sorti[k]];
             }
         }
     }


/*      PRINTF("num resizes = %d\n", num_times_resized); */
/*      PRINTF("final nzmax = %d\n", AB->nzmax); */
     num_times_resized = 0;

     plhs[0] = convertToMatlab(AB);

     /* destroyMySparse(AB); */
     /* FREE(AB); */

     FREE(jw);
     if (max_sort_size > 0) {
         FREE(sorti);
         FREE(ic_copy);
         FREE(c_copy);
     }
     
    return;
}


