function r=findroots(func,jacob,xo,pars,tol);
% multidimensional root finder based on numerical recipes.
% matlab function to compute multidimensional roots of a system of equations
% i.e., find r such that func(r)==0. r can be a vector [x1,x2,x3,...,xn]
% USAGE: r=findroots(func,jacob,x0,pars)
% func(x,pars) is the name (string) of the m-file which evaluates 
% the system of equations at the values of the variables in x and optionally
% requires parameters in vector pars.
% jacob is the name (string) of the m-file which evaluates the
% jacobian matrix of the set of equations, 
% i.e. [df1/dx1 df1/dx2 ...;df2/dx1 df2/dx2 ...]

% Samar Khatiwala (spk@ldeo.columbia.edu)

% ------------------------------------------------
% e.g. r=findroots('lorenz_roots_func','lorenz_jacob_func',[1 1 1]',[10 28 8/3]')
% will find the roots of the lorenz equations.
% The file 'lorenz_roots_func.m' looks like this:
% ------------------------------------------------
% function F=lorenz_roots_func(x,p)
% 
% sig=p(1);
% r=p(2);
% b=p(3);
% theta=p(4)*pi/180;
% fo=p(5);
% 
% F(1)=sig*x(2)-sig*x(1)+fo*cos(theta);
% F(2)=r*x(1)-x(2)-x(1)*x(3)+fo*sin(theta);
% F(3)=x(1)*x(2)-b*x(3);
% 
% F=F';
% -------------------------------------------------
% The file 'lorenz_jacob_func.m' looks like this:
% -------------------------------------------------
% function J=lorenz_jacob_func(x,p)
% 
% sig=p(1);
% r=p(2);
% b=p(3);
% 
% J=[-sig sig 0;r-x(3) -1 -x(1);x(2) x(1) -b];
% --------------------------------------------------

if nargin<5
	tol=1e-12;
end
x=xo;
if nargin<4
	pars=[];
end
d=feval(func,x,pars);

if length(d)>1
	while max(abs(d))>tol
		F=feval(func,x,pars);
		J=feval(jacob,x,pars);
		dx=J\(-F);
		x=x+dx;
		d=feval(func,x,pars);
	end
else
	while abs(d)>tol
		F=feval(func,x,pars);
		J=feval(jacob,x,pars);
		dx=-F/J;
		x=x+dx;
		d=feval(func,x,pars);
	end	
end
r=x;
