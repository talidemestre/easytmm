function [x,y,z] = set2nan(xc,yc,x1,y1,z1)

% set value in vectors x1,y1 to NaN.
% USAGE: [x y] = set2nan(xc,yc,x1,y1)
% This function matches value xc in vector x1, and value yc
% in vector y1. If both values match the same corresponding
% index then those values in x1,y1 are set to NaN and
% returned as the vectors x,y. Useful for selecting points
% on a graph to set to nan.

% Samar Khatiwala (spk@ldeo.columbia.edu)

x = x1;
y = y1;
z = z1;
xt = ones(size(x1))*xc;
yt = ones(size(y1))*yc;
% [xt(1) yt(1)]
[m i] = min(abs(x1-xt));
[m j] = min(abs(y1-yt));
% [x1(i) y1(j)]
% [xc yc]
if (i==j)
  x(i)=NaN;
  y(i)=NaN;
  z(i)=NaN;
end

