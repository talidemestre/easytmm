function [Cg,xg,yg,zg,Xg,Yg,Zg]=grid_boxes3d(C,I,boxFile,gridFile,interpType,keepEmptyLayers)

% function to rearrange boxes onto regular grid. No interpolation 
% is done. 
% [Cg,xg,yg,zg]=grid_boxes3d(C,I,boxFile,gridFile)
% rearranges vector C onto grid xg,yg,zg based on nominal box positions.
% I is index vector referenced to ALL boxes, so C=C_all_boxes(I); 
% e.g., if C is tracer at interior points (index vector Ii) use:
% [Cg,xg,yg,zg]=grid_boxes3d(C,Ii,boxFile,gridFile)
% To do 2d gridding: Suppose C is tracer at interior points but only 
% want to grid onto a single depth (zLayer):
% I=find(Zboxnom==zLayer);
% I1=find(Zboxnom(Ii)==zLayer); 
% [Cg,xg,yg,zg]=grid_boxes3d(C(I1),I,boxFile,gridFile); 
% If interpType='reaarange' then the script simply 'rearranges' 
% the elements of C onto the GCM grid. In this case, Cg will be the 
% same size as the GCM grid (in x and y; in z it will still extract only 
% required layers based on 'I'). (This is not generally the case, since 
% GCM boxes with land not not be represented in the matrix model.) 

if nargin<4
  error('ERROR: must pass 4 arguments');
end
if nargin<5
  interpType='rearrange'; % default
end
if nargin<6
  keepEmptyLayers=0; % default is to DELETE empty layers
end  

if strcmp(interpType,'rearrange')
  load(boxFile,'Xboxnom','Yboxnom','Zboxnom','ixBox','iyBox','izBox','nb')
else  
  load(boxFile,'Xboxnom','Yboxnom','Zboxnom','ixb','iyb','izb','nb')
end

load(gridFile,'x','y','z','nx','ny','nz')

if isempty(I)
  I=[1:nb]';
end

if (strcmp(interpType,'linear')+strcmp(interpType,'nearest')+strcmp(interpType,'rearrange')==0)
  error(['interpType=' interpType ': Unknown value'])
end
 
if strcmp(interpType,'rearrange')
  nt=size(C,2);
  xg=x;
  yg=y;
  Zb=Zboxnom(I);
  zg=unique(Zb);
  Cg=repmat(NaN,[nx ny nz nt]);
  tmp=repmat(NaN,[nx ny nz]);  
  idx=sub2ind([nx ny nz],ixBox(I)',iyBox(I)',izBox(I)');
  for it=1:nt
    tmp(idx)=C(:,it);    
	Cg(:,:,:,it)=tmp;
  end  
% Only keep layers with any data
  if ~keepEmptyLayers
    kl=find(ismember(z,zg));
    Cg=Cg(:,:,kl,:);
  end
%   Cg=repmat(NaN,[length(xg) length(yg) length(zg) nt]);
%   for i=1:length(I)
%     ib=I(i); % box number
%     kl=find(zg==Zboxnom(ib)); % layer index
%     for it=1:nt
%       Cg(ixBox(ib),iyBox(ib),kl,it)=C(i,it);
%     end
%   end
  Cg=squeeze(Cg);
else
  Xb=Xboxnom(I);
  Yb=Yboxnom(I);
  Zb=Zboxnom(I);
  xg=unique(Xboxnom);
  yg=unique(Yboxnom);
  zg=unique(Zb);

  if length(zg)>1
    [Xg,Yg,Zg]=meshgrid(xg,yg,zg);

    for k=1:length(zg)
      kl=find(Zb==zg(k));
      for i=1:length(yg)
        for j=1:length(xg)
          kk=find(Xb(kl)==Xg(i,j,k) & Yb(kl)==Yg(i,j,k));
          if isempty(kk)
             Xg(i,j,k)=NaN;
             Yg(i,j,k)=NaN;
             Zg(i,j,k)=NaN;
          end
        end
      end
    end

    Cg=griddata3(Xb,Yb,Zb,C,Xg,Yg,Zg,interpType);
  else
    [Xg,Yg]=meshgrid(xg,yg);

    for i=1:length(yg)
      for j=1:length(xg)
        kk=find(Xb==Xg(i,j) & Yb==Yg(i,j));
        if isempty(kk)
           Xg(i,j)=NaN;
           Yg(i,j)=NaN;
        end
      end
    end

    Cg=griddata(Xb,Yb,C,Xg,Yg,interpType);
    Zg=zg;
  end
end 
