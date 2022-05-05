function A = readPetscBinMat(filename)

% USAGE: A = readPetscBinMat(filename)
% read PETSc binary format matrix from file
% This function does NOT support complex numbers

% Samar Khatiwala (spk@ldeo.columbia.edu)
% This function is based on code written by Antti.Vanne@uku.fi

MAT_FILE_COOKIE=1211216;

fid=fopen(filename,'r','ieee-be');

cookie=fread(fid,1,'int');
if (cookie ~= MAT_FILE_COOKIE)
  error('ERROR: Not a petsc matrix file');
end

M=fread(fid,1,'int');
N=fread(fid,1,'int');
totalNnz=fread(fid,1,'int');
nnzrows=fread(fid,M,'int');
colInds=fread(fid,totalNnz,'int');
data=fread(fid,totalNnz,'double');
fclose(fid);

ci=1; 
rowInds=zeros(totalNnz,1);
for row=1:M
  if (nnzrows(row)==0) % no data in this row
    continue
  end
  rowInds(ci:ci+nnzrows(row)-1)=row*ones(nnzrows(row),1);
  ci=ci+nnzrows(row); 
end
A=sparse(rowInds,colInds+1,data); 
