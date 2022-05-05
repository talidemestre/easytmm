function i=find_on_plot(x,y)

% Function i=find_on_plot(x,y) finds the index of the point 
% from the vector (x,y) closest (Cartesian distance) to the point 
% selected by ginput.

% Samar Khatiwala (spk@ldeo.columbia.edu)

[xc,yc]=ginput(1);
r=((x-xc).^2)+((y-yc).^2);
[m i] = min(r);
