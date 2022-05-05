function [G,Tc]=convolutionMatrixFromTimeSeries(Tdata,Gdata,dt,T)

% USAGE: [G,Tc]=convolutionMatrixFromTimeSeries(Tdata,Gdata,dt,T)
% Returns a convolution matrix with kernel Gdata over the interval [0:dt:T]. 
% INPUTS:
%   Tdata = vector of times at which kernel Gdata is specified
%   Gdata = vector of kernel values
%   dt = discretization step (same units as Tdata) for convolution (scalar)
%   T  = optional upper time limit of convolution (scalar). If not provided, upper limit 
%        is set to max(Tdata).
%        N=T/dt must be an integer
% OUTPUTS:
%   G = sparse convolution matrix of size (N+1,N), such that G*Cbc is the convolution 
%       of Gdata and Cbc. G*Cbc gives the solution at times t=0,dt,...,T (returned in 
%       vector Tc), given Cbc at times t=dt/2,3*dt/2,...,T-dt/2. 
%       Note: the first row of G is always zero. Thus the returned 
%       solution at time t=0 (first element of G*Cb) is always zero. 
%   Tc = vector of times at which the solution G*Cbc is defined.

if nargin<4 % use Tdata
  T=max(Tdata);
end
if isempty(T)
  T=max(Tdata);
end

if max(Tdata)<T-dt/2
  error('Upper limit of convolution exceeds input time series')
end  

if rem(T,dt)
  error('T must be divisible by dt')
end
N=T/dt;

t=[dt/2:dt:T-dt/2]';
Tc=[0:dt:T]';

g=interp1(Tdata,Gdata,t);

G=sparse(N+1,N);
G(2:end,:)=dt*tril(toeplitz(g));
