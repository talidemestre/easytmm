function [EmPtot,EmPsurf,EmPrelax]=get_surface_emp_for_virtual_flux(gridFile,boxFile,EmP,Srelax,saltRelaxTime,salinity,zeroNetEmP)

% Compute total E-P for virtual flux:
% E-P = explicit (E-P) + (dz/tau)*(Srelax-S)/Sg
% Fv = TRg*(E-P), E-P in m/s
% d[TR]/dt = ... + Fv/dz

if isempty(Srelax) & isempty(EmP)
  error('Both Srelax and EmP are empty!')
end

if nargin<7
  zeroNetEmP=0;
end

load(gridFile,'dz','da','gridType')

if strcmp(gridType,'llc_v4')
  load(boxFile,'ixBox','iyBox','izBox','volb','nb')
  if ~isempty(Srelax) & ~isempty(EmP)
	if length(Srelax)~=length(EmP)
	  error('Both Srelax and EmP must have the same time dimension!')
	end  
  end  
else
  load(boxFile,'ixBox','iyBox','izBox','volb','nb')
  if ~isempty(Srelax) & ~isempty(EmP)
	if size(Srelax,3)~=size(EmP,3)
	  error('Both Srelax and EmP must have the same time dimension!')
	end  
  end  
end

Ib=find(izBox==1);
nbb=length(Ib);

dzb=gridToMatrix(dz,Ib,boxFile,gridFile);
areab=gridToMatrix(da,Ib,boxFile,gridFile);

if ~isempty(Srelax)
  Ssurfrel=gridToMatrix(Srelax,Ib,boxFile,gridFile,1);  
  nm=size(Ssurfrel,2);
else  
  Ssurfrel=[];
end

if ~isempty(EmP)
%  E-P is in m/s
  EmPsurf=gridToMatrix(EmP,Ib,boxFile,gridFile,1);
  nm=size(EmPsurf,2);
else  
  EmPsurf=[];
end

% "Total" E-P in m/s
EmPtot=zeros([nbb nm]);

if ~isempty(EmP)
  EmPtot=EmPsurf;
end

if ~isempty(Srelax)
  surfaceSalinity=salinity(Ib,:);
  volFrac=volb(Ib)/sum(volb(Ib)); % fractional volume of surface boxes
  meanSurfaceSalinity=mean(volFrac'*surfaceSalinity); % volume weighted, annual mean surface salinity
  EmPrelax=(repmat(dzb,[1 nm])/saltRelaxTime).*(Ssurfrel-surfaceSalinity)/meanSurfaceSalinity;
  EmPtot = EmPtot + EmPrelax;
else
  EmPrelax=[];
end

if zeroNetEmP % ensure that area and annual mean EmP is zero
  EmPtot = EmPtot - mean(areab'*EmPtot)/sum(areab);
  if ~isempty(EmPsurf)
	EmPsurf = EmPsurf - mean(areab'*EmPsurf)/sum(areab);
  end
  if ~isempty(EmPrelax)
	EmPrelax = EmPrelax - mean(areab'*EmPrelax)/sum(areab);
  end    
end
