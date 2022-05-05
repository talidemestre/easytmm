function hp=plotpointswithcolormap(x,y,c,cmap,mspec,msize)

% Function to plot points colored according to a given colormap. 
% This is useful e.g., for plotting data point over a pcolor plot.
% usage: hp=plotpointswithcolormap(x,y,c,cmap,[mspec],[msize]);
% Output is a vector of handles to the points plotted.
% Defaults: 
%          mspec='o'
%          msize=8

% Samar Khatiwala (spk@ldeo.columbia.edu)

if nargin<5
  mspec='o';
end
if nargin<6
  msize=8;
end

ax=caxis;
cmin=ax(1);
cmax=ax(2);
nc=size(cmap,1);

c(c<cmin)=cmin;
c(c>cmax)=cmax;

colormap_index=fix(interp1(linspace(cmin,cmax,nc),[1:nc]',c));

hold on
hp=zeros(length(x),1);
for i=1:length(x)
  hp(i)=plot(x(i),y(i),mspec,'markersize',msize,'markeredgecolor','k','markerfacecolor',cmap(colormap_index(i),:));
end
