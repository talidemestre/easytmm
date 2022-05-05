function [Ir,Ip,Irr,Ir_prev,Ip_prev,Ib,Ib_prev]=calc_profile_indices(boxFile,isCoarseGrained)

% Function to compute indices of boxes arranged by vertical profile
% USAGE:
%  [Ir,Ip,Irr,Ir_prev,Ip_prev,Ib,Ib_prev]=calc_profile_indices(boxFile,isCoarseGrained)
% Input: 
%  boxFile: path to 'boxes.mat' file
%  isCoarseGrained: flag indicating whether boxFile refers to a coarse grained system.
% Output:
%  Ir: index vector of boxes after sorting by vertical profiles
%  Ip: cell array containing indices of each vertical profile after sorting. 
%      e.g., if TR is a vector of tracer concentrations that has already been sorted 
%      by profiles, then TR(Ip{3}) returns a vector of tracer concentrations for the 3d 
%      vertical profile.
%  Irr: index vector that takes a sorted vector back to its original arrangement
%      e.g., if TR is a vector of tracer concentrations that has already been sorted 
%      by profiles, then TR(Irr) returns it to its original unsorted arrangement.
%  Ir_prev: index vector that rearranges a vector (in its original arrangement) to one sorted by profiles
%      e.g., if TR is a vector of tracer concentrations in its original arrangement, then TR(Ir_prev) 
%      rearranges it by vertical profile.
%  Ip_prev: cell array indices of each vertical profile before sorting
%      e.g., if TR is a vector of tracer concentrations in its original arrangement, then TR(Ip_prev{3}) 
%      returns a vector of tracer concentrations for the 3d vertical profile.
%  Ib: indices of surface grid boxes after sorting
%  Ib_prev: indices of surface grid boxes before sorting

if nargin<2
  isCoarseGrained=0;
end  

if isCoarseGrained
  % NOTE: we use Xbox and Ybox here rather than the nominal variable since the latter 
  % don't uniquely locate a box in the horizontal. But we rename them to Xboxnom and 
  % Xboxnom to simplify the rest of the code.
  load(boxFile,'Xbox','Ybox','Zboxnom','nb');    
  zsurf=min(Zboxnom);
  Xboxnom=Xbox;
  Yboxnom=Ybox;
  izBox=zeros(1,nb);
  izBox(Zboxnom==zsurf)=1;
%   Ib=find(Zboxnom==zsurf);
else
  load(boxFile,'Xboxnom','Yboxnom','Zboxnom','izBox','nb')
%   Ib=find(izBox(1,:)==1)';
end  

Ib=find(izBox(1,:)==1)';
nbb=length(Ib);

% Compute indexing to rearrange all objects by profile
for is=1:nbb
  ibs=Ib(is);
  Ip{is}=find(Xboxnom==Xboxnom(ibs) & Yboxnom==Yboxnom(ibs));
  [zp,izp]=sort(Zboxnom(Ip{is}));
  Ip{is}=Ip{is}(izp);
end
Ir=cat(1,Ip{:});

% save these for later
Ip_prev=Ip;
Ir_prev=Ir;
Ib_prev=Ib;

% now rearrange
Xboxnom=Xboxnom(Ir);
Yboxnom=Yboxnom(Ir);
Zboxnom=Zboxnom(Ir);

izBox=izBox(Ir);
Ib=find(izBox(1,:)==1)';

% if isCoarseGrained
%   Ib=find(Zboxnom==zsurf);
% else
%   izBox=izBox(Ir);
%   Ib=find(izBox(1,:)==1)';
% end
[tmp,Irr]=sort(Ir); % Irr takes a rearranged vector back to its original arrangement
clear Ip
for is=1:nbb
  ibs=Ib(is);
  Ip{is}=find(Xboxnom==Xboxnom(ibs) & Yboxnom==Yboxnom(ibs));
  [zp,izp]=sort(Zboxnom(Ip{is}));
  Ip{is}=Ip{is}(izp);
end
Ir=cat(1,Ip{:});  
