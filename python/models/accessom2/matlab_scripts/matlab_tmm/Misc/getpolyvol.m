function [volsum,areasum,avgdepth] = getpolyvol(xp,yp,zmin)
% USAGE: [volume,area,average_depth] = getpolyvol(xp,yp,zmin)
% function to compute volume of ocean basin enclosed
% by a polygon defined by its vertices (xp,yp), and
% below zmin. (zmin >= 0). The polygon need not be
% CLOSED. If you call getpolyvol with only 2 arguments
% zmin is assumed zero.
% UNITS: volume: km^3; area: km^2; average_depth: m;

% Samar Khatiwala (spk@ldeo.columbia.edu)

if ((xp(end) ~= xp(1)) | (yp(end) ~= yp(1))) % polygon is not closed
	xp(end+1) = xp(1);
	yp(end+1) = yp(1);
end

if (nargin < 3)
	zmin = 0;
end

% Compute bounds of smallest rectangle to extract from etopo5.
xmin = min(xp)
ymin = min(yp)
xmax = max(xp)
ymax = max(yp)
% round to 1 degree
ymin = floor(ymin)
xmin = floor(xmin)
ymax = ceil(ymax)
xmax = ceil(xmax)
% extract bathymetry
[Z,lat,lon]=etopo5([ymin ymax xmin xmax]);
if ((xmin<0) & (xmax>=0))
	Z = Z(:,2:end);
end
lat=lat';
lon=lon';
lat = flipud(lat);
[X,Y] = meshgrid(lon,lat);
[r c]=size(Z);
s = r*c;
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
% extract point inside or on the desired polygon.
a = inpolygon(x,y,xp,yp);
a = find(a>0);
x = x(a);
y = y(a);
z = z(a);
% compute area of each point
ar = maparea(y);
areasum = sum(ar);
vol = (ar.*(z-zmin))/1000;
volsum = sum(vol);
avgdepth = mean(z);
