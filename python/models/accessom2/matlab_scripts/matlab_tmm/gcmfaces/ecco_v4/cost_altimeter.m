function []=cost_altimeter(dirModel,dirMat);
%object:       compute or plot the various sea level statistics
%              (std model-obs, model, obs, leading to cost function terms)
%inputs:       dirModel is the model run directory
%              dirMat is the directory where diagnozed .mat files will be saved
%                     -> set it to '' to use the default [dirModel 'mat/']
%              doComp is the switch from computation to plot
doComp=1;
if doComp==1;
  doSave=1;
  doPlot=0;
else;
  doSave=0;
  doPlot=1;
end;
doPrint=0;

for doDifObsOrMod=1:3;

if doDifObsOrMod==1; suf='modMobs'; elseif doDifObsOrMod==2; suf='obs'; else; suf='mod'; end;

%%%%%%%%%%%
%load grid:
%%%%%%%%%%%

gcmfaces_global;
if ~isfield(mygrid,'XC'); grid_load('./GRID/',5,'compact'); end;
if ~isfield(mygrid,'LATS_MASKS'); gcmfaces_lines_zonal; end;

%%%%%%%%%%%%%%%
%define pathes:
%%%%%%%%%%%%%%%

dirSigma='/net/nares/raid11/ecco-shared/ecco-version-4/input/input_all_from_pleiades/';
%nameSigma={'sigma_MDT_glob_eccollc.bin','sigma_SLA_smooth_eccollc.bin','sigma_SLA_PWS07r2_glob_eccollc.bin'}; maxLatObs=66
nameSigma={'sigma_MDT_glob_eccollc.bin','slaerr_largescale_r1.err','slaerr_gridscale_r1.err'}; maxLatObs=90

if isempty(dirMat); dirMat=[dirModel 'mat/']; else; dirMat=[dirMat '/']; end;
if isempty(dir(dirMat)); eval(['!mkdir ' dirMat ';']); end;
runName=pwd; tmp1=strfind(runName,'/'); runName=runName(tmp1(end)+1:end);

%%%%%%%%%%%%%%%%%
%do computations:
%%%%%%%%%%%%%%%%%

if doComp==0; 
  eval(['load ' dirMat 'cost_altimeter_' suf '.mat myflds;']);
else;

tic;
%mdt cost function term (misfit plot)
dif_mdt=rdmds2gcmfaces([dirModel 'barfiles/mdtdiff_smooth']);
sig_mdt=v4_read_bin([dirSigma nameSigma{1}],1,0);
sig_mdt(find(sig_mdt==0))=NaN;
%store:
myflds.dif_mdt=dif_mdt;
myflds.sig_mdt=sig_mdt;

%skip blanks:
tmp1=dir([dirModel 'barfiles/sladiff_smooth*data']);
nrec=tmp1.bytes/90/1170/4;
listRecs=[1:7:nrec];

toc; tic;
%lsc cost function term:
if doDifObsOrMod==1;
  sladiff_smooth=cost_altimeter_read([dirModel 'barfiles/sladiff_smooth'],listRecs);
elseif doDifObsOrMod==2;
  sladiff_smooth=cost_altimeter_read([dirModel 'barfiles/slaobs_smooth'],listRecs);
else;
  sladiff_smooth=cost_altimeter_read([dirModel 'barfiles/sladiff_smooth'],listRecs);
  sladiff_smooth=sladiff_smooth+cost_altimeter_read([dirModel 'barfiles/slaobs_smooth'],listRecs);
end;
%mask missing points:
sladiff_smooth(sladiff_smooth==0)=NaN;
%compute rms:
rms_sladiff_smooth=sqrt(nanmean(sladiff_smooth.^2,3));
std_sladiff_smooth=nanstd(sladiff_smooth,0,3);
%get weight:
sig_sladiff_smooth=v4_read_bin([dirSigma nameSigma{2}],1,0);
sig_sladiff_smooth(find(sig_sladiff_smooth==0))=NaN;
%store:
myflds.rms_sladiff_smooth=rms_sladiff_smooth;
myflds.std_sladiff_smooth=std_sladiff_smooth;
myflds.sig_sladiff_smooth=sig_sladiff_smooth;

toc; tic;
%pointwise/point35days cost function term:
if doDifObsOrMod==1;
  sladiff_point35d=cost_altimeter_read([dirModel 'barfiles/sladiff_raw'],listRecs);
elseif doDifObsOrMod==2;
  sladiff_point35d=cost_altimeter_read([dirModel 'barfiles/slaobs_raw'],listRecs);
else;
  sladiff_point35d=cost_altimeter_read([dirModel 'barfiles/sladiff_raw'],listRecs);
  sladiff_point35d=sladiff_point35d+cost_altimeter_read([dirModel 'barfiles/slaobs_raw'],listRecs);
end;
%mask missing points:
sladiff_point35d(sladiff_point35d==0)=NaN;
%compute rms:
rms_sladiff_point35d=sqrt(nanmean(sladiff_point35d.^2,3));
std_sladiff_point35d=nanstd(sladiff_point35d,0,3);
%store:
myflds.rms_sladiff_point35d=rms_sladiff_point35d;
myflds.std_sladiff_point35d=std_sladiff_point35d;

toc; tic;
%pointwise/1day terms:
sum_all=0*mygrid.XC; msk_all=sum_all;
for ii=1:3; 
  if ii==1; myset='tp'; elseif ii==2; myset='gfo'; else; myset='ers'; end;
  %topex pointwise misfits:
  if doDifObsOrMod==1;
    sladiff_point=cost_altimeter_read([dirModel 'barfiles/sladiff_' myset '_raw'],listRecs);
  elseif doDifObsOrMod==2;
    sladiff_point=cost_altimeter_read([dirModel 'barfiles/slaobs_' myset '_raw'],listRecs);
  else;
    sladiff_point=cost_altimeter_read([dirModel 'barfiles/sladiff_' myset '_raw'],listRecs);
    sladiff_point=sladiff_point+cost_altimeter_read([dirModel 'barfiles/slaobs_' myset '_raw'],listRecs);
  end;
  %compute rms:
  msk_tmp=1*(sladiff_point~=0); 
  msk_tmp=sum(msk_tmp,3); sum_tmp=sum(sladiff_point.^2,3);
  sum_all=sum_all+sum_tmp; msk_all=msk_all+msk_tmp; 
  msk_tmp(find(msk_tmp==0))=NaN;
  eval(['rms_' myset '=sqrt(sum_tmp./msk_tmp);']);
  sladiff_point(sladiff_point==0)=NaN;
  eval(['std_' myset '=nanstd(sladiff_point,0,3);']);
end;
%compute overall rms:
msk_all(find(msk_all==0))=NaN;
rms_sladiff_point=sqrt(sum_all./msk_all);
%fill blanks:
warning('off','MATLAB:divideByZero');
msk=mygrid.mskC(:,:,1); msk(find(abs(mygrid.YC)>maxLatObs))=NaN;
rms_sladiff_point=diffsmooth2D_extrap_inv(rms_sladiff_point,msk);
warning('on','MATLAB:divideByZero');
%get weight:
sig_sladiff_point=v4_read_bin([dirSigma nameSigma{3}],1,0);
sig_sladiff_point(find(sig_sladiff_point==0))=NaN;
%store:
myflds.rms_tp=rms_tp; myflds.rms_gfo=rms_gfo; myflds.rms_ers=rms_ers; 
myflds.std_tp=std_tp; myflds.std_gfo=std_gfo; myflds.std_ers=std_ers;
myflds.rms_sladiff_point=rms_sladiff_point;
myflds.sig_sladiff_point=sig_sladiff_point;

%compute zonal mean/median:
for ii=1:4;
  switch ii;
    case 1; tmp1='mdt'; cost_fld=(mygrid.mskC(:,:,1).*myflds.dif_mdt./myflds.sig_mdt).^2;
    case 2; tmp1='lsc'; cost_fld=(mygrid.mskC(:,:,1).*myflds.rms_sladiff_smooth./myflds.sig_sladiff_smooth).^2;
    case 3; tmp1='point35d'; cost_fld=(mygrid.mskC(:,:,1).*myflds.rms_sladiff_point35d./myflds.sig_sladiff_point).^2;
    case 4; tmp1='point'; cost_fld=(mygrid.mskC(:,:,1).*myflds.rms_sladiff_point./myflds.sig_sladiff_point).^2;
  end;    
  cost_zmean=calc_zonmean_T(cost_fld); eval(['mycosts_mean.' tmp1 '=cost_zmean;']);
  cost_zmedian=calc_zonmedian_T(cost_fld); eval(['mycosts_median.' tmp1 '=cost_zmedian;']);
end;

toc; %write to disk:
if doSave; eval(['save ' dirMat 'cost_altimeter_' suf '.mat myflds mycosts_mean mycosts_median;']); end;

end;%if doComp

if doPlot; 
cc=[-0.4:0.05:-0.25 -0.2:0.03:-0.05 -0.03:0.01:0.03 0.05:0.03:0.2 0.25:0.05:0.4];
figure; m_map_gcmfaces(myflds.dif_mdt,0,{'myCaxis',cc}); drawnow;
cc=[0:0.005:0.02 0.03:0.01:0.05 0.06:0.02:0.1 0.14:0.03:0.2 0.25:0.05:0.4];
figure; m_map_gcmfaces(myflds.rms_sladiff_smooth,0,{'myCaxis',cc}); drawnow;
figure; m_map_gcmfaces(myflds.rms_sladiff_point35d,0,{'myCaxis',cc}); drawnow;
figure; m_map_gcmfaces(myflds.rms_sladiff_point,0,{'myCaxis',cc}); drawnow; 
end;

if doPlot&doPrint;
  dirFig='../figs/altimeter/'; ff0=gcf-4;
  for ff=1:4; 
    figure(ff+ff0); saveas(gcf,[dirFig runName '_' suf num2str(ff)],'fig'); 
    eval(['print -depsc ' dirFig runName '_' suf num2str(ff) '.eps;']);   
    eval(['print -djpeg90 ' dirFig runName '_' suf num2str(ff) '.jpg;']); 
  end;
end;

end;%for doDifObsOrMod=1:3;



function [fldOut]=cost_altimeter_read(fileIn,recIn);

nrec=length(recIn);
global mygrid; siz=[size(convert2gcmfaces(mygrid.XC)) nrec];
lrec=siz(1)*siz(2)*4;
myprec='float32';

fldOut=zeros(siz);
fid=fopen([fileIn '.data'],'r','b');
for irec=1:nrec;
status=fseek(fid,(recIn(irec)-1)*lrec,'bof');
fldOut(:,:,irec)=fread(fid,siz(1:2),myprec);
end;

fldOut=convert2gcmfaces(fldOut);



