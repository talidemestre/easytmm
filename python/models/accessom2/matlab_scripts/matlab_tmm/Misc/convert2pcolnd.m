function [X,Y,Fldplot]=convert2pcolnd(Fld,mygrid)

% Function to convert n-dimensional MITgcm gcmfaces field (Fld) to plotting-friend 
% array. This function is simply a wrapper to call convert2pcol multiple times for 
% each horizontal and time slice of a gcmfaces field.

nz=size(Fld{1},3);
nt=size(Fld{1},4);

if ~strcmp(class(Fld),'gcmfaces')
  Fld=gcmfaces(Fld);
end

[X,Y,Fldplot]=convert2pcol(mygrid.XC,mygrid.YC,Fld);
[n1,n2]=size(Fldplot);
Fldplot=zeros([n1 n2 nz nt]);

for it=1:nt
  for iz=1:nz
	[X,Y,Fldplot(:,:,iz,it)]=convert2pcol(mygrid.XC,mygrid.YC,Fld(:,:,iz,it));
  end
end
Fldplot=squeeze(Fldplot);
