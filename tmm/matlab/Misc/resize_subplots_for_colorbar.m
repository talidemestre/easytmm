function [posf,zf]=resize_subplots_for_colorbar(hp,dim,q,dwc)

% hp: handles to subplots
% dim = 1 (vertical) or 2 (horizontal): direction in which to resize
% q = row (if dim=2) or column (if dim=1) which is resized
% dwc = width of ??

[m,n]=size(hp);

if m==1 || n==1
  singleCol=1;
  hp0=hp(:);
  m=max(m,n);
  n=max(m,n);
else
  singleCol=0;
  if dim==1
    hp0=hp(:,q);
  else
    hp0=hp(q,:)';
  end
end

pos0=get(hp0(1),'position');
pos1=get(hp0(end),'position');

if dim==1
%   xe=pos0(2)+pos0(4);
%   xs=pos1(2);
%   w=xe-xs;
%   dw=w/m;
  for i=1:m
    posp=get(hp0(i),'position');
    x0=posp(1);
    y0=posp(2);
    dx=posp(3);
    dy=posp(4);
    
    y0=y0+i*dwc;
    dy=dy-dwc;
    
    posp=[x0 y0 dx dy];
%     pause
    set(hp0(i),'position',posp);

  end
  zf=y0+dy;
end

if dim==2
%   xe=pos0(2)+pos0(4);
%   xs=pos1(2);
%   w=xe-xs;
%   dw=w/m;
  for j=1:n
    posp=get(hp0(j),'position');
    x0=posp(1);
    y0=posp(2);
    dx=posp(3);
    dy=posp(4);
    
    if j>1
     x0=x0-(j-1)*dwc;
    end
    dx=dx-dwc;
    
    posp=[x0 y0 dx dy];
    
%     pause
    set(hp0(j),'position',posp);
  end
  zf=x0+dx;
end

posf=posp;
