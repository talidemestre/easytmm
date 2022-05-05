function []=example_faces2latlon2faces(choiceGrid);
%object:    interpolate back and forth between gcmfaces and lat-lon grid

if 0;
    clear all; grid_load('./',6,'cube'); gcmfaces_bindata; gcmfaces_global;
    lon=[-179:2:179]; lat=[-30:2:30];
    [lat,lon] = meshgrid(lat,lon);
    fld=sin(2*pi/180*mygrid.XC).*sin(2*pi/180*mygrid.YC);
    fld2=gcmfaces_interp_2d(fld,lon,lat);%go from gcmfaces grid to lat-lon grid
end;

gcmfaces_global; global mytri;

if myenv.verbose>0;
    gcmfaces_msg('===============================================');
    gcmfaces_msg(['*** entering example_faces2latlon2faces that will ' ...
        'interpolate a field on the chosen to a lat-lon grid and back' ...
        'to the original grid'],'');
end;

%%%%%%%%%%%%%%%%%
%load parameters:
%%%%%%%%%%%%%%%%%

dir0=[myenv.gcmfaces_dir '/sample_input/'];
dirGrid=[dir0 '/GRID' choiceGrid  '/'];
dirIn=[dir0 '/SAMPLE' choiceGrid  '/'];
if strcmp(choiceGrid,'v4'); 
    nF=5; fileFormat='compact'; 
elseif strcmp(choiceGrid,'v3');
    nF=1; fileFormat='straight'; 
elseif strcmp(choiceGrid,'cube'); 
    nF=6; fileFormat='cube'; 
else;
    error('unknow grid');
end;
grid_load(dirGrid,nF,fileFormat);

%store reference grid
mygrid_refgrid=mygrid;

%%%%%%%%%%%%%%%%%%%
%field for testing:
%%%%%%%%%%%%%%%%%%%

if myenv.verbose>0;
    gcmfaces_msg('* define a sinusoidal field for testing');
end;
fld=sin(2*pi/180*mygrid.XC).*sin(2*pi/180*mygrid.YC);

%%%%%%%%%%%%%%%%%%%%%%%%%%
%lat-lon grid for testing:
%%%%%%%%%%%%%%%%%%%%%%%%%%

if myenv.verbose>0;
    gcmfaces_msg('* define 2x2 lat-lon grid for testing');
end;
%define lat-lon grid
lon=[-179:2:179]; lat=[-89:2:89]; aa=[-180 180 -90 90];
if max(mygrid_refgrid.XC)>180;
    lon=[1:2:359]; aa=[0 360 -90 90];
end;
% lon=[-179:2:179]; lat=[-30:2:30];
[lat,lon] = meshgrid(lat,lon);
%prepare mygrid for lat-lon with no mask
mygrid_latlon.nFaces=1;
mygrid_latlon.XC=gcmfaces({lon}); mygrid_latlon.YC=gcmfaces({lat});
mygrid_latlon.dirGrid='none';
mygrid_latlon.fileFormat='straight';
mygrid_latlon.ioSize=size(lon);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%interpolate to lat-lon grid:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if myenv.verbose>0;
    gcmfaces_msg('* interpolate test field to lat-lon grid');
end;
mygrid=mygrid_latlon; gcmfaces_bindata; 
veclon=convert2array(mygrid.XC); veclon=veclon(mytri.kk);
veclat=convert2array(mygrid.YC); veclat=veclat(mytri.kk);

mygrid=mygrid_refgrid; gcmfaces_bindata; 
vecfld=gcmfaces_interp_2d(fld,veclon,veclat);%go from gcmfaces grid to lat-lon grid

mygrid=mygrid_latlon; gcmfaces_bindata; 
fld_latlon=NaN*convert2array(mygrid.XC); 
fld_latlon(mytri.kk)=vecfld;
fld_latlon=convert2array(fld_latlon); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%interpolate back to ref grid:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if myenv.verbose>0;
    gcmfaces_msg('* interpolate back to original grid');
end;
mygrid=mygrid_refgrid; gcmfaces_bindata; 
veclon=convert2array(mygrid.XC); veclon=veclon(mytri.kk);
veclat=convert2array(mygrid.YC); veclat=veclat(mytri.kk);

mygrid=mygrid_latlon; gcmfaces_bindata; 
vecfld=gcmfaces_interp_2d(fld_latlon,veclon,veclat);%go from gcmfaces grid to lat-lon grid

mygrid=mygrid_refgrid; gcmfaces_bindata; 
fld_refgrid=NaN*convert2array(mygrid.XC); 
fld_refgrid(mytri.kk)=vecfld;
fld_refgrid=convert2array(fld_refgrid); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%get and plot the lat-lon array:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if myenv.verbose>0;
    gcmfaces_msg('* plot lat-lon grid interpolated field');
end;
FLD=fld_latlon{1};
figure; pcolor(lon,lat,FLD); colorbar;
axis(aa); title('interpoate lat-lon map');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot difference due to interpolation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if myenv.verbose>0;
    gcmfaces_msg('* plot error due to back and forth interpolation');
end;
mygrid=mygrid_refgrid;
figure; 
aa=which('m_proj'); 
if isempty(aa); 
  [X,Y,FLD]=convert2pcol(mygrid.XC,mygrid.YC,fld_refgrid-fld); 
  pcolor(X,Y,FLD); shading flat; colorbar;
else;
  m_map_gcmfaces(fld_refgrid-fld);
end;
title('error due to back and forth interpolation');


if myenv.verbose>0;
    gcmfaces_msg('*** leaving example_faces2latlon2faces');
    gcmfaces_msg('===============================================');
end;
