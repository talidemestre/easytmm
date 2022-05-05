function Am=cellmean(A)

% USAGE: Am = cellmean(A) 
% Function to compute mean over cell arrays. 
% The output, Am, has the same size as the elements of A

% Samar Khatiwala (spk@ldeo.columbia.edu)

if ~iscell(A)
  error('Input should be a cell object')
end
nc=length(A);
if nc==1
  Am=A{1};
  return
end  
if issparse(A{1})
   if ndims(A{1})>2
      error('Sparse matrix must be 2-d')
   end
   m=size(A{1},1);
   n=size(A{1},2);
   Am=sparse(m,n);
else
   Am=zeros(size(A{1}));
end
for i=1:nc
  Am=Am+A{i};
end
Am=Am/nc;
