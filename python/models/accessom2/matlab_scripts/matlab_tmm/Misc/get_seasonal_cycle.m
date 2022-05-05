function [Fclim,Fanom]=get_seasonal_cycle(F,T)

% [Fclim,Fanom]=get_seasonal_cycle(F,T)
% Compute seasonal cycle of field F using time in vector T
% If F only has 2 dimensions, assume second dimension is time.
% Insert 'y' dimension to conform with rest of function which 
% assumes F represents multiple realizations of a 2-D field.
% Output variables have same class as input variable.
% T is in ensotime

% Samar Khatiwala (spk@ldeo.columbia.edu)

if ndims(F)==2 % F(x,t)
  [nx,nt]=size(F);
  F=reshape(F,[nx 1 nt]);
end

nx=size(F,1);
ny=size(F,2);
nt=size(F,3);

if nt~=length(T)
  error('Error: mismatch between number of slices in F and length of T')
end

% Climatology and anomaly
zz=zeros(class(F));
Fclim=repmat(zz,[nx ny 12]);
Fanom=repmat(zz,[nx ny nt]);
[yy,mm]=enso2yymm(T);
for itm=1:12
  ii=find(mm==itm);
  Fclim(:,:,itm)=mean(F(:,:,ii),3);
  Fanom(:,:,ii)=F(:,:,ii)-repmat(Fclim(:,:,itm),[1 1 length(ii)]);
end

% get rid of fake singleton dimension
Fclim=squeeze(Fclim);
Fanom=squeeze(Fanom);
