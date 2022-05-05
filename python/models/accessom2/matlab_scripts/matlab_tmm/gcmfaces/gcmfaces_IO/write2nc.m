function []=write2nc(fileOut,fldIn,doCreate,varargin);
%object : write array (not a gcmfaces object) to netcdf file
%inputs : fileOut is the name of the file to be created
%         fldIn is the array to write to disk
%         doCreate is a 0/1 switch; 1 => create file ; 0 => append to file. 
%optional paramaters :
%         can be provided in the form {'name',value}
%         those that are currently active are
%               'descr' is the file description (default '').
%               'fldName' is the nc variable name for fld (default : the outside name of fldIn).
%               'longName' is the corresponding long name (default : '').
%               'units' is the unit of fld (default : '(unknown)').
%               'missval' is the missing value (default : NaN).
%               'fillval' is the fill value (default : NaN).
%               'tim' is a time vector (default : []) if fld has one such dimension.
%               'timName' is the long_name for that dimension (default : 'time index')
%netcdf dimensions : for unspecified (non-singleton) dimensions we will try to make a guess based on 
%         the length of mygrid.RC, mygrid.RF and mygrid.LATS; in case that guess fails
%         we will use 'i1','i2' etc. 

gcmfaces_global;

doCheck=0;%set to one to print stuff to screen

%set more optional paramaters to default values
descr=''; 
fldName=inputname(2); longName=''; 
units='(unknown)'; missval=NaN; fillval=NaN; 
tim=[]; timName='time index'; 

%set more optional paramaters to user defined values
for ii=1:nargin-3;
    if ~iscell(varargin{ii});
        warning('inputCheck:write2nc_1',...
            ['write2nc expects \n'...
            '         its optional parameters as cell arrays. \n'...
            '         Argument no. ' num2str(ii+1) ' was ignored \n'...
            '         Type ''help write2nc'' for details.']);
    elseif ~ischar(varargin{ii}{1});
        warning('inputCheck:write2nc_2',...
            ['write2nc expects \n'...
            '         its optional parameters cell arrays \n'...
            '         to start with character string. \n'...
            '         Argument no. ' num2str(ii+1) ' was ignored \n'...
            '         Type ''help write2nc'' for details.']);
    else;
        if strcmp(varargin{ii}{1},'descr')|...
                strcmp(varargin{ii}{1},'fldName')|...
                strcmp(varargin{ii}{1},'longName')|...
                strcmp(varargin{ii}{1},'units')|...
                strcmp(varargin{ii}{1},'missval')|...
                strcmp(varargin{ii}{1},'fillval')|...
                strcmp(varargin{ii}{1},'tim')|...
                strcmp(varargin{ii}{1},'timName');
            eval([varargin{ii}{1} '=varargin{ii}{2};']);
        else;
            warning('inputCheck:write2nc_3',...
                ['unknown option ''' varargin{ii}{1} ''' was ignored']);
        end;
    end;
end;

%select dimensions of relevance:
nDim=length(size(fldIn));
dimsize=size(fldIn);
for iDim=1:nDim;
  if isfield(mygrid,'LATS'); nLATS=length(mygrid.LATS); else; nLATS=0; end;
  if size(fldIn,iDim)==nLATS;
    dimlist{iDim}='ilat'; 
    dimName{iDim}='latitude';
    dimvec.ilat=mygrid.LATS;
  elseif size(fldIn,iDim)==length(mygrid.RC);
    dimlist{iDim}='idept';
    dimName{iDim}='depth';
    dimvec.idept=-mygrid.RC;
  elseif size(fldIn,iDim)==length(mygrid.RF);
    dimlist{iDim}='idepw';
    dimName{iDim}='depth';
    dimvec.idepw=-mygrid.RF;
  elseif size(fldIn,iDim)==length(tim);
    dimlist{iDim}='itim';
    dimName{iDim}=timName;
    dimvec.itim=tim;
  elseif size(fldIn,iDim)~=1;
    dimlist{iDim}=['i' num2str(iDim)];
    dimName{iDim}=['array index ' num2str(iDim)];
    eval(['dimvec.i' num2str(iDim) '=[1:size(fldIn,iDim)];']);
  end;
end;

%omit singleton dimensions:
ii=find(dimsize~=1);
dimsize=dimsize(ii);
dimlist={dimlist{ii}};
dimName={dimName{ii}};

%check : 
if doCheck;
whos fldIn tim
descr
fldName
longName
units
missval
fillval
timName
dimlist
dimName
dimsize
dimvec
keyboard;
end;

if doCreate;
  %create netcdf file:
  %-------------------
  ncid=nccreate(fileOut,'clobber');

  aa=sprintf([descr '    [file created with gcmfaces_IO/write2nc.m]']);
  ncputAtt(ncid,'','description',aa);
  ncputAtt(ncid,'','date',date);

  ncdefDim(ncid,'itxt',30);
  for dd=1:length(dimlist); ncdefDim(ncid,dimlist{dd},dimsize(dd)); end;

  for dd=1:length(dimlist)1;
    ncdefVar(ncid,dimlist{dd},'double',{dimlist{dd}});
    ncputAtt(ncid,dimlist{dd},'long_name',dimName{dd});
  end;
  ncclose(ncid);

  %fill in the dimensions dimensions values vectors:
  %-------------------------------------------------
  ncid=ncopen(fileOut,'write');
  for dd=1:length(dimlist);
    ncputvar(ncid,dimlist{dd},getfield(dimvec,dimlist{dd}));
  end;
  ncclose(ncid);
end;

%define and fill field:
%----------------------
ncid=ncopen(fileOut,'write');
ncdefVar(ncid,fldName,'double',flipdim(dimlist,2));%note the direction flip
if ~isempty(longName); ncputAtt(ncid,fldName,'long_name',longName); end;
if ~isempty(units); ncputAtt(ncid,fldName,'units',units); end;
ncputAtt(ncid,fldName,'missing_value',missval);
ncputAtt(ncid,fldName,'_FillValue',fillval);
ncputvar(ncid,fldName,fldIn);
ncclose(ncid);


