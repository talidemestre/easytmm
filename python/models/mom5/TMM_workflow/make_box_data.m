% Script to assign box numbers and compute other data for each model grid box
% This was previously split into make_boxes.m and make_boxnum.m
% This script maps each model grid box to a single box

nhh=2 % halo for advection-diffusion scheme

% base_path=fileparts(fileparts(pwd));
gridFile='grid';
load(gridFile)
 
ii=find(bathy);
[ixBox,iyBox,izBox]=ind2sub([nx ny nz],ii);
nb=length(ixBox);

Xbox=repmat(NaN,[nb 1]);
Ybox=repmat(NaN,[nb 1]);
Zbox=repmat(NaN,[nb 1]);
Xboxnom=repmat(NaN,[nb 1]);
Yboxnom=repmat(NaN,[nb 1]);
Zboxnom=repmat(NaN,[nb 1]);
volb=repmat(NaN,[nb 1]); 

for iBox=1:nb
  [nxx,nyy]=size(x);
  if nxx==1 || nyy==1
  Xbox(iBox)=x(ixBox(iBox));
  Ybox(iBox)=y(iyBox(iBox));	  
else
  Xbox(iBox)=x(ixBox(iBox),iyBox(iBox));	
  Ybox(iBox)=y(ixBox(iBox),iyBox(iBox));	  
  end	  
  Zbox(iBox)=z(izBox(iBox));
%   Nominal positions
  Xboxnom(iBox)=Xbox(iBox);
  Yboxnom(iBox)=Ybox(iBox);
  Zboxnom(iBox)=Zbox(iBox);
  volb(iBox)=dv(ixBox(iBox),iyBox(iBox),izBox(iBox));
end

save boxes nb Xbox Ybox Zbox Xboxnom Yboxnom Zboxnom ixBox ... 
           iyBox izBox volb
  
% Now compute box number map
nbhalo=nhh;

bathy(kd)=NaN;

boxnum=repmat(NaN,[nx+2*nbhalo ny+2*nbhalo nz]);
tmp=bathy;

for ib=1:nb
tmp(ixBox(ib),iyBox(ib),izBox(ib))=ib;
end

boxnum(nbhalo+1:nx+nbhalo,nbhalo+1:ny+nbhalo,:)=tmp;

% Assume only (possibly) periodic in x, and don't try to be clever!!
boxnum(1:nbhalo,nbhalo+1:end-nbhalo,:)=tmp(end-nbhalo+1:end,:,:);
boxnum(end-nbhalo+1:end,nbhalo+1:end-nbhalo,:)=tmp(1:nbhalo,:,:);

save boxnum boxnum nbhalo nhh


