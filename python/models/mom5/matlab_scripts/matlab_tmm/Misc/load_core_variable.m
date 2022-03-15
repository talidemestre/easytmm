function [fldout,T,lon,lat]=load_core_variable(fn,varName,Xb,Yb,doMonthlyAvg)

% function to load variable from CORE data set
if verLessThan('matlab','7.8')
  lon=getnc(fn,'LON');
  lat=getnc(fn,'LAT');  
  T=getnc(fn,'TIME');
  fld=getnc(fn,varName,-1,-1,-1,[3 2 1]); % x,y,t
else
  lon = ncread(fn,'LON');
  lat = ncread(fn,'LAT');
  T = ncread(fn,'TIME');
  fld = ncread(fn,varName);
end

i=find(lon>360);   
lon(i)=lon(i)-360;
[d,il]=sort(lon);         
lon=lon(il);

fld=fld(il,:,:);

[nx,ny,nt]=size(fld);

if nargin==5
  if doMonthlyAvg==1
	if nt==360 % daily data
	  fld=reshape(fld,[nx ny 30 12]);
	  fldmean=squeeze(mean(fld,3));       
	elseif nt==365 % daily data
	  daysinmonth=[31 28 31 30 31 30 31 31 30 31 30 31];
	  idx=[0 cumsum(daysinmonth)];
	  fldmean=zeros([nx ny 12]);
	  for im=1:12
		fldmean(:,:,im)=mean(fld(:,:,idx(im)+1:idx(im+1)),3);
	  end
	elseif nt==1460 % 6-hourly data
	  fld=reshape(fld,[nx ny 4 365]);
	  fld=squeeze(mean(fld,3));	
	  daysinmonth=[31 28 31 30 31 30 31 31 30 31 30 31];
	  idx=[0 cumsum(daysinmonth)];
	  fldmean=zeros([nx ny 12]);
	  for im=1:12
		fldmean(:,:,im)=mean(fld(:,:,idx(im)+1:idx(im+1)),3);
	  end
	end
	fld=fldmean;
  end
  [nx,ny,nt]=size(fld); % update size
  T=[0.5:1:11.5]';
end

if nargin>2 % interpolate to desired grid points
  if isempty(Xb) | isempty(Yb)
    error('ERROR: must pass valid grid points to interpolate to!')
  end  
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
