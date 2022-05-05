function nb=getsize(fn)
% USAGE: nb=getsize(filename)
% Simple hack to obtain size (in bytes) of any file

% Samar Khatiwala (spk@ldeo.columbia.edu)

cmd=['!ls -l ' fn ' | awk ''{print $5}'''];
%cmd=['!stat -t ' fn ' | awk ''{print $2}'''];
nb=str2num(evalc(cmd));
