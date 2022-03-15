function t=calc_periodic_times_for_tmm(blocksPerPeriod,fileName)

if isstr(blocksPerPeriod)
  switch lower(blocksPerPeriod)
%   4x-daily (6 hourly)
    case {'4x-daily','6-hourly'}
      bpp=repmat(1,[365*4 1]); % blocks per period         
%   Nominal 365-day year
    case {'monthly-365-day year'}
      bpp=[31 28 31 30 31 30 31 31 30 31 30 31];
%   360-day year
    case {'monthly-360-day year'}
      bpp=repmat(30,[1 12]);
    otherwise
      error(['ERROR: Unknown string passed!: ' blocksPerPeriod])
  end  
  blocksPerPeriod=bpp;
end

cumulativeBlocksPerPeriod=cumsum(blocksPerPeriod); % cumulative blocks per period
totNumBlocksPerPeriod=sum(blocksPerPeriod); % total number of blocks per period
N=length(blocksPerPeriod);
t=zeros(N,1);

t(1)=blocksPerPeriod(1)/2;
for it=1:N-1
  t(it+1)=cumulativeBlocksPerPeriod(it)+blocksPerPeriod(it+1)/2;
end
t=t/totNumBlocksPerPeriod;

if nargin>1
  write_binary(fileName,t,'real*8')
end