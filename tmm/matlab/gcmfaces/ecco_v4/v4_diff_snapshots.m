function []=v4_diff_snapshots(dirModel,dirMat,fileStart);
%object: compute time derivatives between snapshots that 
%   will be compared with time mean flux terms in budgets
%input:     dirModel is the model directory
%           fileStart is the root of file names (e.g. budg2d_snap_set1)
%result:    create e.g. rate_budg2d_snap_set1 files

fileList=dir([dirModel 'diags/BUDG/' fileStart '.*.data']);
for ii=1:length(fileList)-1;

%1) get the time of fld0 & fld1, & the data precision
fileMeta=[dirModel 'diags/BUDG/' fileList(ii).name(1:end-5) '.meta'];
time0={}; time1={};
fileMeta=[dirModel 'diags/BUDG/' fileList(ii).name(1:end-5) '.meta']; fid0=fopen(fileMeta);
fileMeta=[dirModel 'diags/BUDG/' fileList(ii+1).name(1:end-5) '.meta']; fid1=fopen(fileMeta);
while 1;
  tline = fgetl(fid0);
  if ~ischar(tline), break, end
  if isempty(time0); time0=tline; else; time0=[time0 ' ' tline]; end;
  tline = fgetl(fid1);
  if isempty(time1); time1=tline; else; time1=[time1 ' ' tline]; end;
end
fclose(fid0); fclose(fid1);

eval(time0); time0=timeInterval; clear timeInterval;
eval(time1); time1=timeInterval; clear timeInterval;
dataprec=str2num(dataprec(end-1:end));

%2) get the binary data:
fld0=read2memory([dirModel 'diags/BUDG/' fileList(ii).name],[],dataprec);
fld1=read2memory([dirModel 'diags/BUDG/' fileList(ii+1).name],[],dataprec);

%3) compute the tendency term:
fld2=(fld1-fld0)/(time1-time0);

%4) write to file:
fileMetaOld=[dirModel 'diags/BUDG/' fileList(ii+1).name(1:end-5) '.meta'];
fileMetaNew=[dirMat 'BUDG/rate_' fileList(ii+1).name(1:end-5) '.meta'];
eval(['!\cp ' fileMetaOld ' ' fileMetaNew]);
fileDataNew=[dirMat 'BUDG/rate_' fileList(ii+1).name(1:end-5) '.data'];
write2file(fileDataNew,fld2,dataprec);

end;

