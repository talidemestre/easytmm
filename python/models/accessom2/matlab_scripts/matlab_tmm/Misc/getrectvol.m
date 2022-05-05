function [volsum,areasum,avgdepth] = getrectvol(xpyp,zmin)
% USAGE: [volume,area,average_depth] = getrectvol([ymin ymax xmin xmax],zmin)
% function to compute volume of ocean basin enclosed
% by a RECTANGLE defined by its  bottom,top, left and right, and
% below zmin. (zmin >= 0). xpyp is a vector with components
% [ymin ymax xmin xmax]. If you call getrectvol with only 1 argument
% zmin is assumed zero.
% UNITS: volume: km^3; area: km^2; average_depth: m;

% Samar Khatiwala (spk@ldeo.columbia.edu)

if (nargin < 2)
	zmin = 0;
end

% round to 1/12 degrees
ymin = floor(xpyp(1))
xmin = floor(xpyp(3))
ymax = ceil(xpyp(2))
xmax = ceil(xpyp(4))

% extract bathymetry
[Z,lat,lon]=etopo5(xpyp);
if ((xmin<0) & (xmax>=0))
	Z = Z(:,2:end);
end
lat=lat';
lon=lon';
lat = flipud(lat);
[X,Y] = meshgrid(lon,lat);
s = size(Z,1)*size(Z,2);
z = reshape(Z,s,1);
x = reshape(X,s,1);
y = reshape(Y,s,1);
clear Z X Y;
% exctract only those point with depth <= zmin. This will
% also eliminate all points on land.
a = find(z <= -zmin);
z = abs(z(a));
x = x(a);
y = y(a);
% compute area of each point
ar = maparea(y);
areasum = sum(ar);
vol = (ar.*(z-zmin))/1000;
volsum = sum(vol);
avgdepth = mean(z);
