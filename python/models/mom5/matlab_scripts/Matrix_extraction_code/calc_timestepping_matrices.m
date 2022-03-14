function [A1,A2,u,Drelax,Ddecay,Q,ab15,ab05]=calc_timestepping_matrices(method,Aexp,dt,Crelax,lambdaRelax,lambdaDecay,Q,Aimp,componentForm)

% Function to compute DISCRETE matrix operators for timestepping a generic tracer.
% USAGE:
% [A1,A2,u,Drelax,Q,ab15,ab05]=calc_timestepping_matrices(method,Aexp,dt,Crelax,lambdaRelax,lambdaDecay,Q,Aimp,componentForm)
% One time step: C_n+1 = Aimp*(A1*C_n + A2*Cn-1 + (ab15+ab05)*u)
% If method is DST3, A2=[], ab15=1, and ab05=0.
% OUTPUTS:
%   A1,[A2]: discrete EXPLICIT timestepping operators. If input method is DST3, A2=[];
%            A1 and A2 include the relaxation and decay terms.
%            NOTE: if Aimp is provided as an input argument, A1 and A2 will also include 
%                  the implicit transport operator. 
%                  In that case, C_n+1 = A1*C_n + A2*Cn-1 + (ab15+ab05)*u 
%   Drelax: discrete operator for relaxation term. This output is really only useful 
%           when lambdaRelax is time-dependent.
%   u: discrete forcing term (sum of relaxation and forcing (Q) terms). 
%      NOTE: if Aimp is provided as an input argument, u will also include implicit transport
%   Ddecay: discrete operator for decay term.
%   Q: discrete forcing term
%   ab15,ab05: interpolation factors.
% INPUTS:
%   method: a string indicating time stepping method consistent with the 
%           input transport matrices. method can be 'ab2' or 'dst3'.
%   Aexp: Explicit transport matrix (continuous time).
%   dt: time step to use for the (fake) time stepping.
%   Aimp: OPTIONAL implicit transport matrix that is then included in A1,A2, and u. 
%         DO NOT use this option with time-dependent Aexp and/or time-dependent lambdaRelax.
%   componentForm: FLAG to indicate whether the relaxation and decay terms should be included 
%                  in the discrete time-stepping matrices or not. (componentForm=1 => NOT included.)
%   Forcings: 
%           (1) relaxation, Crelax and lambdaRelax [sec^-1]. Both must be vectors of 
%               the same length as the tracer vector, and must contain zeros at 
%               grid points where no relaxation is to be applied (e.g., below the 
%               surface).
%           (2) radioactive decay, lambdaRelax [sec^-1].
%           (3) generic forcing term, Q (e.g., a surface flux).
%           To turn off any of these forcing terms, pass an empty array, i.e., [].

% SPK 10/10/05: modified to accept time-dependent Crelax (i.e., Crelax is a matrix with 
%               each column corresponding to a different time. In that case output u is 
%               also a matrix with the same dimensions as Crelax
% SPK 10/11/05: modified to accept Aimp as an optional argument. If Aimp is provided, 
%               A1,A2, and u are modified to include implicit transport.
% SPK 11/6/05: - modified to return Ddecay, Q, ab15, and ab05 as output arguments
%              - added flag componentForm to input arguments. If componentForm=1,
%                A1 (and A2) will NOT include the decay and relaxation terms.

if nargin<4
  lambdaRelax=[];
end
if nargin<6
  lambdaDecay=[];
end
if nargin<7
  Q=[];
end
if nargin<8
  withImplicitMatrix=0; 
else
  if isempty(Aimp)
    withImplicitMatrix=0;
  else
    withImplicitMatrix=1;
  end
end
if nargin<9
  componentForm=0;
end
if componentForm & withImplicitMatrix
  error('Cannot specify both withImplicitMatrix and componentForm simultaneously')
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

% Some diagnostic output
switch tsMethod
  case 2
    disp('AB-II time stepping specified')
  case 30
    disp('DST3 time stepping specified')
  otherwise
    error('Unknown time stepping method')
end
if ~isempty(lambdaRelax)
  disp('Relaxation term specified')
end
if ~isempty(lambdaDecay)
  disp('Decay term specified')
end
if withImplicitMatrix
  disp('Implicit transport will be included in the discrete time-stepping operators')
end
if componentForm
  disp('Component form output requested: relaxation and decay terms will NOT be included in ')
  disp('the time stepping matrices')
end

nb=size(Aexp,1);

I=speye(nb,nb);
% A1=I+ab15*dt*Aexp;
% split into 2 steps to deal with big matrices
A1=ab15*dt*Aexp;
A1=I+A1;
if tsMethod==30
  A2=[];
else  
  A2=ab05*dt*Aexp;
end

if ~isempty(lambdaRelax)
  if (length(lambdaRelax)~=nb) | (size(Crelax,1)~=nb)
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

% the sparse() below catches the case when the argument is zero: 
% e.g., q=sparse(50000,50000); 
% q + 0 will try to create a full matrix and generate an error
if ~componentForm
  A1=A1-sparse(ab15*Ddecay)-sparse(ab15*Drelax);
end
if withImplicitMatrix
  A1=Aimp*A1;
end 
if tsMethod==30
  A2=[];
else
  if ~componentForm
    A2=A2-sparse(ab05*Ddecay)-sparse(ab05*Drelax);
  end
  if withImplicitMatrix
    A2=Aimp*A2;
  end
end

u=Drelax*Crelax+Q;
if withImplicitMatrix
  u=Aimp*u;
end
