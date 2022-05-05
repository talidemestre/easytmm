function writePetscBin(filename,X,multiVec,isBig,numBlocks,displayMsg)

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
%  numBlocks: 
%  displayMsg: flag to indicate whether to be verbose or not. Default is to 
%              write out diagnostic information.
% Samar Khatiwala (spk@ldeo.columbia.edu)
% This function is based on code originally written by Antti.Vanne@uku.fi

if nargin<2
  error('ERROR: at least 2 input arguments needed')
end

if nargin<3 % default is single vector or matrix
  multiVec=0;
else
  if isempty(multiVec)
    multiVec=0;
  end
end

if nargin<4 % default is to use m-code to generate sparse layout information for matrix
  isBig=0;
else  
  if isempty(isBig)
    isBig=0;
  end
end

if nargin<5 % default number of blocks (only used if isBig=3)
  numBlocks=20;
else
  if isempty(numBlocks)
    numBlocks=20;
  end
end

if nargin<6 % default is to be verbose
  displayMsg=1;
else
  if isempty(displayMsg)
    displayMsg=1;
  end
end

MAT_FILE_COOKIE=1211216;
VEC_FILE_COOKIE=1211214;

if (size(X,2) == 1) || (multiVec==1) 
% X is a vector
  if displayMsg
    disp('Saving vector..');
  end
  fid=fopen(filename,'w','ieee-be');  
  nv=size(X,2);
  for it=1:nv
    fwrite(fid,VEC_FILE_COOKIE,'int');
    fwrite(fid,size(X,1),'int');
    fwrite(fid,full(X(:,it)),'float64');
  end
  fclose(fid);
  if displayMsg
    disp(['Wrote ' num2str(nv) ' vectors'])
  end
else 
% X is a matrix
  if displayMsg
    disp('Saving matrix');
  end
  if ~isBig
	fid=fopen(filename,'w','ieee-be');
	[M,N]=size(X);
	fwrite(fid,MAT_FILE_COOKIE,'int');
	fwrite(fid,M,'int');
	fwrite(fid,N,'int');
	fwrite(fid,nnz(X),'int');
	Xt=X';
    [ii,jj,aa]=find(Xt);
% nonzeros in each row
    nnzrow=zeros(M,1);
%    for kk = 1:M
%       nnzrow(kk) = nnz(jj==kk); % slow
%       nnzrow(kk) = length(find(jj==kk)); % faster
%    end
    nnzrow(:)=full(sum(spones(Xt))'); % fastest (but makes a copy of Xt)
    fwrite(fid,nnzrow,'int');
    fwrite(fid,ii-1,'int');
    fwrite(fid,aa,'float64');
  elseif isBig==1
    writePetscBinaryMat_mex(filename,X')  
%     writePetscBinaryMatrixTranspose_mex(filename,X')  
  elseif isBig==2
%     writePetscBinaryMat_notsp_noeval('X',filename,20)
    writePetscBinaryMat_notsp('X',filename,20)
  elseif isBig==3
    [M,N]=size(X);
    rows_per_block = fix(M/numBlocks);

	fid=fopen(filename,'w','ieee-be');
	fwrite(fid,MAT_FILE_COOKIE,'int');
	fwrite(fid,M,'int');
	fwrite(fid,N,'int');
	fwrite(fid,nnz(X),'int');
    fclose(fid);

%     Xblock=sparse(N,rows_per_block);

    id=abs(round(randn*1000000));
    f1=['temp_nnzr_data_' int2str(id)];
    f2=['temp_ir_data_' int2str(id)];
    f3=['temp_pr_data_' int2str(id)];

    start_row = 1;
    end_row = 1;
    iter_count = 0;
    break_out = 0;    
    while (end_row <= M && ~break_out)
	  iter_count=iter_count+1;	  
	  end_row = start_row + rows_per_block - 1;
	  if (end_row > M && start_row <= M)
		end_row = M;
		break_out = 1;
	  elseif (end_row > M && start_row > M)
		break;
	  end
	  msize=end_row-start_row+1;
% 	  [start_row end_row msize]
% 	  Xblock(:,1:msize)=X(start_row:end_row,:)';					  
	  writePetscBinaryMatrixBlocks_mex(f1,f2,f3,X(start_row:end_row,:)');
	  start_row = end_row + 1;
    end
    eval(['!cat ' f1 ' ' f2 ' ' f3 ' >> ' filename])
    eval(['!rm -f ' f1 ' ' f2 ' ' f3])
  else
    error('Unknown value for flag isBig')
  end
end
