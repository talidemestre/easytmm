function [U,V,KHX,KHY]=matrix2flow(Ams,Xboxnom,Yboxnom,links,useSphericalGrid)

d2r=pi/180;
rad=6371e3;
boxFile='boxes';
gridFile='grid';
nb=size(Ams,1);

u=repmat(NaN,[nb 1]);
v=repmat(NaN,[nb 1]);
khx=repmat(NaN,[nb 1]);
khy=repmat(NaN,[nb 1]);

for i=1:nb
   iW=links(i,1);
   iE=links(i,2);
   iS=links(i,3);
   iN=links(i,4);
   iD=links(i,5);
   iU=links(i,6); 
   if ~isnan(iE+iW)
      if useSphericalGrid        
        dxb=rad*cos(Yboxnom(i)*d2r)*((Xboxnom(iE)-Xboxnom(iW))/2)*d2r;
      else
        dxb=8e3; %(Xboxnom(iE)-Xboxnom(iW))/2;
      end
      u(i)=dxb*(Ams(i,iW)-Ams(i,iE));
      khx(i)=(dxb^2)*(Ams(i,iW)+Ams(i,iE))/2;
   end
   if ~isnan(iN+iS)
      if useSphericalGrid
        dyb=rad*((Yboxnom(iN)-Yboxnom(iS))/2)*d2r;
      else
        dyb=8e3; %(Yboxnom(iN)-Yboxnom(iS))/2;
      end
      v(i)=dyb*(Ams(i,iS)-Ams(i,iN));
      khy(i)=(dyb^2)*(Ams(i,iS)+Ams(i,iN))/2;
   end
end

[U,xg,yg,zg]=grid_boxes3d(u,[1:nb]',boxFile,gridFile,'nearest');
[V,xg,yg,zg]=grid_boxes3d(v,[1:nb]',boxFile,gridFile,'nearest');
[KHX,xg,yg,zg]=grid_boxes3d(khx,[1:nb]',boxFile,gridFile,'nearest');
[KHY,xg,yg,zg]=grid_boxes3d(khy,[1:nb]',boxFile,gridFile,'nearest');
