function []=grid_load_native_RAZ();
%object:    load NATIVE FORMAT grid information for RAZ, which
%           includes the extra line & column of vorticity points;
%           or derive it as exch_Z(RAZ).
%input/ouput: none; all happens in the mygrid global structure.

gcmfaces_global;

%try default file names first
files=dir([mygrid.dirGrid 'tile*.mitgrid']);

%then try specific names
if isempty(files)&~strcmp(mygrid.XC.gridType,'ll');
    names=input('grid files not found; please specify \n names (e.g. ''grid_cs32*bin'')\n');
    files=dir([mygrid.dirGrid names]);
end;

if ~isempty(files)&~strcmp(mygrid.XC.gridType,'ll');
    %load from files
    
    RAZfull=gcmfaces;
    for iFile=1:mygrid.nFaces;
        [ni,nj]=size(mygrid.XC{iFile});
        tmp1=dir([mygrid.dirGrid files(iFile).name]);
        nf=tmp1.bytes/8/(ni+1)/(nj+1);
        fld=read2memory([mygrid.dirGrid files(iFile).name],[ni+1 nj+1 nf],64);
        RAZfull{iFile}=fld(:,:,10);
    end;
    
    mygrid.RAZfull=RAZfull;
    
elseif ~strcmp(mygrid.XC.gridType,'ll');
    
    fprintf('\n No native grid file was found, so we will fill\n');
    fprintf('corners of RAZfull using a vorticity point exchange.\n');
    global exch_Z_assume_sym;
    fprintf('Choose a method : 0) approximate by neighbor average ? \n');
    exch_Z_assume_sym=input('Choose a method : 1) assume uncertain symetry ? \n');

    mygrid.RAZfull=mygrid.RAZ;
    mygrid.RAZfull=exch_Z(mygrid.RAZ);
    exch_Z_assume_sym=0;%exch_Z_assume_sym should not be used except for RAZ
    
else;%latlon grid 
    mygrid.RAZfull=exch_Z(mygrid.RAZ);
end;


