function areasum = getrectarea(xpyp)

% USAGE: area = getrectarea([ymin ymax xmin xmax])
% function to compute area of ocean basin enclosed
% by a RECTANGLE defined by its  bottom,top, left and right.
% xpyp is a vector with components [ymin ymax xmin xmax]. 
% UNITS: area: km^2

% Samar Khatiwala (spk@ldeo.columbia.edu)

% round to 1/12 degrees
ymin = floor(xpyp(1)*12)/12
xmin = floor(xpyp(3)*12)/12
ymax = ceil(xpyp(2)*12)/12
xmax = ceil(xpyp(4)*12)/12
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
% compute area of each point
ar = maparea(y);
areasum = sum(ar);
