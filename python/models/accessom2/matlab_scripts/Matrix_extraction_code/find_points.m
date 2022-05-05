function ln=find_points(ib,iDir,nh,links)

% find_points(ib,iDir,nh,links) returns indices of points 
% adjacent to ib in direction iDir (W E S N D U). Upto nh 
% points are returned. if nh<0, ALL adjacent points in that 
% direction are returned. 
if nh<0
  nh=1e6;
end

% W E S N D U 
ln=[];
jl=links(ib,iDir);
ih=1;
while ~isnan(jl) & ih<=nh
   ln=[ln jl];
   jl=links(jl,iDir);
   ih=ih+1;
end

  
