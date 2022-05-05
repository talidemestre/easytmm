function h=plotzcol(x,y,z,sym)

% Function to assign symbol color based on value in z vector.
% USAGE: plotzcol(xdata,ydata,zdata,'symbol')
% xdata, ydata and zdata must be of same length.

% Samar Khatiwala (spk@ldeo.columbia.edu)

i=find(~isnan(x) & ~isnan(y) & ~isnan(z));
x=x(i);
y=y(i);
z=z(i);
l=length(x);
% make into row vectors...
x = reshape(x,1,l);
y = reshape(y,1,l);
z = reshape(z,1,l);
x = [x;x]; 
y = [y;y]; 
z = [z;z]; 
h = mesh(x,y,z,z);
view(2)
if nargin>3,
   set(h,'Marker',sym,'LineStyle','none')
end
% set(gca,'GridLineStyle','none')

