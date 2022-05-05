function [varargout]=calc_boxmean_T(fld,varargin);
%purpose: compute a weighted average of a field
%
%inputs:
%	(1) fld is a 3D (or 2D) field in gcmfaces format at the grid 
%		center where missing values are assigned a NaN	
%	(2a) 'LATS',LATS is a line vector of latitutde interval edges
%	(2b) 'LONS',LONS is a line vector of longitutde interval edges
%	(3a) 'weights',weights is a weights field. If it is not specified
%		then we use the grid cell volume in the weighted average.
%               If specifying 'weights' you likely want to set it to 0 on land.
%	(3b) 'level',kk is a specification of the vertical level. This
%		is only used when fld is a 2D field to define weights
%outputs:
%	(1) FLD is the field/vector/value of the weighted mean. It's 
%		size depends on the input size
%	(2) W is the weights for each element of FLD. It can be used to simply
%		compute the global weighted average as nansum(W(:).*FLD(:))/nansum(W(:))
%usage:	
%	input 2a and/or 2b is necessary
%       input 3a or 3b is optional, and are mutually exclusive, except if 
%		fld is 2D when input 3b is needed and 3a is excluded 
%	output 2 is optional

%by assumption: grid_load is done
global mygrid;

%get arguments
for ii=1:(nargin-1)/2;
	tmp1=varargin{2*ii-1}; eval([tmp1 '=varargin{2*ii};']);
end;

%initialize output:
n3=max(size(fld.f1,3),1); n4=max(size(fld.f1,4),1);

%test inputs/outputs consistency:
tmp1=~isempty(whos('LONS'))+~isempty(whos('LATS'));
if tmp1~=1&tmp1~=2; error('wrong input specification'); end;
tmp1=~isempty(whos('weights'))+~isempty(whos('level'));
if tmp1>1; error('wrong input specification'); end;
if nargout>2; error('wrong output specification'); end
if n3==1&isempty(whos('level'))&isempty(whos('weights')); error('wrong input specification'); end;

%prepare output etc.:
if ~isempty(whos('LONS'))&~isempty(whos('LATS')); %use complex
valranges=LONS'*ones(size(LATS))+i*(ones(size(LONS))'*LATS); 
elseif ~isempty(whos('LONS'));
valranges=LONS'; 
else;
valranges=i*LATS;
end;
nnranges=size(valranges);
nnout=max(size(valranges)-1,[1 1]);
%
FLD=NaN*ones([nnout n3 n4]);
W=NaN*ones([nnout n3 n4]);

%select weights for average:
if isempty(whos('weights'))&isempty(whos('level'));
  weights=mygrid.hFacC.*mk3D(mygrid.RAC,mygrid.hFacC);
  weights=weights.*mk3D(mygrid.DRF,mygrid.hFacC);
elseif ~isempty(whos('level'));
  weights=mygrid.hFacC(:,:,level).*mygrid.RAC*mygrid.DRF(level);
end;

%multiply with data mask:
msk=repmat(1*~isnan(fld),[1 1 n3 n4]); 
weights=weights.*msk;
%switch to 2D array to speed up computation:
fld=convert2array(fld);
n1=size(fld,1); n2=size(fld,2);
fld=reshape(fld,n1*n2,n3*n4);
%same for the weights:
weights=reshape(convert2array(weights),n1*n2*n3,1)*ones(1,n4);
weights=reshape(weights,n1*n2,n3*n4);
%multiply one with the other
fld=fld.*weights;
%remove data mask
fld(isnan(fld))=0;

lonvec=reshape(convert2array(mygrid.XC),n1*n2,1);
latvec=reshape(convert2array(mygrid.YC),n1*n2,1);

for ix=1:nnout(1);
for iy=1:nnout(2);

   %get list ofpoints that form a zonal band:
   if nnout(1)==1;
     mm=find(latvec>=imag(valranges(ix,iy))&latvec<imag(valranges(ix,iy+1)));
   elseif nnout(2)==1;
     mm=find(lonvec>=real(valranges(ix,iy))&lonvec<real(valranges(ix+1,iy)));
   else;
     mm=find(latvec>=imag(valranges(ix,iy))&latvec<imag(valranges(ix,iy+1))...
            &lonvec>=real(valranges(ix,iy))&lonvec<real(valranges(ix+1,iy)));
   end;

   %do the area weighed average along this band: 
   tmp1=sum(fld(mm,:),1); 
   tmp2=sum(weights(mm,:),1); 
   tmp2(tmp2==0)=NaN;
   tmp1=tmp1./tmp2;

   %store:
   FLD(ix,iy,:,:)=reshape(tmp1,n3,n4);
   W(ix,iy,:,:)=reshape(tmp2,n3,n4);

end; 
end;

if nargout==2;
  varargout={FLD,W};
elseif nargout==1;
  varargout={FLD};
else;
  varargout={};
end;



