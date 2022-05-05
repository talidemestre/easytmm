function []=basic_diags_compute_v3_or_v4(choiceV3orV4);
%object:    illustrates a series of standard computations
%           (streamfunctions, transports, zonal means, etc.)
%inputs:    choiceV3orV4 ('v3' or 'v4') selects the sample GRID

input_list_check('basic_diags_compute_v3_or_v4',nargin);

gcmfaces_global;
if myenv.verbose>0;
    gcmfaces_msg('===============================================');
    gcmfaces_msg(['*** entering basic_diags_compute_v3_or_v4 ' ...
        'that will load a set of variables form file ' ...
        'and compute a series of derived diagnostics '],'');
%     gcmfaces_msg('*** entering basic_diags_compute_v3_or_v4','');
%     gcmfaces_msg('that will load a set of variables form file','  ');
%     gcmfaces_msg('and compute a series of derived diagnostics','  ');
end;

%%%%%%%%%%%%%%%%%
%load parameters:
%%%%%%%%%%%%%%%%%

if myenv.verbose>0;
    gcmfaces_msg('* set grid files path and format, and number of faces for this grid');
end;
dir0=[myenv.gcmfaces_dir '/sample_input/'];
dirGrid=[dir0 '/GRID' choiceV3orV4  '/'];
dirIn=[dir0 '/SAMPLE' choiceV3orV4  '/'];
if strcmp(choiceV3orV4,'v4'); nF=5; fileFormat='compact'; else; nF=1; fileFormat='straight'; end;
if myenv.verbose>0;
    gcmfaces_msg('* call grid_load : load grid to memory (mygrid) according to');
    gcmfaces_msg(['dirGrid = ' dirGrid],'  ');
    gcmfaces_msg(['nFaces = ' num2str(nF)],'  ');
    gcmfaces_msg(['fileFormat = ' fileFormat],'  ');
%     fprintf(['  > dirGrid = ' dirGrid '\n']);
end;
grid_load(dirGrid,nF,fileFormat);

if myenv.verbose>0;
    gcmfaces_msg('* call gcmfaces_lines_zonal : determine grid lines that closely follow');
    gcmfaces_msg('parallel lines and will be used in zonal mean and overturning computations','  ');
end;
if strcmp(choiceV3orV4,'v4'); gcmfaces_lines_zonal; else; gcmfaces_lines_zonal([-75:75]'); end;
if myenv.verbose>0;
    gcmfaces_msg('* call gcmfaces_lines_transp : determine grid lines that closely follow');
    gcmfaces_msg('great circles and will be used to compute transsects transports','  ');
end;
eval(['[lonPairs,latPairs,names]=line_greatC_TUV_MASKS_' choiceV3orV4 ';']);
gcmfaces_lines_transp(lonPairs,latPairs,names);
RF=squeeze(mygrid.RF)';

if myenv.verbose>0;
    gcmfaces_msg('* create directory for storing results to file');
end;
dirOut=[dirIn 'matlabDiags/']; 
if ~isdir(dirOut); eval(['mkdir ' dirOut ';']); end;

%%%%%%%%%%%%%%%%%
%do computations:
%%%%%%%%%%%%%%%%%

listFld=dir([dirIn 'DDtheta.00*data']);
listTimes=[]; for tt=1:length(listFld); listTimes=[listTimes;str2num(listFld(tt).name(9:end-5))]; end;

for setDiags=1:2
    
    for ttt=1:length(listTimes);
        
        tt=listTimes(ttt);
%         tic;
        
        if setDiags==1;
            if myenv.verbose>0; gcmfaces_msg('* call rdmds2gcmfaces : load velocity fields');end;
            fileFld='DDuvel'; msk=mygrid.hFacC; fldU=rdmds2gcmfaces([dirIn fileFld],tt); fldU=mean(fldU,4); fldU(msk==0)=NaN;
            fileFld='DDvvel'; msk=mygrid.hFacC; fldV=rdmds2gcmfaces([dirIn fileFld],tt); fldV=mean(fldV,4); fldV(msk==0)=NaN;
            if myenv.verbose>0; gcmfaces_msg('* call calc_barostream : comp. barotropic stream function');end;
            [fldBAR]=calc_barostream(fldU,fldV);
            if myenv.verbose>0; gcmfaces_msg('* call calc_overturn : comp. overturning stream function');end;
            [fldOV]=calc_overturn(fldU,fldV);
            if myenv.verbose>0; gcmfaces_msg('* call calc_transports : comp. transects transports');end;
            [fldTRANSPORTS]=1e-6*calc_transports(fldU,fldV,mygrid.LINES_MASKS,{'dh','dz'});
            listDiags='fldBAR fldOV fldTRANSPORTS';
        elseif setDiags==2;
            if myenv.verbose>0; gcmfaces_msg('* load tracer and transports fields');end;
            fileFld='DDtheta'; msk=mygrid.hFacC; fldT=rdmds2gcmfaces([dirIn fileFld],tt); fldT=mean(fldT,4); fldT(msk==0)=NaN;
            fileFld='DDsalt'; msk=mygrid.hFacC; fldS=rdmds2gcmfaces([dirIn fileFld],tt); fldS=mean(fldS,4); fldS(msk==0)=NaN;
            fileFld='ADVx_TH'; msk=mygrid.hFacW; fldADVTX=rdmds2gcmfaces([dirIn fileFld],tt); fldADVTX=mean(fldADVTX,4); fldADVTX(msk==0)=NaN;
            fileFld='ADVy_TH'; msk=mygrid.hFacS; fldADVTY=rdmds2gcmfaces([dirIn fileFld],tt); fldADVTY=mean(fldADVTY,4); fldADVTY(msk==0)=NaN;
            fileFld='ADVx_SLT'; msk=mygrid.hFacW; fldADVSX=rdmds2gcmfaces([dirIn fileFld],tt); fldADVSX=mean(fldADVSX,4); fldADVSX(msk==0)=NaN;
            fileFld='ADVy_SLT'; msk=mygrid.hFacS; fldADVSY=rdmds2gcmfaces([dirIn fileFld],tt); fldADVSY=mean(fldADVSY,4); fldADVSY(msk==0)=NaN;
            if myenv.verbose>0; gcmfaces_msg('* call calc_zonmean_T : comp. zonal mean temperature');end;
            [fldTzonmean]=calc_zonmean_T(fldT);
            if myenv.verbose>0; gcmfaces_msg('* call calc_zonmean_T : comp. zonal mean salinity');end;
            [fldSzonmean]=calc_zonmean_T(fldS);
            if myenv.verbose>0; gcmfaces_msg('* call calc_MeridionalTransport : comp. meridional heat transport');end;
            [fldMT_H]=1e-15*4e6*calc_MeridionalTransport(fldADVTX,fldADVTY);
            if myenv.verbose>0; gcmfaces_msg('* infer meridional fresh water transport from meridional salt transport');end;
            [fldMT_FW]=1e-6/35*calc_MeridionalTransport(fldADVSX,fldADVSY);%needs revision
            listDiags='fldTzonmean fldSzonmean fldMT_H fldMT_FW';
        end;
        
        fileOut=[dirOut 'set' num2str(setDiags) '_' num2str(tt) '.mat'];
        if myenv.verbose>0; gcmfaces_msg(['* save diagnostics to fileOut = ' fileOut]); end;
        eval(['save ' fileOut ' ' listDiags ';']);
%         fprintf([num2str(ttt) '/' num2str(length(listTimes)) ' done in ' num2str(toc) '\n']);
        
    end;%for ttt=1:length(listTimes);
end;%for setDiags=1:2

if myenv.verbose>0;
    gcmfaces_msg('*** leaving basic_diags_compute_v3_or_v4');
    gcmfaces_msg('===============================================','');
end;

