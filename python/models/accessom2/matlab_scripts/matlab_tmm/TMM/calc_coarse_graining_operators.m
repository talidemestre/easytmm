function cgFileSuffix=calc_coarse_graining_operators(ncx,ncy,ncz,r0,gridFile,boxFileBase,maskFile,cgFileSuffix)

% Script to compute coarse-graining operators. This script will also coarse grain grid and 
% box arrays.

% Note: in the CG model, There are at least 2 ways to define da and dz depending 
% on how the boxes are reshaped. 
% (1): all boxes in a vertical column have the same area, and 
% dz is defined equal to (volume of box)/(area of box). 
% Thus dv(ix,iy,:) = constant*dz(ix,iy,:). With this definition, 
% the vertical distribution of dz will be rather uneven 
% in the horizontal, and deviate considerably from the nominal 
% distribution, dznom. (Deeper boxes might become too thin, 
% for instance.)
% for ibc=1:nbc
%   bathy(ixBox(ibc),iyBox(ibc),izBox(ibc))=1;
%   dv(ixBox(ibc),iyBox(ibc),izBox(ibc))=volb(ibc);
%   if izBox(ibc)==1 % surface box
%     I=find(Beta(ibc,:))'; % boxes contributing to this coarse-grained surface box
%     da(ixBox(ibc),iyBox(ibc),:)=sum(areab(I));
%   end
% end
% da=da.*bathy;
% kd=find(bathy==0); % dry points
% kw=find(bathy==1); % wet points
% dz(kw)=dv(kw)./da(kw);
% end (1)
% (2): the vertical distribution of dz is set to the zonally-
% averaged profile. (This should not deviate too much from the 
% profile of NOMINAL dz (dznom) of the full model.) Since the 
% volume of each box must remain unchanged, each box in a vertical 
% column will therefor have a different % area. (Area should 
% decrease with depth.) Remember to account for this when computing 
% vertical fluxes and tendencies due to vertical flux convergence.
% for ibc=1:nbc
%   bathy(ixBox(ibc),iyBox(ibc),izBox(ibc))=1;
%   dv(ixBox(ibc),iyBox(ibc),izBox(ibc))=volb(ibc);
%   I=find(Beta(ibc,:))'; % boxes contributing to this coarse-grained box
%   dz(ixBox(ibc),iyBox(ibc),izBox(ibc))=mean(dzb(I));
% end
% kd=find(bathy==0); % dry points
% kw=find(bathy==1); % wet points
% da(kw)=dv(kw)./dz(kw);
% end (2)    

if nargin<6
  error('ERROR: At least 6 arguments needed')
end
if nargin<7
  maskFile=[];
end
if nargin<8
  cgFileSuffix=[int2str(ncx) 'x' int2str(ncy) 'x' int2str(ncz)];
end  
  
if isempty(maskFile)
  useMask=0;
else
  useMask=1;
  load(maskFile)
end

load(gridFile,'nx','ny','nz','x','y','z','bathy','da','dznom','dz','dx','dy','dth','dphi','sphericalGrid')

load(fullfile(boxFileBase,'boxes'),'ixBox','iyBox','izBox','ixb','iyb','izb','nb','Xboxnom','Yboxnom','Zboxnom','volb')
load(fullfile(boxFileBase,'boxnum'))
boxnum=boxnum(nbhalo+1:end-nbhalo,nbhalo+1:end-nbhalo,:);

% dxb=gcm2matrix(repmat(dx,[1 1 nz]),[1:nb]',ixBox,iyBox,izBox);
% dyb=gcm2matrix(repmat(dy,[1 1 nz]),[1:nb]',ixBox,iyBox,izBox);
% dzb=gcm2matrix(dz,[1:nb]',ixBox,iyBox,izBox);
areab=gcm2matrix(da,[1:nb]',ixBox,iyBox,izBox);

numBoxes=0;
nbc=ceil(nb/min([ncx ncy]));
% nominal position/width
xbnc=repmat(NaN,[nbc 1]);
ybnc=repmat(NaN,[nbc 1]);
zbnc=repmat(NaN,[nbc 1]);
xbc=repmat(NaN,[nbc 1]);
ybc=repmat(NaN,[nbc 1]);
zbc=repmat(NaN,[nbc 1]);
dxbc=repmat(NaN,[nbc 1]);
dybc=repmat(NaN,[nbc 1]);
dzbc=repmat(NaN,[nbc 1]);
dabc=repmat(NaN,[nbc 1]);
dvbc=repmat(NaN,[nbc 1]);

Beta=sparse(nbc,nb);
basinc=repmat(NaN,[nbc 1]);

if useMask
  basinNums=unique(basin_mask(~isnan(basin_mask)));
  numBasins=length(basinNums);
else
  basinNums=[1];
  numBasins=length(basinNums);
  bathy_basin_mask=ones([nx ny nz]);
  bathy_basin_mask(bathy==0)=NaN;
end

% Note: since we don't want any given coarse box to include grid points from 
% different ocean basins, we loop over the basin index. While this is perfectly 
% fine as far as the CG operators are concerned, it is no longer possible to 
% define a coarse grained (geographical) grid since more than one CG box may 
% map onto a single "nominal" grid point. This is really only 
% an issue near the Panama Canal where there is risk of accidentally combining  
% points from the Pacific and Atlantic basins into a single CG box. 
% Under these circumstances, the cleanest way to map boxes onto a lat/lon/depth 
% grid is to do so on the original grid using the operator M. That is, C_fg = M*C_cg, 
% where C_cg and C_fg  are vectors of tracer concentrations in the CG and FG space, 
% respectively.

for il=1:numBasins
  iBasin=basinNums(il);
%   for iy=1:32
% 	for ix=1:64
% 	  ix1=(ix-1)*2+1;
% 	  iy1=(iy-1)*2+1;
  for iy=1:ny/ncy
	for ix=1:nx/ncx
	  ix1=(ix-1)*ncx+1;
	  iy1=(iy-1)*ncy+1;
	  ix2=ix1+ncx-1;
	  iy2=iy1+ncy-1;  
      for iz=1:nz
		tmp=boxnum(ix1:ix2,iy1:iy2,iz);
		bb=bathy_basin_mask(ix1:ix2,iy1:iy2,iz);	 
		tmp=tmp(bb==iBasin);
		Ig=sort(tmp(find(~isnan(tmp(:))))); % global indices of FG boxes
		if ~isempty(Ig)
		  numBoxes=numBoxes+1;
		  Beta(numBoxes,Ig)=volb(Ig)'/sum(volb(Ig));
		  basinc(numBoxes)=iBasin; % assign a basin number to this coarse box
%         By definition, all vertical points in a profile have the same 
%         horizontal (xbc,ybc) coordinates (taken to be the mean coordinates 
%         of the surface box). With this convention, we should be able to 
%         uniquely identify all CG boxes in the same nominal profile.
%         We also define nominal coordinates (xbnc,ybnc -> Xboxnom,Yboxnom) 
%         as the mean over the geographical coordinates of the (ncx) x (ncy) 
%         rectangle that nominally constitutes this CG box. Unfortunately, 
%         these may not uniquely identify a CG box (e.g., if half the boxes 
%         in the (ncx) x (ncy) rectangle belong to one ocean basin and the 
%         other half belong to another basin).
		  if iz==1
			xbcsurf=mean(Xboxnom(Ig));
			ybcsurf=mean(Yboxnom(Ig));
			dabcsurf=sum(areab(Ig));
		  end
%         nominal positions (may NOT be unique so be very careful when using)
		  xbnc(numBoxes)=mean(x(ix1:ix2));
		  ybnc(numBoxes)=mean(y(iy1:iy2));
		  zbnc(numBoxes)=z(iz);

		  xbc(numBoxes)=xbcsurf;
		  ybc(numBoxes)=ybcsurf;
		  zbc(numBoxes)=mean(Zboxnom(Ig));
%         dxbc and dybc are not well defined if the coarse box is not "rectangular".
%         use with caution!
		  dxbc(numBoxes)=sum(dx(ix1:ix2,iy));
		  dybc(numBoxes)=sum(dy(iy1:iy2,iy));    
		  dabc(numBoxes)=dabcsurf;		  
% 		  dabc(numBoxes)=sum(areab(Ig));
          dvbc(numBoxes)=sum(volb(Ig));
% 		  (1): all boxes in a vertical column have the same area, and 
% 		  dz is defined equal to (volume of box)/(area of box). 
% 		  Thus dv(ix,iy,:) = constant*dz(ix,iy,:). With this definition, 
% 		  the vertical distribution of dz will be rather uneven 
% 		  in the horizontal, and deviate considerably from the nominal 
% 		  distribution, dznom. (Deeper boxes might become too thin, 
% 		  for instance.) A more fundamental problem is that the depth 
%         of any CG box interface, given by the SUM of dzbc for that profile, 
%         will deviate strongly from its true depth. So always use 
%         the nominal depth of the layer or interface in CG calculations that require 
%         this information (e.g., the Martin flux profile). DON'T use 
%         sum(dzbc) to compute the "depth" of any interface.
%           dzbc(numBoxes)=dvbc(numBoxes)/dabc(numBoxes);
          dzbc(numBoxes)=dvbc(numBoxes)/dabcsurf;
		end
	  end
	end
  end
end

Beta=Beta(1:numBoxes,:);
M=Beta';
% M(find(M))=1; % doesn't work with very big matrices
% one=@(x) 1;
% M=spfun(one,M);
M=spones(M);

% check
if nnz(M)~=nb
  error('Error constructing coarse graining operator')
end
s=full(sum(M',1));
if ~all(s==1)
  error('Error constructing coarse graining operator')
end

basinc=basinc(1:numBoxes);

xbnc=xbnc(1:numBoxes);
ybnc=ybnc(1:numBoxes);
zbnc=zbnc(1:numBoxes);
xbc=xbc(1:numBoxes);
ybc=ybc(1:numBoxes);
zbc=zbc(1:numBoxes);
dxbc=dxbc(1:numBoxes);
dybc=dybc(1:numBoxes);

dzbc=dzbc(1:numBoxes);
dabc=dabc(1:numBoxes);
dvbc=dvbc(1:numBoxes);

% save(['coarse_graining_operators_' cgFileSuffix],'Beta','M')

% Now coarse grain all box variables
nbc=size(Beta,1); % number of boxes in coarse-grained model

x=sort(unique(xbnc));
y=sort(unique(ybnc));
z=sort(unique(zbnc));

% these are not uniquely defined! Don't use them!!
% ixBox=repmat(NaN,[1 nbc]);
% iyBox=repmat(NaN,[1 nbc]);
% izBox=repmat(NaN,[1 nbc]);
% for ibc=1:nbc % loop over all coarse-grained boxes
% %   I=find(Beta(ibc,:))';
% % these will not be unique!!  
%   ixBox(ibc)=find(x==xbnc(ibc));  
%   iyBox(ibc)=find(y==ybnc(ibc));  
%   izBox(ibc)=find(z==zbnc(ibc));  
%   ixb{ibc}=ixBox(ibc);
%   iyb{ibc}=iyBox(ibc);
%   izb{ibc}=izBox(ibc);  
% end

% Rename variables
nb=nbc;

Xbox=xbc;
Ybox=ybc;
Zbox=zbc;

Xboxnom=xbnc;
Yboxnom=ybnc;
Zboxnom=zbnc;

% dxb and dyb are not well defined
dxb=dxbc;
dyb=dybc;
dzb=dzbc;
dab=dabc;
volb=dvbc;

% save boxes nb Xbox Ybox Zbox Xboxnom Yboxnom Zboxnom ixBox iyBox izBox ixb iyb izb volb
save(['boxes' cgFileSuffix],'nb','Xbox','Ybox','Zbox','Xboxnom','Yboxnom','Zboxnom','volb','dab','dxb','dyb','dzb','basinc')

% Now coarse grain all grid variables
nx=length(x);
ny=length(y);
nz=length(z);
% These are not well defined if the coarse box is not rectangular!
% bathy=repmat(0,[nx ny nz]);
% dv=repmat(0,[nx ny nz]);
% da=repmat(0,[nx ny nz]);
% dz=repmat(0,[nx ny nz]);
% for ibc=1:nbc
%   bathy(ixBox(ibc),iyBox(ibc),izBox(ibc))=1;
%   dv(ixBox(ibc),iyBox(ibc),izBox(ibc))=volb(ibc);
%   if izBox(ibc)==1 % surface box
%     I=find(Beta(ibc,:))'; % boxes contributing to this coarse-grained surface box
%     da(ixBox(ibc),iyBox(ibc),:)=sum(areab(I));
%   end
% end
% da=da.*bathy;
% kd=find(bathy==0); % dry points
% kw=find(bathy==1); % wet points
% dz(kw)=dv(kw)./da(kw);

dznom=dznom(1:nz);

save(['grid' cgFileSuffix],'x','y','z','nx','ny','nz','dznom','ncx','ncy','ncz')

if isempty(r0)
  save(['coarse_graining_operators' cgFileSuffix],'Beta','M')
else
  S=calc_interp_operator(r0,gridFile,boxFileBase,maskFile,cgFileSuffix);
  save(['coarse_graining_operators' cgFileSuffix],'Beta','M','S')
end
