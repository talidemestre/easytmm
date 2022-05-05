function out=gcmfaces2grid(fld,mygrid)

if nargin<2
  global mygrid;
end

n1=mygrid.ioSize(1); n2=mygrid.ioSize(2);
nz=size(fld{1},3);

out=repmat(0,[n1*n2 nz]);
for iFace=1:mygrid.nFaces;
  j=mygrid.faces2gcm{iFace};
  out(j,:)=reshape(fld{iFace},[length(j) nz]);
end  

out=reshape(out,[n1 n2 nz]);
