function J=calc_finite_difference_jacobian(x,func,cols,isMultiFunc);

% Function to compute the Jacobian of a nonlinear function using 
% finite differences. 
% USAGE: J=calc_finite_difference_jacobian(x,func,[cols]);
%  INPUTS:
%   x: (vector) value of independent variable
%   func: function handle for the nonlinear function. func(x) should 
%         return the nonlinear function as a column vector.
%   cols: optional vector of column indices to limit computation to only those columns
%   isMultiFunc: optional flag to indicate whether func can accept a matrix argument X 
%                and return a matrix F, such that the F(:,i) is the function evaluated
%                at X(:,i). Default is 0.
%  OUTPUT:
%   J: Jacobian, d(func(x))/dx
% Notes: The Jacobian is computed one column at a time by calculating the 
% directional derivative J*e_j, where e_j is the unit vector in the j-th 
% direction. 
% Use this function if the Jacobian is dense or if it is sparse but you know nothing 
% about its sparsity pattern. If you do know the sparsity, use graph coloring 
% to compute the Jacobian more efficiently (see calc_finite_difference_jacobian_sparse.m 
% and calc_finite_difference_jacobian_sparse_multi.m).
% This function uses a difference increment based on the routine 'dirder.m' 
% written by C. T. Kelley at NCSU. 

% Samar Khatiwala (spk@ldeo.columbia.edu)

if nargin<2
  error('ERROR: Must pass at least 2 arguments')
end  

n=length(x);

if nargin<3 || isempty(cols) % compute all columns
  cols=[1:n];
end

if nargin<4 || isempty(isMultiFunc)
  isMultiFunc=0;
end

m=length(cols);
J=zeros(n,m); % return a dense matrix

if isMultiFunc % func can accept multiple input vectors
  Xm=zeros([n m+1]);
  epsdiff=zeros(m,1);
  Xm(:,1)=x;
  for j=1:m % loop over each column
    e=zeros(n,1); %  unit vector
    e(cols(j))=1;
    epsdiff(j)=calc_eps(x,e); % difference increment
    Xm(:,j+1)=x+epsdiff(j)*e;
  end
  fm=func(Xm);
  f0=fm(:,1);  
  for j=1:m % loop over each column
    f1=fm(:,j+1);
    J(:,j)=(f1-f0)/epsdiff(j); % (dfunc/dx)*e
  end
else % func can accept only a single input vector
  f0=func(x);
  for j=1:m % loop over each column
    e=zeros(n,1); %  unit vector
    e(cols(j))=1;
    epsdiff=calc_eps(x,e); % difference increment
    f1=func(x+epsdiff*e);
    J(:,j)=(f1-f0)/epsdiff; % (dfunc/dx)*e
  end
end

function epsdiff=calc_eps(x,w)
% Taken from C.T Kelley's dirder.m

n = length(x);

% scale the step
if norm(w) == 0
    z = zeros(n,1);
return
end

epsnew = 1.d-7;

% Now scale the difference increment.
xs=(x'*w)/norm(w);
if xs ~= 0.d0
   epsnew=epsnew*max(abs(xs),1.d0)*sign(xs);
end
epsdiff=epsnew/norm(w);
