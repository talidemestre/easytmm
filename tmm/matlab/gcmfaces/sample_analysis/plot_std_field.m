function []=plot_std_field(choiceV3orV4);
%object:    compute and display a standard deviation field
%inputs:    choiceV3orV4 ('v3' or 'v4') selects the sample GRID

input_list_check('plot_std_field',nargin);

%%%%%%%%%%%%%%%%%
%load parameters:
%%%%%%%%%%%%%%%%%
gcmfaces_global;
dir0=[myenv.gcmfaces_dir '/sample_input/'];
dirGrid=[dir0 '/GRID' choiceV3orV4  '/'];
dirIn=[dir0 '/SAMPLE' choiceV3orV4  '/'];
if strcmp(choiceV3orV4,'v4'); nF=5; fileFormat='compact'; else; nF=1; fileFormat='straight'; end;
mygrid=[]; grid_load(dirGrid,nF,fileFormat);

%%%%%%%%%%%
%get field:
%%%%%%%%%%%
nameFld='DDetan'; tt=[53:78]*336; cc=[0 0.10];
fld=rdmds2gcmfaces([dirIn nameFld],tt);
fld=std(fld,[],3); msk=mygrid.hFacC(:,:,1); fld(find(msk==0))=NaN;
 
%%%%%%%%%%%%
%plot field:
%%%%%%%%%%%%
if ~myenv.lessplot;
  figure; set(gcf,'Units','Normalized','Position',[0.1 0.3 0.4 0.6]);
  [X,Y,FLD]=convert2pcol(mygrid.XC,mygrid.YC,fld); 
  pcolor(X,Y,FLD); axis([-180 180 -90 90]); shading flat; caxis(cc); colorbar; 
end;


