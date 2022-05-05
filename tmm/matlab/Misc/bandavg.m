function avg=bandavg(x,nbw)

% function to perform a band average on vector x.
% USAGE: avg=bandavg(x,nbw), where nbw is the bandwidth (in 
% ODD number of grid points). Make sure no NaN's are present.

% Samar Khatiwala (spk@ldeo.columbia.edu)

N=length(x);
numbands=fix(N/nbw);
x=x(1:numbands*nbw);
x=reshape(x,nbw,numbands);
avg=mean(x)';
