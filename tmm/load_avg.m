%% load in grid data


gridFile=fullfile('grid');
boxFile=fullfile('boxes');
% profilesFile=fullfile(base_path,'profile_data');

load(gridFile,'nx','ny','nz','x','y','z','gridType')
load(boxFile,'nb','izBox')

Ib=find(izBox==1);
Ii=find(izBox~=1);

nbb=length(Ib);
nbi=length(Ii);

[~,a] = system("ls -d archive/output??? | tail -1");
a = a(end-3:end-1);
nyr = 1;
year = (str2double(a)+1)*nyr;
time = year-nyr+1:year;

%% Read in and write time average

fn='Tracer_avg.petsc';
tmptr=readPetscBinVec(fn,-1);
fn='Tracer_bc_avg.petsc';
bc=readPetscBinVec(fn,-1);
nt=size(tmptr,2);
tr=zeros([nb nt]);
tr(Ib,:)=bc;
tr(Ii,:)=tmptr;
Tracer=matrixToGrid(tr,[],boxFile,gridFile);
write2netcdf('Tracer.nc',Tracer,x,y,z,time,'Tracer');

