function []=extract_mean(dirIn,dirOut,name,prec,recs);
%object : compute mean of diagnotics records (~time mean)
%input:	dirIn is the records directory (e.g. 'iter3/diags/TRSP/')
%	dirOut is the mean dir (e.g. 'iter3_mean/diags/TRSP/')
%	name is the file name start (e.g. 'trsp_3d_set2')
%	prec is the file preciision (e.g. 32)
%	recs is the list of records (e.g. [1:228])
%notes:	the result is e.g. iter3_mean/diags/TRSP/trsp_3d_set2.0000000000.data
%	extract_mean_driver contains a complete call sequence

if isempty(whos('prec')); prec=32; end;
if isempty(whos('name')); name=''; end;

listIn=dir([dirIn name '*data']);
if isempty(whos('recs')); recs=[1:length(listIn)]; end;
nn=length(recs);
listIn=listIn(recs);

%initialize files
if isempty(dir(dirOut)); mkdir(dirOut); end;

fileIn=[listIn(1).name(1:end-5) '.meta'];
ii=strfind(fileIn,'.');
fileOut=[fileIn(1:ii-1) '.0000000000.meta'];
eval(['!\cp -f ' dirIn fileIn ' ' dirOut fileOut]);

fileIn=listIn(1).name;
ll=listIn(1).bytes/prec*8;
ii=strfind(fileIn,'.');
fileOut=[fileIn(1:ii-1) '.0000000000.data'];
fld=0*read2memory([dirIn fileIn],[ll 1],prec);
write2file([dirOut fileOut],fld,prec);

%eval(['!\cp -f ' dirIn fileIn ' ' dirOut fileOut]);

%do the time average:
fld=0*read2memory([dirIn fileIn],[],prec);
for ii=1:nn;
  fld=fld+1/nn*read2memory([dirIn listIn(ii).name],[ll 1],prec);
end;
write2file([dirOut fileOut],fld,prec);



