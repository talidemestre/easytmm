% generate data to split matrix extraction over multiple runs

load tracer_tiles numGroups

% base_path=fileparts(fileparts(pwd));
gridFile='grid';
load(gridFile,'nz')

% change this to match the number of tracers you can simultaneously run
maxTracers=nz;

[D,G]=ndgrid(1:nz,1:numGroups); % D is the depth at which to put "delta" and G the tracer group

D=D(:);
G=G(:);

totNumTracers=numGroups*nz; % total number of independent 'tracers' required to extract entire matrix

if rem(totNumTracers,maxTracers)~=0
  error('Error: Total number of tracers must be divisible by maxTracers')
end  

totNumRuns=totNumTracers/maxTracers; % number of runs required given the specified maximum number of tracers per run

D=reshape(D,[maxTracers totNumRuns]);
G=reshape(G,[maxTracers totNumRuns]);

% check
if ~isempty(find(diff(G)))
  error('Error: each run should only involve a unique tracer pattern')
end

G=G(1,:)';

tracer_run_data.depths=D;
tracer_run_data.groups=G;

save matrix_extraction_run_data tracer_run_data

% totNumRuns=ceil(totNumTracers/maxTracers); % number of runs required given the specified maximum number of tracers per run
% 
% numTracers=maxTracers*totNumRuns; % actual number of tracers to be run (equal to or greater than totNumTracers)
% 
% D1=zeros(numTracers,1);
% D1(1:totNumTracers)=D;
% D1(totNumTracers+1:end)=-1; % dummy tracers
% 
% G1=zeros(numTracers,1);
% G1(1:totNumTracers)=G;
% G1(totNumTracers+1:end)=1; % dummy tracers
% 
% tracer_run_data.depths=reshape(D1,[maxTracers totNumRuns]);
% tracer_run_data.groups=reshape(G1,[maxTracers totNumRuns]);
% 
% save matrix_extraction_run_data tracer_run_data

