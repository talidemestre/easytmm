function [Cs,A,b]=calc_steadystate_tracer(method,Aexp,Aimp,dt,Crelax,lambdaRelax,lambdaDecay,Q)

% Function to compute steady state tracer field for a generic tracer
% with time independent forcing.
% USAGE:
% [Cs,A,b]=calc_steadystate_tracer(method,Aexp,Aimp,dt,Crelax,lambdaRelax,lambdaDecay,Q)
% OUTPUTS:
%   Cs: steady state tracer distribution.
%   A and b: the coefficient matrix and RHS, respectively. i.e., A*Cs = b.
% INPUTS:
%   method: a string indicating time stepping method consistent with the 
%           input transport matrices. method can be 'ab2' or 'dst3'.
%   Aexp: Explicit transport matrix (continuous time).
%   Aimp: Implicit transport matrix (discrete time).
%   dt: time step to use for the (fake) time stepping.
%   Forcings: 
%           (1) relaxation, Crelax and lambdaRelax [sec^-1]. Both must be vectors of 
%               the same length as the tracer vector, and must contain zeros at 
%               grid points where no relaxation is to be applied (e.g., below the 
%               surface).
%           (2) radioactive decay, lambdaRelax [sec^-1].
%           (3) generic forcing term, Q (e.g., a surface flux).
%           To turn off any of these forcing terms, pass an empty array, i.e., [].

if nargin<5
  lambdaRelax=[];
end
if nargin<7
  lambdaDecay=[];
end
if nargin<8
  Q=[];
end

method=lower(method);
if strcmp(method,'ab2')
  abEps=0.1;
  ab15=1.5+abEps;
  ab05=-(0.5+abEps);
  tsMethod=2;  
elseif strcmp(method,'dst3')
  ab15=1.0;
  ab05=0.0;
  tsMethod=30;
end

nb=size(Aexp,1);

I=speye(nb,nb);
A1=I+ab15*dt*Aexp;
if tsMethod==30
  A2=[];
else  
  A2=ab05*dt*Aexp;
end

if ~isempty(lambdaRelax)
  if (length(lambdaRelax)~=nb) | (length(Crelax)~=nb)
    error('lambdaRelax and Crelax must be of length nb')
  end
  Drelax=spdiags(lambdaRelax,0,nb,nb)*dt;
else
  Drelax=0;
  Crelax=0;
%   Drelax=sparse(nb,nb);
%   Crelax=zeros([nb 1]);
end

if ~isempty(lambdaDecay)
  Ddecay=lambdaDecay*I*dt;
else
  Ddecay=0;
%   Ddecay=sparse(nb,nb);
end

if ~isempty(Q)
  Q=Q*dt;
else  
  Q=0;
%   Q=zeros([nb 1]);
end

A1=A1-sparse(ab15*Ddecay)-sparse(ab15*Drelax);
if tsMethod==30
  A=Aimp*A1-I;  
else
  A2=A2-sparse(ab05*Ddecay)-sparse(ab05*Drelax);
  A=Aimp*(A1+A2)-I;  
end

% A=Aimp*(A1+A2)-I;
b=-(ab15+ab05)*Aimp*(Drelax*Crelax+Q);

Cs=A\b;
