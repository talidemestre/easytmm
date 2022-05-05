% base_path=fileparts(fileparts(pwd));

gridFile='grid';
boxFile='boxes';

load(gridFile,'gridType')

load(boxFile,'Xboxnom','Yboxnom','Zboxnom','izBox','nb')

Ib=find(izBox==1);
nbb=length(Ib);

% Compute indexing to rearrange all objects by profile
Ip=cell(nbb,1);
for is=1:nbb
  ibs=Ib(is);
  Ip{is}=find(Xboxnom==Xboxnom(ibs) & Yboxnom==Yboxnom(ibs));
  [zp,izp]=sort(Zboxnom(Ip{is}));
  Ip{is}=Ip{is}(izp);
end
Ir=cat(1,Ip{:});
% save these for later
Ip_pre=Ip;
Ir_pre=Ir;  

%
Xboxnom=Xboxnom(Ir);
Yboxnom=Yboxnom(Ir);
Zboxnom=Zboxnom(Ir);
izBox=izBox(Ir);
Ib=find(izBox==1);
[tmp,Irr]=sort(Ir); % Irr takes a rearranged vector back to its original arrangement
Ip=cell(nbb,1);
for is=1:nbb
  ibs=Ib(is);
  Ip{is}=find(Xboxnom==Xboxnom(ibs) & Yboxnom==Yboxnom(ibs));
  [zp,izp]=sort(Zboxnom(Ip{is}));
  Ip{is}=Ip{is}(izp);
end
Ir=cat(1,Ip{:});  
% save these for later
Ip_post=Ip;
Ir_post=Ir;  

save profile_data Ip_pre Ir_pre Ip_post Ir_post Irr
