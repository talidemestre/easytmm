function C=model2box(TR,ib,ixb,iyb,izb,alpha,kd)
% Average GCM onto box grid
% TR(x,y,z) or TR(x,y)
nb=length(ib);
C=repmat(0,[nb 1]);
if nargin==7
  TR(kd)=0;
end

if ndims(TR)==2
  for j=1:nb
    i=ib(j);
    C(j)=sum(sum(sum(alpha{i}.*TR(ixb{i},iyb{i}))));
  end
else
  for j=1:nb
    i=ib(j);
    C(j)=sum(sum(sum(alpha{i}.*TR(ixb{i},iyb{i},izb{i}))));
  end
end
