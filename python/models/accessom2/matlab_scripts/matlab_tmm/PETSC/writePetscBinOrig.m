function writePetscBin(filename,X,multiVec,isBig)

% USAGE: writePetscBin(filename,X,multiVec,isBig)
% Function to write a vector or matrix to PETSc binary format
% INPUTS:
%  filename: name of file to write vector/matrix to
%  X: vector or sparse matrix
%  multiVec: If X has more than one column, multiVec=1 
%            indicates that X each column of X is a 
%            vector.
%  isBig: flag to force script to call a mex function when 
%         writing out a sparse matrix. Use this option for 
%         large matrices.
%         To use this option you must have the mex function 
%         'writePetscBinaryMat_mex.mexXXX' in your path.
% Samar Khatiwala (spk@ldeo.columbia.edu)
% This function is based on code originally written by Antti.Vanne@uku.fi

if nargin<3
  multiVec=0;
end
if isempty(multiVec)
  multiVec=0;
end

if nargin<4
  isBig=0;
end
if isempty(isBig)
  isBig=0;
end

MAT_FILE_COOKIE=1211216;
VEC_FILE_COOKIE=1211214;

if (size(X,2) == 1) || (multiVec==1) 
% X is a vector
  disp('Saving vector..');
  fid=fopen(filename,'w','ieee-be');  
  nv=size(X,2);
  for it=1:nv
    fwrite(fid,VEC_FILE_COOKIE,'int');
    fwrite(fid,size(X,1),'int');
    fwrite(fid,full(X(:,it)),'float64');
  end
  fclose(fid);
  disp(['Wrote ' num2str(nv) ' vectors'])
else 
% X is a matrix
  disp('Saving matrix');
  if ~isBig
	fid=fopen(filename,'w','ieee-be');
	[M,N]=size(X);
	fwrite(fid,MAT_FILE_COOKIE,'int');
	fwrite(fid,M,'int');
	fwrite(fid,N,'int');
	fwrite(fid,nnz(X),'int');
    [ii,jj,aa]=find(X');
% nonzeros in each row
    nnzrow=zeros(size(X,1), 1);
%    for kk = 1:M
%       nnzrow(kk) = nnz(jj==kk); % slow
%       nnzrow(kk) = length(find(jj==kk)); % faster
%    end
    nnzrow(:)=full(sum(spones(X'))'); % fastest  
    fwrite(fid,nnzrow,'int');
    fwrite(fid,ii-1,'int');
    fwrite(fid,aa,'float64');
  elseif isBig==1
    writePetscBinaryMat_mex(filename,X')
%   elseif isBig==2
%     writePetscBinaryMat_blocks_mex('X',filename)
  else
    error('Unknown value for flag isBig')
  end
end
