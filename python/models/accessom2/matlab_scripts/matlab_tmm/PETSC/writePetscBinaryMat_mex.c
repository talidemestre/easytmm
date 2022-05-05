/*=================================================================
 * Mex function to write sparse matrix in PETSc binary format. 
 * USAGE: writePetscBinaryMat(filename,A'), where
 *          filename: string containing name of file to write to
 *          A: sparse matrix to write out.
 * IMPORTANT: To write out matrix A you MUST pass A' (A transpose)
 *            as the 2d argument. This is because matlab stores 
 *            sparse matrices internally in column major format. 
 *            This is exactly the opposite of what is needed for 
 *            writing out a PETSc binary file.

 * this program tests to see if the host system is little-endian and if so
 * swaps the byte ordering of the data that is written into the binary file 
 * to ensure that the data file is always written in big-endian format
 *=================================================================*/

#include <stdio.h>
#include <string.h>
#include "matrix.h"
#include "mex.h"


#define LITTLE_ENDIAN_SYS   0
#define BIG_ENDIAN_SYS      1

#define DoByteSwap(x) ByteSwap((unsigned char *) &x, sizeof(x))

int machineEndianness(){
   long int i = 1;
   const char *p = (const char *) &i;
	/* check if lowest address contains the least significant byte */
   if (p[0] == 1)  
      return LITTLE_ENDIAN_SYS;
   else
      return BIG_ENDIAN_SYS;
}


void ByteSwap(unsigned char * b, int n){
   register int i = 0;
   register int j = n-1;
   unsigned char temp;
   while (i<j){
      /* swap(b[i], b[j]) */
	  temp = b[i];
	  b[i] = b[j];
	  b[j] = temp;
      i++, j--;
   }
}


/* mexFunction is the gateway routine for the MEX-file. */ 
void
mexFunction( int nlhs, mxArray *plhs[],
             int nrhs, const mxArray *prhs[] )
{
  double  *pr, *pi;
  mwIndex  *ir, *jc;
  mwSize    m,n,nnz;
  mwIndex i,j,nnzr;
  FILE *io;
  size_t one = 1;
  int MAT_FILE_COOKIE=1211216;

  /* byte swapped values */
  int *m_b, *n_b, *nnz_b, *nnzr_b, *MAT_FILE_COOKIE_b, *ir_b;
  double *pr_b;

  int mySystemType = machineEndianness();

  (void) nlhs;     /* unused parameters */
  (void) plhs;

  char *filename;
  int   buflen,status;
    
  /* Check for proper number of arguments. */
  if (nrhs != 2) 
    mexErrMsgTxt("Two inputs required.");

  /* First argument must be a string. */
  if (mxIsChar(prhs[0]) != 1)
    mexErrMsgTxt("First argument must be a string.");

  /* Second argument must be a sparse matrix. */
  if (mxIsSparse(prhs[1]) != 1)
    mexErrMsgTxt("Second argument must be a sparse matrix.");

  /* Get the length of the input string. */
  buflen = (mxGetM(prhs[0]) * mxGetN(prhs[0])) + 1;

  /* Allocate memory for input and output strings. */
  filename = mxCalloc(buflen, sizeof(char));

  /* Copy the string data from prhs[0] into a C string 
   * filename. */
  status = mxGetString(prhs[0], filename, buflen);
  if (status != 0) 
    mexWarnMsgTxt("Not enough space. String is truncated.");

  /* Get the starting positions of all four data arrays. */ 
  pr = mxGetPr(prhs[1]);
  pi = mxGetPi(prhs[1]);
  ir = mxGetIr(prhs[1]);
  jc = mxGetJc(prhs[1]);
  
  m = mxGetM(prhs[1]); /* number of rows of A' (columns of A) */
  n = mxGetN(prhs[1]); /* number of columns of A' (rows of A) */
/*   nnz = mxGetNzmax(prhs[1]); */ /* this is only an upper bound! */

/* Figure out number of nonzero elements */
  nnz=0;
  for (j=0;j<n;j++) {
    nnzr=jc[j+1]-jc[j]; /* number of nonzero elements in column j+1 of A' (row j+1 of A) */
    nnz=nnz+nnzr;
  }

  if( mySystemType == BIG_ENDIAN_SYS ){
/* 	mexPrintf("Detected big-endian system. No byte swapping will be used.\n"); */

	io = fopen(filename,"w");
	fwrite (&MAT_FILE_COOKIE,sizeof(int),one,io);   
	/*   mexPrintf("%s=%d\n","MAT_FILE_COOKIE",MAT_FILE_COOKIE); */
	fwrite (&n,sizeof(int),one,io); 
	/*   mexPrintf("%s=%d\n","n",n); */
	fwrite (&m,sizeof(int),one,io); 
	/*   mexPrintf("%s=%d\n","m",m);   */
	fwrite (&nnz,sizeof(int),one,io); 
	/*   mexPrintf("%s=%d\n","nnz",nnz);   */
	for (j=0;j<n;j++) {
		nnzr=jc[j+1]-jc[j];
		fwrite (&nnzr,sizeof(int),one,io); 
	/*     mexPrintf("%s=%d\n","nnzr",nnzr); */
	}
	fwrite (ir,sizeof(int),(size_t) nnz,io); /* row indices of of nonzero elements of A' (column indices of A) */
	fwrite (pr,sizeof(double),(size_t) nnz,io); /* actual data */
	fclose(io);
  } else {
/* 	mexPrintf("Detected little-endian system. Byte swapping will be used.\n"); */

	io = fopen(filename,"w");
	
	MAT_FILE_COOKIE_b = (int *)malloc(sizeof(int));
	*MAT_FILE_COOKIE_b = MAT_FILE_COOKIE;
	DoByteSwap(MAT_FILE_COOKIE_b[0]);
	fwrite (MAT_FILE_COOKIE_b,sizeof(int),one,io);   
	
	n_b = (int *)malloc(sizeof(int));
	*n_b = n;
	DoByteSwap(n_b[0]);
	fwrite (n_b,sizeof(int),one,io); 
	
	m_b = (int *)malloc(sizeof(int));
	*m_b = m;
	DoByteSwap(m_b[0]);
	fwrite (m_b,sizeof(int),one,io); 

	nnz_b = (int *)malloc(sizeof(int));
	*nnz_b = nnz;
	DoByteSwap(nnz_b[0]);
	fwrite (nnz_b,sizeof(int),one,io); 
	
	nnzr_b = (int *)malloc(sizeof(int));
	for (j=0;j<n;j++) {
		nnzr=jc[j+1]-jc[j];
		*nnzr_b = nnzr;
		DoByteSwap(nnzr_b[0]);
		fwrite (nnzr_b,sizeof(int),one,io); 
	}
	
	/* row indices of of nonzero elements of A' (column indices of A) */
	ir_b = (int *)malloc(sizeof(int));
	for (j=0; j<nnz; j++) {
	    *ir_b = ir[j];
		DoByteSwap(ir_b[0]);
		fwrite (ir_b,sizeof(int),one,io); 		
	}

	/* actual data */
	pr_b = (double *)malloc(sizeof(double));	
	for (j=0; j<nnz; j++) {
	    *pr_b = pr[j];   
		DoByteSwap(pr_b[0]);
    	fwrite (pr_b,sizeof(double),one,io);		
	}

	fclose(io);
 }

  return;
}
