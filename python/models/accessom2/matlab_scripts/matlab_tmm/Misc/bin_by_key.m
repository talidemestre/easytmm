function [VAR,Z]=bin_by_key(dat,zg)

% USAGE: [VAR,Z]=bin_by_key(dat,zg)
% function to bin data in columns 2:end of dat according to column 1 of dat. 
% The bins are specified by zg and don't have to be of uniform width.
% Binned data is returned in VAR. VAR(:,:,1) is mean and
% VAR(:,:,2) is std deviation. Z is the mid point of each bin.

% Samar Khatiwala (spk@ldeo.columbia.edu)

Z=zg(1:end-1)+diff(zg)/2; % centers of bins; max Z should be > than max expected Z
nz=length(Z);
nv=size(dat,2)-1;
VAR=NaN*ones(nz,nv,2); % matrix to hold bin averaged 'data'

zv=dat(:,1);
for i=1:nz
	k=find(zv>=zg(i) & zv<zg(i+1));
	if ~isempty(k)
		temp=dat(k,2:end);
		for j=1:nv
			jn=find(~isnan(temp(:,j)));
			if ~isempty(jn)
				VAR(i,j,1)=mean(temp(jn,j));
				VAR(i,j,2)=std(temp(jn,j));
			end
		end
	end
end
