function [secX,secY,secFLD]=gcmfaces_section(lons,lats,fld,varargin);
%purpose: extract a great circle section (defined by two points) from a field
%         or a latitude circle (defined by one latitude)
%
%inputs:	lons/lats are the longitude/latitude vector
%		fld is the gcmfaces field (can incl. depth/time dimensions)
%optional:      sortByLon to sort point by longitude (default = 0 -> sort by latgitude) 
%outputs:	secX/secY is the vector of grid points longitude/latitude
%		secFLD is the vector/matrix of grid point values (from fld)

if nargin>3; sortByLon=varargin{1}; else; sortByLon=0; end;

global mygrid;

if length(lats)==2;
  line_cur=gcmfaces_lines_transp(lons,lats,{'tmp'});
elseif length(lats)==1;
  tmp1=abs(mygrid.LATS-lats);
  tmp2=find(tmp1==min(tmp1));
  tmp2=tmp2(1);
  line_cur=mygrid.LATS_MASKS(tmp2);
else;
  error('wrong specification of lons,lats');
end;
secP=find(line_cur.mskCedge==1);
secN=length(secP);

%lon/lat vectors:
secX=zeros(secN,1); secY=zeros(secN,1); 
%sections:
n3=max(size(fld{1},3),1); n4=max(size(fld{1},4),1); secFLD=zeros(secN,n3,n4);
%counter:
ii0=0; 
for ff=1:secP.nFaces;
  tmp0=secP{ff}; [tmpI,tmpJ]=ind2sub(size(mygrid.XC{ff}),tmp0);
  tmp1=mygrid.XC{ff}; for ii=1:length(tmpI); secX(ii+ii0)=tmp1(tmpI(ii),tmpJ(ii)); end;
  tmp1=mygrid.YC{ff}; for ii=1:length(tmpI); secY(ii+ii0)=tmp1(tmpI(ii),tmpJ(ii)); end;
  tmp1=fld{ff}; for ii=1:length(tmpI); secFLD(ii+ii0,:,:)=squeeze(tmp1(tmpI(ii),tmpJ(ii),:,:)); end;
  ii0=ii0+length(tmpI);
end;

%sort according to increasing latitude or longitude:
if sortByLon; 
  [tmp1,ii]=sort(secX); %sort according to increasing longitude
else;
  [tmp1,ii]=sort(secY); %sort according to increasing latitude
end;
secX=secX(ii); secY=secY(ii); secFLD=secFLD(ii,:,:);

