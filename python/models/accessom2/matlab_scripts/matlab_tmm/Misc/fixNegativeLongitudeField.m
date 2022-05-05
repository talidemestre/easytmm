function [fldnew,xnew]=fixNegativeLongitudeField(fld,x)

[nx,ny,nt]=size(fld);
xnew=x;
ix1=find(x>=0);
ix2=find(x<0);
xnew(1:length(ix1))=x(ix1);
xnew(length(ix1)+1:end)=x(ix2);
xnew(xnew<0)=xnew(xnew<0)+360;

fldnew=[];
if ~isempty(fld)
  fldnew=zeros(size(fld));
  for it=1:nt
	fldnew(1:length(ix1),:,it)=fld(ix1,:,it);
	fldnew(length(ix1)+1:end,:,it)=fld(ix2,:,it);
  end
end
  
