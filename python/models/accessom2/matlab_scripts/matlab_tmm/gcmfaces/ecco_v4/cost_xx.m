function []=cost_xx(dirModel,dirMat,doComp,dirTex,nameTex);
%object:	compute cost function term for atmospheric controls
%inputs:	dirModel is the model directory
%               dirMat is the directory where diagnozed .mat files will be saved
%                     -> set it to '' to use the default [dirModel 'mat/']
%		doComp is a switch (1->compute; 0->display)
%optional:      dirTex is the directory where tex and figures files are created
%                 (if not specified then display all results to screen instead)
%               nameTex is the tex file name (default : 'myPlots')

if isempty(dirMat); dirMat=[dirModel 'mat/']; else; dirMat=[dirMat '/']; end;
if isempty(dir(dirMat)); eval(['!mkdir ' dirMat ';']); end;

%determine if and where to create tex and figures files
dirMat=[dirMat '/'];
if isempty(who('dirTex'));
  addToTex=0;
else;
  if ~ischar(dirTex); error('mis-specified dirTex'); end;
  addToTex=1;
  if isempty(who('nameTex')); nameTex='myPlots'; end;
  fileTex=[dirTex nameTex '.tex'];
end;

for ii=1:6;
switch ii;
case 1; xxName='atemp'; sigName='cap_sigma_tmp2m_degC_eccollc.bin'; cc=2; uni='K';
case 2; xxName='aqh'; sigName='cap_sigma_spfh2m_eccollc.bin'; cc=2; uni='g/kg';
case 3; xxName='tauu'; sigName='cap_sigma_ustr_eccollc.bin'; cc=0.04; uni='N/m2';
case 4; xxName='tauv'; sigName='cap_sigma_vstr_eccollc.bin'; cc=0.04; uni='N/m2';
case 5; xxName='lwdown'; sigName='cap_sigma_dlw_eccollc.bin'; cc=20; uni='W/m2';
case 6; xxName='swdown'; sigName='cap_sigma_dsw_eccollc.bin'; cc=40; uni='W/m2';
end;

if doComp;

%load grid
gcmfaces_global;
if ~isfield(mygrid,'XC'); grid_load('./GRID/',5,'compact'); end;
if ~isfield(mygrid,'LATS_MASKS'); gcmfaces_lines_zonal; end;

dirSig='/net/nares/raid11/ecco-shared/ecco-version-4/input/input_all_from_pleiades/';

%read model cost output
tmp1=dir([dirModel 'ADXXfiles/xx_' xxName '.effective.*data']);
tmp2=size(convert2gcmfaces(mygrid.XC)); 
fld_xx=read2memory([dirModel 'ADXXfiles/' tmp1.name],[tmp2 tmp1.bytes/tmp2(1)/tmp2(2)/4]);
fld_xx=convert2gcmfaces(fld_xx);
%does not work when adjoint overwrites xx*effective*meta     fld_xx=rdmds2gcmfaces([dirModel 'ADXXfiles/xx_' xxName '.effective.*']);

fld_sig=v4_read_bin([dirSig sigName],1,0);
if strcmp(xxName,'aqh'); fld_xx=fld_xx*1000; fld_sig=fld_sig*1000; end;

%compute xx stats
fld_rms=sqrt(mean(fld_xx.^2,3));
fld_mean=mean(fld_xx,3);
fld_std=std(fld_xx,[],3);

%mask
fld_rms=fld_rms.*mygrid.mskC(:,:,1); 
fld_sig=fld_sig.*mygrid.mskC(:,:,1);
fld_mean=fld_mean.*mygrid.mskC(:,:,1);
fld_std=fld_std.*mygrid.mskC(:,:,1);

clear fld_xx;

eval(['save ' dirMat '/cost_xx_' xxName '.mat fld_* cc uni;']);

else;%display previously computed results

global mygrid;

eval(['load ' dirMat '/cost_xx_' xxName '.mat;']);

figure; 
m_map_gcmfaces(fld_sig,0,{'myCaxis',[0:0.05:0.5 0.6:0.1:1 1.25]*cc});
myCaption={['prior uncertainty -- ' xxName ' (' uni ')']};
if addToTex; write2tex(fileTex,2,myCaption,gcf); end;

figure; 
m_map_gcmfaces(fld_rms,0,{'myCaxis',[0:0.05:0.5 0.6:0.1:1 1.25]*cc});
myCaption={['rms adjustment -- ' xxName ' (' uni ')']};
if addToTex; write2tex(fileTex,2,myCaption,gcf); end;

figure;
m_map_gcmfaces(fld_std,0,{'myCaxis',[0:0.05:0.5 0.6:0.1:1 1.25]*cc});
myCaption={['std adjustment -- ' xxName ' (' uni ')']};
if addToTex; write2tex(fileTex,2,myCaption,gcf); end;

figure;
m_map_gcmfaces(fld_mean,0,{'myCaxis',[-0.5:0.05:0.5]*cc});
myCaption={['mean adjustment -- ' xxName ' (' uni ')']};
if addToTex; write2tex(fileTex,2,myCaption,gcf); end;

end;

end;%for ii=1:6;

