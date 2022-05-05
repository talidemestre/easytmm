function srp(token,str,filename)

% USAGE: srp(token,str,filename)
% Function to replace token with str in file filename. This 
% function is simply a MATLAB interface to the perl program 
% srp.pl which is assumed to be in your path.

% Samar Khatiwala (spk@ldeo.columbia.edu)

cmd=['!srp ' '"' token '"' ' "' str '"' ' ' filename];
eval(cmd)
