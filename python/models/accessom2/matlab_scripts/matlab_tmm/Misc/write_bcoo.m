function write_bcoo(A,filename)
% USAGE: write_bcoo(A,filename)
% Stores the matrix A in a binary file under the sparse COOrdinates storage 
% format. The matrix is assumed to be square.
%
% The COOrdinates storage format holds the matrix by using an UNORDERED set of 
% triplets ( i, j, a_ij ). The number of triplets corresponds to the number
% of non-zero values in the matrix. 
%
% The function first writes header data (n and nz) into a 
% text file `filename'.
% It then writes ia,ja,and ra as int32,int32,and float64 into 
% a binary file `filename.bin'. (The first nz elements of this 
% file are ia, the next nz are ja, etc.)

% Samar Khatiwala (spk@ldeo.columbia.edu)

[m,n] = size(A);
if ( m~=n ) error('matrix is not square'); end;

[ia,ja,ra] = find(A);
nz = length(ia);
if ( nz==0 ) error('empty matrix'); end;
 
fid = fopen(filename,'w') ;
if ( fid==-1 ) error('could not open file'); end;

% Header data
fprintf(fid,'%u %u\n',[n; nz]);
fprintf(fid,'%s',[filename '.bin']);  

fclose(fid);

% actual data 
fid=fopen([filename '.bin'],'wb','ieee-be'); 
fwrite(fid,ia,'int32'); 
fwrite(fid,ja,'int32');
fwrite(fid,ra,'float64');  
fclose(fid); 

