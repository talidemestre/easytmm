function [fldout,lon,lat]=load_ocmip_variable(ocmip_path,varName,Xb,Yb,doMasking)

if isempty(ocmip_path)
  mydir=fileparts(which(mfilename));
  ocmip_path=fullfile(mydir,'Data');
end

% varName: 'FICE', 'XKW', or 'P'
fn=fullfile(ocmip_path,'gasx_ocmip2.nc');
if verLessThan('matlab','7.8')
  lon=getnc(fn,'LON');
  lat=getnc(fn,'LAT');  
  fld=getnc(fn,varName,-1,-1,-1,[3 2 1]); % x,y,t
  tmask=getnc(fn,'TMASK',-1,-1,-1,[2 1]); % x,y
else
  lon = ncread(fn,'LON');
  lat = ncread(fn,'LAT');
  fld = ncread(fn,varName);
  tmask = ncread(fn,'TMASK');
end

i=find(lon>360);   
lon(i)=lon(i)-360;     
[d,il]=sort(lon);         
lon=lon(il);

[nx,ny,nt]=size(fld);

if nargin<5 || doMasking==1
  l=find(tmask==0); tmask(l)=NaN;

  for it=1:nt
	fld(:,:,it)=fld(:,:,it).*tmask;
  end
end

fld=fld(il,:,:);

if nargin>2 && (~isempty(Xb) && ~isempty(Yb)) % interpolate to desired grid points
  fldb=interp_2dfield(fld,lon,lat,Xb,Yb);  
  if any(isnan(fldb))
    error('ERROR: Problem with interpolation!')
  end
% switch output variables
  lon=Xb;
  lat=Yb;
  fldout=fldb;
else % return the periodically-extended field
% periodically extend
  dl=lon(2)-lon(1);
  lon=[lon(1)-dl;lon;lon(end)+dl]; 

  fldout=repmat(0,[nx+2 ny nt]);
  fldout(2:end-1,:,:)=fld;
  for it=1:nt
	fldout(:,:,it)=[fld(end,:,it);fld(:,:,it);fld(1,:,it)];
  end
end

