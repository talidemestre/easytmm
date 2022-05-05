function halo = get_halo(iBox,nhh,iv,nhv,links)

% Get halo around box iBox. nhh is size of halo in horiz.
% nhv is size of halo in vertical. nhh<0 or nhv<0 will 
% extract ALL adjacent points in horizontal or vertical.

if nargin<5
  load links
end

ib=iBox;
%   W E S N D U
iN=find_points(ib,4,nhh,links);
iS=find_points(ib,3,nhh,links);
halo=[ib iN iS];
tmp=halo;
for i=1:length(halo)
  ib=halo(i);
  iW=find_points(ib,1,nhh,links);
  iE=find_points(ib,2,nhh,links);
  tmp=[tmp iW iE];
end
halo=tmp;

if nargin>2 & iv==1
%  Find points only above and below iBox
   ib=iBox;
   iD=find_points(ib,5,nhv,links);
   iU=find_points(ib,6,nhv,links);
   halo=[halo iD iU];
elseif nargin>2 & iv==2
%  Find points above and below all points in horiz halo
   tmp=halo;
   for i=1:length(halo)
      ib=halo(i);
      iD=find_points(ib,5,nhv,links);
      iU=find_points(ib,6,nhv,links);
      tmp=[tmp iD iU];
   end
   halo=tmp;
end


