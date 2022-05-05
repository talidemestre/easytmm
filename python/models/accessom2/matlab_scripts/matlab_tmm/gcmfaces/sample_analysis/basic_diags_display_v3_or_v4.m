function []=basic_diags_display_v3_or_v4(choiceV3orV4);
%object:    display the result of basic_diags_compute_v3_or_v4
%inputs:    choiceV3orV4 ('v3' or 'v4') selects the sample GRID

input_list_check('basic_diags_display_v3_or_v4',nargin);

gcmfaces_global;
if myenv.verbose>0;
    gcmfaces_msg('===============================================');
    gcmfaces_msg(['*** entering basic_diags_display_v3_or_v4 ' ...
        'that will display (as a figure or as text) the results of basic_diags_compute_v3_or_v4'],'');
end;

%%%%%%%%%%%%%%%%%
%load parameters:
%%%%%%%%%%%%%%%%%

dir0=[myenv.gcmfaces_dir '/sample_input/'];
dirGrid=[dir0 '/GRID' choiceV3orV4  '/'];
dirIn=[dir0 '/SAMPLE' choiceV3orV4  '/'];
if strcmp(choiceV3orV4,'v4'); nF=5; fileFormat='compact'; else; nF=1; fileFormat='straight'; end;
grid_load(dirGrid,nF,fileFormat);

if strcmp(choiceV3orV4,'v4'); LATS=[-89:89]'; else; LATS=[-75:75]'; end;
gcmfaces_lines_zonal(LATS);
eval(['[lonPairs,latPairs,names]=line_greatC_TUV_MASKS_' choiceV3orV4 ';']);
gcmfaces_lines_transp(lonPairs,latPairs,names);
RF=squeeze(mygrid.RF)';

dirOut=[dirIn 'matlabDiags/']; 
if ~isdir(dirOut); eval(['mkdir ' dirOut ';']); end;

%%%$%%%%%%%%
%do display:
%%%%$%%%%%%%

listFld=dir([dirIn 'DDtheta.00*data']);
listTimes=[]; for tt=1:length(listFld); listTimes=[listTimes;str2num(listFld(tt).name(9:end-5))]; end;

for setDiags=1:2
%%%%%%%%%%%%%%%%%%%%%%%%%
%load pre-computed diags:
%%%%%%%%%%%%%%%%%%%%%%%%%

for ttt=1:length(listTimes);
   tt=listTimes(ttt); eval(['load ' dirOut 'set' num2str(setDiags) '_' num2str(tt) '.mat;']);
   if setDiags==1;
      listDiags={'fldBAR','fldOV','fldTRANSPORTS'};
   elseif setDiags==2;
      listDiags={'fldTzonmean','fldSzonmean','fldMT_H','fldMT_FW'};
   else;
      0
   end;
   clear tmpdiag; for ii=1:length(listDiags); eval(['tmpdiag.' listDiags{ii} '=' listDiags{ii} ';']); end;
   if ttt==1; alldiag=tmpdiag; else; alldiag(ttt)=tmpdiag; end;
end;

%%%%%%%%%%%%%%%
%display diags:
%%%%%%%%%%%%%%%

if setDiags==1;

tt=[1]; nt=length(tt); TT=listTimes(tt)*3600/86400;

%barotropic streamfunction:
fld=0*alldiag(1).fldBAR; for ttt=tt; fld=fld+alldiag(ttt).fldBAR/nt; end; fldBF=fld;
[X,Y,FLD]=convert2pcol(mygrid.XC,mygrid.YC,fld);
cc=[[-200:40:-40] [-30:10:80]];
figure; pcolor(X,Y,FLD); axis([-180 180 -90 90]); set(gcf,'Renderer','zbuffer'); shading interp; 
colormap(jet(16)); caxis([-50 50]); colorbar; title('Horizontal Stream Function');

%meridional streamfunction:
fld=0*alldiag(1).fldOV; for ttt=tt; fld=fld+alldiag(ttt).fldOV/nt; end; fldOV=fld;
X=LATS*ones(1,length(RF)); Y=ones(length(LATS),1)*RF;
cc=[[-50:10:-30] [-24:3:24] [30:10:50]];
figure; pcolor(X,Y,fld); axis([-90 90 -6000 0]); set(gcf,'Renderer','zbuffer'); shading interp;
colormap(jet(16)); caxis([-25 25]); colorbar; title('Meridional Stream Function');


tt=[1:length(alldiag)]; nt=length(tt); TT=listTimes(tt)*3600/86400;
if myenv.verbose>0; gcmfaces_msg('* call basic_diags_display_transport : print and/or plot transports');end;

%Bering Strait and Arctic/Atlantic exchanges:
if nt>1; figure; orient tall; end; iiList=[1 8:12]; rrList=[[-1 3];[-3 1];[-6 2];[-3 9];[-9 3];[-0.5 0.5]];
for iii=1:length(iiList); ii=iiList(iii); if nt>1; subplot(3,2,iii); end;
basic_diags_display_transport(alldiag,ii,[mygrid.LINES_MASKS(ii).name ' (>0 to Arctic)'],RF,listTimes,rrList(iii,:));
end;

%Florida Strait:
if nt>1; figure; orient tall; end; iiList=[3 4 6 7]; rrList=[[0 35];[0 35];[-10 10];[-10 10]];
for iii=1:length(iiList); ii=iiList(iii); if nt>1; subplot(2,2,iii); end;
basic_diags_display_transport(alldiag,ii,[mygrid.LINES_MASKS(ii).name ' (>0 to Atlantic)'],RF,listTimes,rrList(iii,:));
end;

%Drake, ACC etc:
if nt>1; figure; orient tall; end; iiList=[13 NaN 20 19 18]; rrList=[[120 200];[NaN NaN];[120 200];[-40 10];[120 200]];
for iii=1:length(iiList); ii=iiList(iii);
if ~isnan(ii); if nt>1; subplot(3,2,iii); end; 
basic_diags_display_transport(alldiag,ii,[mygrid.LINES_MASKS(ii).name ' (>0 to the West)'],RF,listTimes,rrList(iii,:)); 
end;
end;
%Indonesian Throughflow special case:
if nt>1; subplot(3,2,6); end;
basic_diags_display_transport(alldiag,[14:17],'Indonesian Throughflow (>0 to the West)',RF,listTimes,[-40 10]);


elseif setDiags==2;

tt=[1:length(alldiag)]; nt=length(tt); TT=listTimes(tt)*3600/86400;
 
fld=0*zeros(nt,length(LATS)); kk=1;
for ttt=1:nt; tmp1=alldiag(tt(ttt)).fldTzonmean(:,kk); fld(ttt,:)=tmp1'; end;
x=TT*ones(1,length(LATS)); y=ones(nt,1)*LATS';
figure; set(gcf,'Renderer','zbuffer');
if nt>1; 
  pcolor(x,y,fld); shading interp; axis([TT(1) TT(end) -90 90]);
  colormap(jet(15)); caxis([-3 30]);  colorbar;
else; 
  plot(y,fld); aa=axis; aa(1:2)=max(abs(aa(1:2)))*[-1 1]; axis(aa); grid on;
end;
set(gca,'FontSize',14); 
title(['zonal mean T -- in degC -- at ' num2str(mygrid.RC(kk)) 'm']);

fld=0*zeros(nt,length(LATS)); kk=1;
for ttt=1:nt; tmp1=alldiag(tt(ttt)).fldSzonmean(:,kk); fld(ttt,:)=tmp1'; end;
x=TT*ones(1,length(LATS)); y=ones(nt,1)*LATS';
figure; set(gcf,'Renderer','zbuffer');
if nt>1; 
  pcolor(x,y,fld); shading interp; axis([TT(1) TT(end) -90 90]);
  colormap(jet(15)); caxis([32 36]);  colorbar;
else; 
  plot(y,fld); aa=axis; aa(1:2)=max(abs(aa(1:2)))*[-1 1]; axis(aa); grid on;
end;
set(gca,'FontSize',14);
title(['zonal mean S -- in psu -- at ' num2str(mygrid.RC(kk)) 'm']);

fld=0*zeros(nt,length(alldiag(1).fldMT_H));
for ttt=1:nt; tmp1=alldiag(tt(ttt)).fldMT_H; fld(ttt,:)=tmp1'; end;
x=TT*ones(1,length(alldiag(1).fldMT_H)); y=ones(nt,1)*LATS';
figure; set(gcf,'Renderer','zbuffer');
if nt>1; 
  pcolor(x,y,fld); shading interp; axis([TT(1) TT(end) -90 90]);
  colormap(jet(15)); caxis([-2 2]);  colorbar;
else; 
  plot(y,fld); aa=axis; aa(1:2)=max(abs(aa(1:2)))*[-1 1]; 
  aa(3:4)=max(abs(aa(3:4)))*[-1 1]; axis(aa); grid on;
end;
set(gca,'FontSize',14);
title('Meridional Heat Transport (in pW)'); set(gca,'FontSize',14);

fld=0*zeros(nt,length(alldiag(1).fldMT_FW));
for ttt=1:nt; tmp1=alldiag(tt(ttt)).fldMT_FW; fld(ttt,:)=tmp1'; end;
x=TT*ones(1,length(alldiag(1).fldMT_FW)); y=ones(nt,1)*LATS';
figure; set(gcf,'Renderer','zbuffer');
if nt>1; 
  pcolor(x,y,fld); shading interp; axis([TT(1) TT(end) -90 90]);
  colormap(jet(15)); caxis([-1 1]);  colorbar;
else; 
  plot(y,fld); aa=axis; aa(1:2)=max(abs(aa(1:2)))*[-1 1]; 
  aa(3:4)=max(abs(aa(3:4)))*[-1 1]; axis(aa); grid on;
end;
set(gca,'FontSize',14);
title('Meridional FW Transport (in ??)'); set(gca,'FontSize',14);

end;%if setDiags==1;
end;%for setDiags=1:2

if myenv.verbose>0;
    gcmfaces_msg('*** leaving basic_diags_display_v3_or_v4');
    gcmfaces_msg('===============================================','');
end;
