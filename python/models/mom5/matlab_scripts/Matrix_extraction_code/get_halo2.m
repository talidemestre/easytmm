function halo = get_halo2(iBox,nhorhalo,iv,nhv,nbhalo,boxnum,ixb,iyb,izb)

% USAGE: halo = get_halo2(iBox,nhorhalo,iv,nhv,nbhalo,boxnum,ixb,iyb,izb)
% Function to compute halo around box iBox. 
% INPUTS:
%  nhorhalo: is size of the halo in the horizontal
%  nhv: is size of the halo in the vertical. nhv<0 will extract 
%       ALL adjacent points in the horizontal or vertical.
%  iv:  integer to select whether to return points above/below iBox 
%       only or all horizontal points in the halo of iBox.
%       iv=1: find points only above and below iBox
%       iv=2: find points above and below all points in horizontal halo
%  nbhalo: size of stencil (halo) used in the matrix computation
%  boxnum: array containing box numbers
%  ixb,iyb,izb: cell arrays containing (i,j,k) indices of boxes

if nargin~=9
  error('ERROR: 9 arguments needed')
end

% if nargin<5
%   load boxnum boxnum nbhalo
%   load boxes ixb iyb izb
% end

if nhorhalo<0
  error('ERROR: nhorhalo must be >=0')
end
if nhorhalo>nbhalo
  error('ERROR: nhorhalo must be <= nbhalo')
end  

nz=size(boxnum,3);
% nbhalo=(size(boxnum,2)-nx)/2;

if nhv<0
  nhv=nz;
end

% indices referenced to boxnum
ii=ixb{iBox}+nbhalo;
jj=iyb{iBox}+nbhalo;
kk=izb{iBox};

if iv==2 & nhv~=0
% Find points above and below all points in horiz halo
  h1=boxnum(ii-nhorhalo:ii+nhorhalo,jj-nhorhalo:jj+nhorhalo,max(1,kk-nhv):min(kk+nhv,nz));
  halo=reshape(h1,[prod(size(h1)) 1]);
  ik=find(~isnan(halo));
  halo=sort(halo(ik));
else % all other cases
  halo=[iBox];
  % First find horizontal halo
  if nhorhalo~=0
    nhor=(2*nhorhalo+1)^2;
    h1=boxnum(ii-nhorhalo:ii+nhorhalo,jj-nhorhalo:jj+nhorhalo,kk);
    halo=reshape(h1,[nhor 1]);      
  end
  % Find points only above and below iBox
  if iv==1 & nhv~=0
    hv=squeeze(boxnum(ii,jj,max(1,kk-nhv):min(kk+nhv,nz)));
    halo=[halo;hv];
  end
  ik=find(~isnan(halo));
  halo=unique(sort(halo(ik)));
end

