function [Iin,Iout]=get_indices(Tdata,Tin)

% USAGE: [Iin,Iout]=get_indices(Tdata,Tin)
% Function to compute indices of values in vector Tin 
% that are present in the vector Tdata. The returned indices, 
% Iin, are referenced to the vector Tdata.
% The function will also compute indices of values in 
% vector Tdata that are absent from vector Tin. The returned 
% indices, Iout, are referenced to the vector Tdata.

% Samar Khatiwala (spk@ldeo.columbia.edu)

Iin=[];
for it=1:length(Tin)
%   Iin(it)=find(Tin(it)==Tdata); % index to Tdata
  Iin=[Iin;find(Tin(it)==Tdata)]; % index to Tdata
end
Iin=Iin(:);

if length(Iin)==length(Tin)
  if ~isempty(find(Tdata(Iin)~=Tin))
    disp('Warning: some values of Tin missing in Tdata')
  end
else
  disp('Warning: some values of Tin missing in Tdata')
end

if nargout>1
  Iout=[];
  for it=1:length(Tdata)
    if isempty(find(Tdata(it)==Tin))
      Iout=[Iout;it];
    end    
  end
  Iout=Iout(:);
end
