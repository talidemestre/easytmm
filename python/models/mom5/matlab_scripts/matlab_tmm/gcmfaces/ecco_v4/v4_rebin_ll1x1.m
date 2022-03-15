function [fldOut]=v4_rebin_ll1x1(fldIn,pType);
%object : rebin a field (extensive or intensive)
%         from llc90 grid to a 1x1 lat-lon grid
%input :  fldIn is the variable of interest
%         pType is 'extensive' or 'intensive'
%output : fldOut is the rebined varible

gcmfaces_global; global mytri;

%store gcmfaces grid
mygrid_refgrid=mygrid; mytri_refgrid=mytri;

%compute/load 1 degree lat-lon grid
global mygrid_latlon mytri_latlon;
if isempty(mygrid_latlon);
  lon=[-179.5:179.5]; lat=[-89.5:89.5];
  [lat,lon] = meshgrid(lat,lon);mygrid_latlon.nFaces=1;
  mygrid_latlon.XC=gcmfaces({lon}); mygrid_latlon.YC=gcmfaces({lat});
  mygrid_latlon.dirGrid='none';
  mygrid_latlon.fileFormat='straight';
  mygrid_latlon.ioSize=size(lon);

  mygrid=mygrid_latlon; gcmfaces_bindata; mytri_latlon=mytri;

  mygrid=mygrid_refgrid; mytri=mytri_refgrid;
end;

%compute (intermediate) high resolution grid
global hr;
if isempty(hr);
  hr.nIncrease=4;
  %increased resolution for XC/YC
  for kk=1:2;
    if kk==1; 
      tmp0=exp(i*mygrid.XC*pi/180);
    else;
      tmp0=exp(i*mygrid.YC*pi/180);
    end;
    %add velocity points and vorticity points
    tmp00=exch_T_N(tmp0); tmp00(tmp00==0)=NaN;
    tmp00=dbl_res(tmp00,0);
    for ff=1:5; tmp00{ff}=tmp00{ff}(2:end-1,2:end-1); end;
    %linearly interpolate to higher resolution
    dx=1/hr.nIncrease;
    tmp000=tmp00;
    for ff=1:5;
    tmp1=tmp00{ff};
    [n1,n2]=size(tmp1); n1=(n1-1)/2; n2=(n2-1)/2;
    [xi,yi]=meshgrid([0:0.5:n2],[0:0.5:n1]);
    [xo,yo]=meshgrid([dx/2:dx:n2-dx/2],[dx/2:dx:n1-dx/2]);
    tmp2=interp2(xi,yi,tmp1,xo,yo,'linear');
    tmp000{ff}=tmp2;
    end;
    if kk==1; hr.XC=180/pi*angle(tmp000); else; hr.YC=180/pi*angle(tmp000); end;
  end;
  %increased resolution for RAC
  hr.RAC=mygrid.RAC;
  for ff=1:5;
    tmp1=mygrid.RAC{ff};
    tmp2=repmat(tmp1(:)',[hr.nIncrease 1]);
    tmp3=reshape(tmp2(:),[hr.nIncrease*size(tmp1,1) size(tmp1,2)]); 
    tmp1=tmp3';
    tmp2=repmat(tmp1(:)',[hr.nIncrease 1]);
    tmp3=reshape(tmp2(:),[hr.nIncrease*size(tmp1,1) size(tmp1,2)]);    
    hr.RAC{ff}=tmp3'/hr.nIncrease/hr.nIncrease;
  end;
  %put in vector form
  hr.XC=convert2array(hr.XC); hr.XC=hr.XC(:);
  hr.YC=convert2array(hr.YC); hr.YC=hr.YC(:);
  hr.RAC=convert2array(hr.RAC); hr.RAC=hr.RAC(:);
end;

%main computation:
mygrid=mygrid_latlon; mytri=mytri_latlon;
fldOut=repmat(mygrid.XC,[1 1 size(fldIn{3},3)]);
for kk=1:size(fldIn{3},3);
  %increased resolution for fldIn
  fldHr=NaN*fldIn(:,:,1);
  for ff=1:5;
    tmp1=fldIn{ff}(:,:,kk);
    tmp2=repmat(tmp1(:)',[hr.nIncrease 1]);
    tmp3=reshape(tmp2(:),[hr.nIncrease*size(tmp1,1) size(tmp1,2)]);
    tmp1=tmp3';
    tmp2=repmat(tmp1(:)',[hr.nIncrease 1]);
    tmp3=reshape(tmp2(:),[hr.nIncrease*size(tmp1,1) size(tmp1,2)]);
    fldHr{ff}=tmp3';
  end;
  %put data in vector form
  mygrid=mygrid_refgrid; mytri=mytri_refgrid;
  fldHr=convert2array(fldHr); fldHr=fldHr(:);
  mskHr=1*(~isnan(fldHr)); fldHr(isnan(fldHr))=0;

  %bin average to lat-lon grid
  mygrid=mygrid_latlon; mytri=mytri_latlon;
  if strcmp(pType,'intensive');
    [fldOut(:,:,kk),COUNT]=gcmfaces_bindata(hr.XC,hr.YC,hr.RAC.*mskHr.*fldHr);
    [mskOut,COUNT]=gcmfaces_bindata(hr.XC,hr.YC,hr.RAC.*mskHr);
    mskOut(mskOut==0)=NaN;
    fldOut(:,:,kk)=fldOut(:,:,kk)./mskOut;
  else;
    [tmpOut,COUNT]=gcmfaces_bindata(hr.XC,hr.YC,mskHr.*fldHr);
    [mskOut,COUNT]=gcmfaces_bindata(hr.XC,hr.YC,mskHr);
    tmpOut(mskOut==0)=NaN;
    fldOut(:,:,kk)=tmpOut/hr.nIncrease/hr.nIncrease;
  end;
end;

%result in array format
fldOut=fldOut{1};

%restore gcmfaces grid
mygrid=mygrid_refgrid; mytri=mytri_refgrid;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [obsOut]=dbl_res(obs,extendNaN);
%object:    use neighbor average to double the fields resolution
%inputs:    lon,lat,fld are the gridded product arrays, with
%               NaN for missing values in fld.
%           extendNaN states whether between a real and a NaN
%               we add a NaN (extendNaN==1) or a real (extendNaN~=1)
%outputs:   lonOut,latOut,fldOut are the x2 resolution arrays
%

obsOut=obs;

for ff=1:5;
    tmpA=obs{ff};

    %1) zonal direction:
    tmpB=nanmean2flds(tmpA(1:end-1,:),tmpA(2:end,:),extendNaN);
    tmpC=ones(size(tmpA,1)*2-1,size(tmpA,2));
    tmpC(1:2:end,:)=tmpA;
    tmpC(2:2:end-1,:)=tmpB;

    %2) meridional direction:
    tmpB=nanmean2flds(tmpC(:,1:end-1),tmpC(:,2:end),extendNaN);
    tmpA=ones(size(tmpC,1),size(tmpC,2)*2-1);
    tmpA(:,1:2:end)=tmpC;
    tmpA(:,2:2:end-1)=tmpB;

    %3) store field:
    obsOut{ff}=tmpA;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [fld]=nanmean2flds(fld1,fld2,extendNaN);
%object:    compute the average of two fields, accounting for NaNs
%inputs:    fld1 and fld2 are the two fields
%           if extendNaN==1 the result is NaN if either fld1 or fld2 is NaN.
%               Otherwise the result is real if either fld1 or fld2 is real.

if extendNaN==1;
    fld=(fld1+fld2)/2;
else;
    msk1=~isnan(fld1); fld1(isnan(fld1))=0;
    msk2=~isnan(fld2); fld2(isnan(fld2))=0;
    fld=fld1+fld2;
    msk=msk1+msk2;
    msk(msk==0)=NaN;
    fld=fld./msk;
end;


