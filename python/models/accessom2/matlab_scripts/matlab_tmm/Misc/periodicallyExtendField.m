function [fldnew,xnew]=periodicallyExtendField(fld,x)

% periodically extend in first dimension
[nx,ny,nz]=size(fld);
dx=x(2)-x(1);
xnew=[x(1)-dx;x;x(end)+dx]; 

fldnew=repmat(0,[nx+2 ny nz]);
fldnew(2:end-1,:,:)=fld;
for iz=1:nz
  fldnew(:,:,iz)=[fld(end,:,iz);fld(:,:,iz);fld(1,:,iz)];
end
