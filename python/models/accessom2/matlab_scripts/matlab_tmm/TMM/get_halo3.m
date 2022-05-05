function [halo,inOverFlow] = get_halo3(iBox,nhorhalo,iv,nhv,nbhalo,boxnum,ixBox,iyBox,izBox,overflows,surfaceOnly)

% USAGE: halo = get_halo3(iBox,nhorhalo,iv,nhv,nbhalo,boxnum,ixBox,iyBox,izBox)
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
%  ixBox,iyBox,izBox: arrays containing (i,j,k) indices of boxes

if nargin<9
  error('ERROR: At least 9 arguments needed!')
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

% indices referenced to boxnum

if isa(iBox,'struct') % assume llc_v4 grid
% Note: boxnum contains global box numbers so returned halo will have global box numbers
  nz=size(boxnum{1},3);
  if nhv<0
	nhv=nz;
  end

  iF=iBox.facenum;
  iBoxLoc=iBox.locnum;
  iBoxGlob=iBox.globnum;
  
  ii=ixBox{iF}(iBoxLoc)+nbhalo; % note: areguments passed to this function are actually ixBoxFace etc
  jj=iyBox{iF}(iBoxLoc)+nbhalo;
  kk=izBox{iF}(iBoxLoc);

  if iv==2 & nhv~=0
% Find points above and below all points in horiz halo
	h1=boxnum{iF}(ii-nhorhalo:ii+nhorhalo,jj-nhorhalo:jj+nhorhalo,max(1,kk-nhv):min(kk+nhv,nz));
	halo=reshape(h1,[prod(size(h1)) 1]);
	ik=find(~isnan(halo));
	halo=sort(halo(ik));
  else % all other cases
	halo=[iBoxGlob];
  % First find horizontal halo
	if nhorhalo~=0
	  nhor=(2*nhorhalo+1)^2;
	  h1=boxnum{iF}(ii-nhorhalo:ii+nhorhalo,jj-nhorhalo:jj+nhorhalo,kk);
	  halo=reshape(h1,[nhor 1]);      
	end
  % Find points only above and below iBox
	if iv==1 & nhv~=0
	  hv=squeeze(boxnum{iF}(ii,jj,max(1,kk-nhv):min(kk+nhv,nz)));
	  halo=[halo;hv];
	end
	ik=find(~isnan(halo));
	halo=unique(sort(halo(ik)));
  end

else  

  nz=size(boxnum,3);
  
  if nhv<0
	nhv=nz;
  end

  ii=ixBox(iBox)+nbhalo;
  jj=iyBox(iBox)+nbhalo;
  kk=izBox(iBox);

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

end

inOverFlow=[];
if nargin>9 % overflow halos
  if ~isempty(overflows)
	if isa(iBox,'struct') % assume llc_v4 grid
	  iBox=iBox.globnum;
    end  
	inOverFlow=0;
	if nargin<11 || isempty(surfaceOnly)
	  surfaceOnly=0;
	end

    is=overflows.sourceid(iBox);
    if is~=0
	  inOverFlow=1;	
	  if surfaceOnly
		overflow_halos=overflows.source_surface_halos{is};
	  else
		overflow_halos=overflows.source_halos{is};
	  end        
	  hs=overflow_halos;
	  halo=[halo;hs];
	  halo=unique(sort(halo));
    end    
        
% 	
% % 	if surfaceOnly
% % 	  myfun=@(x)~isempty(find(x.overflow_source_surface_halos==iBox));	  
% % 	else
% % 	  myfun=@(x)~isempty(find(x.overflow_source_halos==iBox));	  
% % 	end    
% 	if surfaceOnly
% 	  myfun=@(x)~isempty(find(x.overflow_source_surface_boxes==iBox));	  
% 	else
% 	  myfun=@(x)~isempty(find(x.overflow_source_boxes==iBox));	  
% 	end    
% 
% % 	myfun=@(x)~isempty(find(x.overflow_source_surface_boxes==iBox));	  
% 
% 	in=find(cellfun(myfun,overflows));
% 	if ~isempty(in)
%       inOverFlow=1;	
%       for n=1:length(in)
%       	is=in(n);
% 		if surfaceOnly
% 		  overflow_halos=overflows{is}.overflow_source_surface_halos;
% 		else
% 		  overflow_halos=overflows{is}.overflow_source_halos;
% 		end        
% 		hs=overflow_halos;
% 	  	halo=[halo;hs];
% 	  end	
% 	  halo=unique(sort(halo));
%     end    
% 	
% %   loop over overflows to find if ib is in a source region    
% 	for n=1:length(overflows)
% 	  if surfaceOnly
% 	    myfun=@(x)~isempty(find(x.overflow_source_surface_halos==iBox));	  
% 		overflow_source=overflows{n}.overflow_source_surface_boxes;
% 		overflow_halos=overflows{n}.overflow_source_surface_halos;
% 	  else
% 		overflow_source=overflows{n}.overflow_source_boxes;
% 		overflow_halos=overflows{n}.overflow_source_halos;
% 	  end        
% %       is=find(overflow_source==iBox);
% 	  is=find(overflow_halos==iBox);
% 	  if ~isempty(is)
% %       ib is in n-th overflow: add its overflow halo      
% %         hs=overflow_halos{is};
% 		hs=overflow_halos;
% 		halo=[halo;hs];
% 		halo=unique(sort(halo));
% 		inOverFlow=1;
% % 		break
% 	  end  
% 	end
  end
end
