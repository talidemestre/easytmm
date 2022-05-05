function ar = maparea(lat)

% maparea returns the area in km^2 of a 5' by 5' square
% centered at latitude lat (and any longitude).

% Samar Khatiwala (spk@ldeo.columbia.edu)

lat=2*pi/360*abs(lat);
temp = 6.371*6.371*1e6*2*pi*(5/60)/360*2*pi*(5/60)/360;
ar=temp*cos(lat);
