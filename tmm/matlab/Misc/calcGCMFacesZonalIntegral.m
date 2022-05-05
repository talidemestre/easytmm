function [Fldint,latc,area,bandpoints]=calcGCMFacesZonalIntegral(Fld,mygrid)

% Adapted from gcmfaces_calc/calc_zonmean_T.m

nl=length(mygrid.LATS);

nz=size(Fld{1},3);
nt=size(Fld{1},4);

if ~strcmp(class(Fld),'gcmfaces')
  Fld=gcmfaces(Fld);
end

Fldint=zeros([nl nz*nt]);
area=zeros([nl 1]);
latc=zeros([nl 1]);
bandpoints=zeros([nl 1]);

fld=convert2array(Fld);
n1=size(fld,1); n2=size(fld,2); 
fld=reshape(fld,[n1*n2 nz*nt]); 
rac=repmat(reshape(convert2array(mygrid.RAC),[n1*n2 1]),[1 nz*nt]);
if nz==length(mygrid.RC);
   mskC=convert2array(mygrid.mskC);
   mskC=reshape(mskC,[n1*n2*nz 1]);
   mskC=repmat(mskC,[1 nt]);
   mskC=reshape(mskC,[n1*n2 nz*nt]);
else; 
   mskC=repmat(reshape(convert2array(mygrid.mskC(:,:,1)),[n1*n2 1]),[1 nz*nt]);
end;
mskC(isnan(mskC))=0;

% masked area only:
rac(isnan(fld))=0;
mskC(isnan(fld))=0;
fld(isnan(fld))=0;

rac=rac.*mskC;
fld=fld.*rac;

for iy=1:nl
%  get list ofpoints that form a zonal band:
   mm=convert2array(mygrid.LATS_MASKS(iy).mskCedge);
   mm=find(~isnan(mm) & mm~=0);
   bandpoints(iy)=length(mm);
%  do the area weighed average along this band: 
   Fldint(iy,:)=sum(fld(mm,:),1);
   area(iy)=sum(rac(mm,1),1);
   latc(iy)=mygrid.LATS_MASKS(iy).lat;
end

Fldint=reshape(Fldint,[nl nz nt]);

% 
% % The following version gives a very 'jagged' distribution with latitude
% % Adapted from gcmfaces_calc/calc_budget_mean_zonal.m
% nl=length(mygrid.LATS);
% 
% nz=size(Fld{1},3);
% nt=size(Fld{1},4);
% 
% if ~strcmp(class(Fld),'gcmfaces')
%   Fld=gcmfaces(Fld);
% end
% 
% latc=mygrid.LATS;
% 
% Fldint=zeros([nl nz nt]);
% area=zeros([nl 1]);
% latband=zeros([nl 2]);
% bandpoints=zeros([nl 1]);
% 
% for il=1:nl
%   if il>1 & il<nl
% 	tmpMin=0.5*(mygrid.LATS(il-1)+mygrid.LATS(il));
% 	tmpMax=0.5*(mygrid.LATS(il)+mygrid.LATS(il+1));
%   elseif il==1
% 	tmpMin=-Inf;
% 	tmpMax=0.5*(mygrid.LATS(il)+mygrid.LATS(il+1));
%   elseif il==nl
% 	tmpMin=0.5*(mygrid.LATS(il-1)+mygrid.LATS(il));
% 	tmpMax=+Inf;
%   end
%   bandMask=mygrid.mskC(:,:,1).*(mygrid.YC>=tmpMin & mygrid.YC<tmpMax);
%   areaMask=mygrid.RAC.*bandMask;
%   latband(il,1)=tmpMin;
%   latband(il,2)=tmpMax;
%   area(il)=nansum(areaMask);
%   bandpoints(il)=nansum(bandMask);
%   for it=1:nt
% 	for iz=1:nz
%       Fldint(il,iz,it)=nansum(nansum(Fld(:,:,iz,it).*areaMask));
%     end
%   end  
% end
