function avg=boxavg(x,M)

% USAGE: avg = boxavg(x,M)
% Simple box filter of width M

% Samar Khatiwala (spk@ldeo.columbia.edu)

avg=zeros(size(x,1)-M+1,1);
for i=1:M
	avg=avg+x(i:end-M+i);
end
avg=avg/M;
