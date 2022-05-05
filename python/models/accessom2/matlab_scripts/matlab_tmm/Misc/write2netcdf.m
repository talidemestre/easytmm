function write2netcdf(netcdfFileName,data,x,y,z,t,varName,units,dimNames,dimUnits)

% Simple function to write tracer fields to a netcdf file. This function will 
% overwrite any existing file.
% USAGE: write2netcdf(fileName,dataArray,x,y,z,t,variableName,[units],[dimNames],[dimUnits])
% For 2-d data, pass z=[].

if size(x,2)~=1 % 2-d array
  Xis2D=1;
else
  Xis2D=0;
end

if isempty(z)
  haveZ=0;
else
  haveZ=1;
end

if isempty(t)
  haveTime=0;
else
  haveTime=1;
end

haveUnits=0;
if nargin>7 && ~isempty(units)
  haveUnits=1;
end

haveDimNames=0;
if nargin>8 && ~isempty(dimNames)
  haveDimNames=1;
end

haveDimUnits=0;
if nargin>9 && ~isempty(haveDimUnits)
  haveDimUnits=1;
end

if haveZ
  [nx,ny,nz,nt]=size(data);
else
  [nx,ny,nt]=size(data);
end
 
% create file
ncid = netcdf.create(netcdfFileName,'CLOBBER');

% define dimensions
if haveDimNames
  xname=dimNames{1};
  yname=dimNames{2};
  if haveZ
    zname=dimNames{3};
  end
  if haveTime
    tname=dimNames{4};
  end  
else
  xname='Longitude';
  yname='Latitude';
  if haveZ
    zname='Depth';
  end
  if haveTime
    tname='Time';
  end  
end

if haveDimUnits
  xunit=dimUnits{1};
  yunit=dimUnits{2};
  if haveZ
    zunit=dimUnits{3};
  end
  if haveTime
    tunit=dimUnits{4};
  end  
else
  xunit='degrees_east';
  yunit='degrees_north';
  if haveZ
    zunit='meter';
  end
  if haveTime
    tunit='year';
  end  
end

lon_dimid = netcdf.defDim(ncid,xname,nx);
lat_dimid = netcdf.defDim(ncid,yname,ny);
if haveZ
  dep_dimid = netcdf.defDim(ncid,zname,nz);
end  
if haveTime
  time_dimid = netcdf.defDim(ncid,tname,nt);
end

% Define the coordinate variables
if Xis2D
  lon_varid = netcdf.defVar(ncid,xname,'double',[lon_dimid lat_dimid]);     
else
  lon_varid = netcdf.defVar(ncid,xname,'double',lon_dimid);     
end
if Xis2D
  lat_varid = netcdf.defVar(ncid,yname,'double',[lon_dimid lat_dimid]);     
else
  lat_varid = netcdf.defVar(ncid,yname,'double',lat_dimid);     
end
if haveZ
  dep_varid = netcdf.defVar(ncid,zname,'double',dep_dimid);
end  
if haveTime
  time_varid = netcdf.defVar(ncid,tname,'double',time_dimid);
  if haveZ
    data_varid1 = netcdf.defVar(ncid,varName,'double',[lon_dimid lat_dimid dep_dimid time_dimid]);
  else
    data_varid1 = netcdf.defVar(ncid,varName,'double',[lon_dimid lat_dimid time_dimid]);
  end  
else
  if haveZ
    data_varid1 = netcdf.defVar(ncid,varName,'double',[lon_dimid lat_dimid dep_dimid]);
  else
    data_varid1 = netcdf.defVar(ncid,varName,'double',[lon_dimid lat_dimid]);
  end    
end

netcdf.putAtt(ncid,data_varid1,'missing_value',NaN);
if haveUnits
  netcdf.putAtt(ncid,data_varid1,'units',units);
end

netcdf.putAtt(ncid,lon_varid,'units',xunit);
netcdf.putAtt(ncid,lat_varid,'units',yunit);
if haveZ
  netcdf.putAtt(ncid,dep_varid,'units',zunit);
end  
if haveTime
  netcdf.putAtt(ncid,time_varid,'units',tunit);
end

netcdf.endDef(ncid);

% write the coordinate variables
netcdf.putVar(ncid,lon_varid,x);
netcdf.putVar(ncid,lat_varid,y);
if haveZ
  netcdf.putVar(ncid,dep_varid,z);
end  
if haveTime
  netcdf.putVar(ncid,time_varid,t);
end

% write the data
netcdf.putVar(ncid,data_varid1,data);

netcdf.close(ncid)   
