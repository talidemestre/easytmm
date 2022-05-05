function areasum = getpolyarea(xp,yp)
% USAGE: area = getpolyarea(xp,yp)
% function to compute area of ocean basin enclosed
% by a polygon defined by its vertices (xp,yp).
% UNITS: area: km^2

% Samar Khatiwala (spk@ldeo.columbia.edu)

if ((xp(end) ~= xp(1)) | (yp(end) ~= yp(1))) % polygon is not closed
	xp(end+1) = xp(1);
	yp(end+1) = yp(1);
end


% Compute bounds of smallest rectangle enclosing the polygon.
xmin = min(xp);
ymin = min(yp);
xmax = max(xp);
ymax = max(yp);
% round to 1/12 degrees
ymin = floor(ymin*12)/12;
xmin = floor(xmin*12)/12;
ymax = ceil(ymax*12)/12;
xmax = ceil(xmax*12)/12;
% get latitude and longitude
lat = ymax:-1/12:ymin;
lon = xmin:1/12:xmax;
lat=lat';
lon=lon';
[X,Y] = meshgrid(lon,lat);
s = size(X,1)*size(X,2);
x = reshape(X,s,1);
y = reshape(Y,s,1);
clear X Y;
% extract point inside or on the desired polygon.
a = inpolygon(x,y,xp,yp);
a = find(a>0);
x = x(a);
y = y(a);
% compute area of each point
ar = maparea(y);
areasum = sum(ar);
