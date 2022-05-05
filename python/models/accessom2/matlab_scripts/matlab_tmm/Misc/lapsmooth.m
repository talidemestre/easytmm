function S=lapsmooth(V,cyc);

% Hack to do a laplacian smoothing. 
% S=lapsmooth(V,cyc) will smooth V in the FIRST dimension. 
% if cyc=1, the field is treated as periodic in that direction.
% To smooth other directions, permute V before passing it to 
% lapsmooth.

% Samar Khatiwala (spk@ldeo.columbia.edu)

if nargin<2
   cyc=1;
end
[nx,ny,nz,nt]=size(V);
L=repmat([1 2 1]',[1 ny]);
S=V;
for t=1:nt
   for k=1:nz
      if cyc==1
         tmp=[V(end,:,k,t);V(:,:,k,t);V(1,:,k,t)];
         for i=1:nx
             S(i,:,k,t)=sum(L.*tmp(i:i+2,:),1)/4;
         end
      else
         for i=2:nx-1
             S(i,:,k,t)=sum(L.*V(i-1:i+1,:,k,t),1)/4;
         end
      end
   end
end
      
