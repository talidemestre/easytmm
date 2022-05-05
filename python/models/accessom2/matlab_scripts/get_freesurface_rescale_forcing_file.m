base_path=fileparts(fileparts(pwd));
matrix_path=fileparts(pwd);

gridFile=fullfile(base_path,'grid');
boxFile=fullfile(matrix_path,'Data','boxes');

load(boxFile,'nb')
load(gridFile,'gridType')

cmd=['grep NUMEXPTEND ' fullfile(matrix_path,'settmmenv.csh') ' | awk ''{print $3}'''];
maxNumTend=str2num(evalExternalCommand(cmd))

if strcmp(gridType,'llc_v4')
  load(gridFile,'gcmfacesdata')
  nb=sum(nb);
end

Rfs=zeros([nb maxNumTend]);
fn=fullfile(matrix_path,'Runs','Job1','FREESURFFAC');
for im=1:maxNumTend
  ff=rdmds(fn,NaN,'rec',im);
  if strcmp(gridType,'llc_v4')
    FF=grid2gcmfaces(ff,gcmfacesdata);
  end  
  Rfs(:,im)=gridToMatrix(FF,[],boxFile,gridFile);
end

save('Rfs','Rfs')

evalExternalCommand(['mv Rfs.mat ../TMs/']);
