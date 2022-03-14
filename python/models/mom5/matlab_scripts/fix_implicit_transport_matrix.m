% script to "correct" implicit transport matrix

inFile='matrix_nocorrection_annualmean.mat';
outFile='matrix_corrected_implicit.mat';

load(inFile,'Aimpms')
nm=length(Aimpms);

% for im=1:nm
%   [in,jn]=find(Aimpms{im}<0); % find negative values
%   dd=spdiags(Aimpms{im},0); % diagonal
% %  s=sum(Aimpms{im},2);
%   for k=1:length(in) % loop over diagonam values
% 	i=in(k);
% 	j=jn(k);
% 	an=Aimpms{im}(i,j);
% 	dd(i)=dd(i)+an; % add this to the diagonal
% 	Aimpms{im}(i,j)=0; % set negative to 0
%   end
%   Aimpms{im}=spdiags(dd,0,Aimpms{im});
% end

for im=1:nm
  [ii,jj,aa]=find(Aimpms(im));
  dd=spdiags(Aimpms(im),0); % diagonal
  kn=find(aa<0);
  in=ii(kn);
  jn=jj(kn);
  an=aa(kn);
  % this step CANNOT be vectorized since for a given row there 
  % might be multiple negative values  
  for k=1:length(in) 
    dd(in(k))=dd(in(k))+an(k);
  end
%   aa(kn)=0; % set negatives to zero
  aa(kn)=1e-15;
  k=find(aa~=0); % pick out nonzeros
  Aimpms(im)=sparse(ii(k),jj(k),aa(k),size(Aimpms(im),1),size(Aimpms(im),2)); % reassemble matrix
  Aimpms(im)=spdiags(dd,0,Aimpms(im)); % insert new diagonal
end

% save(outFile,'Aimpms')
load(inFile,'Aexpms')
save(outFile,'-v7.3','Aexpms','Aimpms')

