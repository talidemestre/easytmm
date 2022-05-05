function fldb=interp_2dfield(fld,lon,lat,Xb,Yb)

if nargin~=5
  error('ERROR: Must pass 5 arguments!')
end
  
myfld=fld;
[nx,ny,nt]=size(fld);

[n1,n2]=size(lon);

if n2>1 % if lon/lat are 2-d use griddata
  nbb=length(Xb);
  fldb=repmat(0,[nbb nt]);
  lon1=lon(:);
  lat1=lat(:);
  for it=1:nt
	tmpfld=myfld(:,:,it);
	tmpfld=tmpfld(:);
	ko=find(~isnan(tmpfld));  
	fldb(:,it)=griddatan([lon1(ko) lat1(ko)],tmpfld(ko),[Xb Yb],'linear');
%   get rid of NaNs  
	k1=find(isnan(fldb(:,it)));
	if ~isempty(k1)
	  fldb(k1,it)=griddatan([lon1(ko) lat1(ko)],tmpfld(ko),[Xb(k1) Yb(k1)],'nearest');  
	end  
  end 

else
% periodically extend
  dl=lon(2)-lon(1);
  lon=[lon(1)-dl;lon;lon(end)+dl]; 

  fldtmp=repmat(0,[nx+2 ny nt]);
  fldtmp(2:end-1,:,:)=myfld;
  for it=1:nt
	fldtmp(:,:,it)=[myfld(end,:,it);myfld(:,:,it);myfld(1,:,it)];
  end

  nbb=length(Xb);
  fldb=repmat(0,[nbb nt]);
  for it=1:nt
	fldb(:,it)=interpn(lon,lat,fldtmp(:,:,it),Xb,Yb,'linear');
%   get rid of NaNs  
	k1=find(isnan(fldb(:,it)));
	if ~isempty(k1)
	  fldb(k1,it)=interpn(lon,lat,fldtmp(:,:,it),Xb(k1),Yb(k1),'nearest');
	end  
  end

end

% now fix up any remaining NaN's
for it=1:nt
  if any(isnan(fldb(:,it)))  %  get rid of NaN's finding nearest value
	k1=find(isnan(fldb(:,it)));
	k2=find(~isnan(fldb(:,it)));  
	xx=Xb(k2);
	yy=Yb(k2);
	ll=fldb(k2,it);
	for ii=1:length(k1)
	  i=k1(ii);
	  [m,j]=min(abs(xx-Xb(i))+abs(yy-Yb(i)));
	  fldb(i,it)=ll(j);
	end
  end
end
