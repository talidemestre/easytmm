function v1=grid2gcmfaces(v0,mygrid);

if nargin<2
  global mygrid;
end

[n1,n2,n3,n4,n5]=size(v0);

v0=reshape(v0,[n1*n2 n3*n4*n5]);
if nargin>1
  v1=cell(mygrid.nFaces,1);
end
for iFace=1:mygrid.nFaces;
	v1{iFace}=reshape(mygrid.gcm2faces{iFace}*v0,[mygrid.facesSize(iFace,:) n3 n4 n5]);
end;

if nargin<2    
  v1=gcmfaces(v1);
end
