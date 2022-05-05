function []=example_interp(choiceV3orV4);
%object:    a interp2 example within gcmfaces
%inputs:    choiceV3orV4 ('v3' or 'v4') selects the sample GRID

gcmfaces_global;
if myenv.verbose>0;
    gcmfaces_msg(['* call example_interp : will define ' ...
        'a 2x2 gridded variable (an SSH field here), and then ' ...
        'use interp2 to map it to the chosen grid. '],'');
end;

%%%%%%%%%%%%%%%%%
%load parameters:
%%%%%%%%%%%%%%%%%

dir0=[myenv.gcmfaces_dir '/sample_input/'];
dirGrid=[dir0 '/GRID' choiceV3orV4  '/'];
dirIn=[dir0 '/SAMPLE' choiceV3orV4  '/'];
if strcmp(choiceV3orV4,'v4'); nF=5; fileFormat='compact'; else; nF=1; fileFormat='straight'; end;
grid_load(dirGrid,nF,fileFormat);

%%%%%%%%%%%%%%%%%%%%%%%
%get sample data: V3 SSH
dirV3=[myenv.gcmfaces_dir '/sample_input/SAMPLEv3/'];
etan=rdmds([dirV3 'DDetan'],0); etan(etan==0)=NaN;
dirV3=[myenv.gcmfaces_dir '/sample_input/GRIDv3/'];
lon=rdmds([dirV3 'XC']); lat=rdmds([dirV3 'YC']);
lon=lon(1:2:end,21:2:140);
lat=lat(1:2:end,21:2:140);
etan=etan(1:2:end,21:2:140);

%%%%%%%%%%%%%%%%%%%%%%%
%do the interpolation:
x=[lon-360;lon;lon+360]; y=[lat;lat;lat]; z=[etan;etan;etan];

z_interp=gcmfaces(5);
for ii=1:mygrid.nFaces;
xi=mygrid.XC{ii}; yi=mygrid.YC{ii};
zi = interp2(x',y',z',xi,yi);
z_interp{ii}=zi;
end;

%%%%%%%%%%%%%%%%%%%%%%%
%illustrate the result:

figure; x=[lon-360;lon]; y=[lat;lat]; z=[etan;etan];
pcolor(x,y,z); axis([-180 180 -90 90]); shading flat; caxis([-2 1]); colorbar;

figure; [X,Y,FLD]=convert2pcol(mygrid.XC,mygrid.YC,z_interp);
pcolor(X,Y,FLD); axis([-180 180 -90 90]); shading flat; caxis([-2 1]); colorbar;



