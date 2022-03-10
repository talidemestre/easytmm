gridType='spherical';
deltaT=7200;
sphericalGrid=1;
useOverflows=0;

rundir='/Users/davidhutchinson/Dropbox/UNSW/data/MatrixExtractionCode/MOM5/a38_c8_cold/';
vertFile=fullfile(rundir,'ocean_vert.nc');
depthFile=fullfile(rundir,'ht.nc');
levelFile=fullfile(rundir,'temp_levels.nc');
% addpath('/Users/davidhutchinson/Dropbox/UNSW/data/MatrixExtractionCode/spk');

x=ncread(depthFile,'xt_ocean'); % nominal longitude
y=ncread(depthFile,'yt_ocean'); % nominal latitude
z=ncread(depthFile,'st_ocean');

nx=length(x);
ny=length(y);
nz=length(z);

% figure out dry/wet mask
numlevels=ncread(levelFile,'num_levels');
% numlevels=numlevels';
levels=repmat(numlevels,[1 1 nz]);
K=repmat([1:nz]',[1 nx ny]);
K=permute(K,[2 3 1]);
bathy=1*(K<=levels);

kd=find(isnan(bathy) | bathy==0); % dry points
% kd4=find(isnan(b4) | b4==0); % dry points
kw=find(~isnan(bathy) & bathy~=0); % wet points
bathy(kd)=0;
bathy(kw)=1;
% find index of deepest wet point
ideep=repmat(NaN,[nx ny]);
for iy=1:ny
   for ix=1:nx
      sk=squeeze(bathy(ix,iy,:));
      k=find(isnan(sk) | sk==0);
      if ~isempty(k)
         ideep(ix,iy)=min(k)-1;
      else
         ideep(ix,iy)=nz;
      end
   end
end

% figure out dz
zb=ncread(depthFile,'st_edges_ocean'); % bottom of cells
dznom=diff(zb);
zb=zb(2:end);

dz=repmat(dznom,[1 nx ny]);
dz=permute(dz,[2 3 1]);
ht=ncread(depthFile,'ht')';
for j=1:ny
  for i=1:nx
    kb=numlevels(i,j);
    if kb>0
      dz(i,j,kb)=ht(j,i)-zb(kb-1);
    end
  end
end
dz=dz.*bathy;

tmp=ncread(vertFile,'x_vert_T');
dx=abs((tmp(:,:,2)+tmp(:,:,3))/2 - (tmp(:,:,1)+tmp(:,:,4))/2);

tmp=ncread(vertFile,'y_vert_T');
dy=abs((tmp(:,:,4)+tmp(:,:,3))/2 - (tmp(:,:,1)+tmp(:,:,2))/2);

da=ncread(depthFile,'area_t');

da=repmat(da,[1 1 nz]).*bathy;
dv=da.*dz;

dphi=dx;
dth=dy;

save grid kd kw nx ny nz x y z dv ideep bathy dznom dz dx dy dth dphi ...
	 da sphericalGrid deltaT gridType useOverflows
