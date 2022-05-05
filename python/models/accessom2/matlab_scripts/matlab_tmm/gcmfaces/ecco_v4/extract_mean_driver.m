function []=extract_mean_driver(runName,dirOut);
%object: uses extact_mean to the complete list of diags for solution
%input:	runName is the solution directory (e.g. 'iter3/')
%	dirOut is the directory where to put the mean ([runName '/extracts_mean/'] by default)

if isempty(whos('dirOut')); 
  dirOut0=[runName 'extracts_mean/'];
else;
  dirOut0=dirOut;
end;

if isempty(dir(dirOut0)); mkdir(dirOut0); end;
if isempty(dir([dirOut0 'diags'])); mkdir([dirOut0 'diags']); end;
if isempty(dir([dirOut0 'mat'])); mkdir([dirOut0 'mat']); end;

dirIn=[runName '/diags/TRSP/'];
dirOut=[dirOut0 '/diags/TRSP/'];
prec=32; recs=[1:228];
listNames={'trsp_3d_set1','trsp_3d_set2'};
for jj=1:length(listNames);
 listNames{jj}
 extract_mean(dirIn,dirOut,listNames{jj},prec,recs);
end;

dirIn=[runName '/diags/STATE/'];
dirOut=[dirOut0 '/diags/STATE/'];
prec=32; recs=[1:228];
listNames={'state_2d_set1','state_3d_set1'};
for jj=1:length(listNames);
 listNames{jj}
 extract_mean(dirIn,dirOut,listNames{jj},prec,recs);
end;

listNames={'budg2d_hflux_set1','budg2d_hflux_set2','budg2d_zflux_set1','exf_zflux_set1'};
dirIn=[runName '/diags/BUDG/'];
dirOut=[dirOut0 '/diags/BUDG/'];
prec=64; recs=[2:992];
for jj=1:length(listNames);
 listNames{jj}
 extract_mean(dirIn,dirOut,listNames{jj},prec,recs);
end;

listNames={'rate_budg2d_snap_set1','rate_budg2d_snap_set2'};
dirIn=[runName '/mat/BUDG/'];
dirOut=[dirOut0 '/mat/BUDG/'];
prec=64; recs=[1:991];
name='trsp_3d_set2';
for jj=1:length(listNames);
 listNames{jj}
 extract_mean(dirIn,dirOut,listNames{jj},prec,recs);
end;


