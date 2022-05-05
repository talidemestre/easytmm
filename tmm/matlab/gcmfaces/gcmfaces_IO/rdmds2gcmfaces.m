function [fldOut]=rdmds2gcmfaces(varargin);
%object:    read with rmds then apply convert2gcmfaces 
%input:     varargin are the options to pass to rdmds (type help rdmds)
%output:    fldOut is a gcmfaces object
%
%note:      an earlier version was expecting nFaces to be passed
%           as the last argument; this is not the case anymore.

v0=rdmds(varargin{1:end}); 
fldOut=convert2gcmfaces(v0);

