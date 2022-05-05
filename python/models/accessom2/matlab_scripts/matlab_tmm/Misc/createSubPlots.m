function [ha,haveXLabel,haveYLabel]=createSubPlots(m,n,dx,dy,xoff,yoff,dxside,dytop)

% USAGE: [ha,haveXLabel,haveYLabel]=createSubPlots(m,n,dx,dy,xoff,yoff,dxside,dytop)
% Function to create (m,n) subplots with desired spacing dx and dy, optionally offset 
% from the origin by xoff and yoff, and spacing of dxside and dytop on the right side 
% and top, respectively. The function returns a vector of handles, ha, to each subplot 
% in the usual Matlab subplot ordering (i.e., numbers increase along rows starting with 
% the top row). The function also returns vectors haveXLabel and haveYLabel with flags 
% for whether the subplot should have an xlabel and ylabel, respectively. This is useful 
% for omitting axis labels from some subplots (e.g., the y-axis label can be omitted 
% from subplot(1,2,2) and the x-axis label from subplot(2,2,1)).

if nargin<4
  error('ERROR: Must pass at least 4 arguments!')
end
  
% if nargin<8
%   hc=0.25;
% end
% if nargin<7
%   wc=0.25;
% end    
if nargin<8
  dytop=0;
end
if nargin<7
  dxside=0;
end
if nargin<6
  yoff=0;
end
if nargin<5
  xoff=0;
end    

w=(1-xoff-dxside)/n;
h=(1-yoff-dytop)/m;

x=zeros(n,1);
x(1)=xoff;
for j=2:n
  x(j)=x(j-1)+w;
end  
y=zeros(m,1);
y(1)=yoff;
for i=2:m
  y(i)=y(i-1)+h;
end  
y=flipud(y);

pos=cell(m,n);
for j=1:n
  for i=1:m
    pos{i,j}=[x(j) y(i) w-dx h-dy];
%     pos{i,j}=[x(j)+dx y(i)+dy w-2*dx h-2*dy];
  end
end

ha=zeros(m*n,1);
haveXLabel=ones(m*n,1);
haveYLabel=ones(m*n,1);
idx=1;
for i=1:m
  for j=1:n  
    ha(idx)=axes('Position',pos{i,j});
    if j>1
      haveYLabel(idx)=0;
    end
    if i<m
      haveXLabel(idx)=0;
    end      
    idx=idx+1;    
  end
end

% if nargin>4
%   cbarpos.x=((1-xoff)-wc)/2 + xoff;
%   cbarpos.y=((1-yoff)-hc)/2 + yoff;
%   cbarpos.w=wc;
%   cbarpos.h=hc;
% end
