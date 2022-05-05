function Fl = myinterp3(x,y,z,f,Xl,Yl,Zl)

% 'fast' 3-d linear interpolation. 
% This is essentially a matlab version of my fortran code. 
% It returns the same answer as interpn(...,'linear') but is 
% MUCH faster.
% Make sure correct arguments are passed. This function 
% does NO error checking.

Fl=repmat(NaN,size(Xl));

for il=1:length(Xl)
  xl=Xl(il);
  yl=Yl(il);
  zl=Zl(il);
  jlox=max(find(x<=xl)); 
  jloy=max(find(y<=yl)); 
  jloz=max(find(z<=zl));
  
% Use bilinear interpolation in (x,y) on the "faces" z(jloz) and z(jloz+1)
  if jlox<length(x)
    jloxp1=jlox+1;
    t=(xl-x(jlox))/(x(jloxp1)-x(jlox));
  else
    jloxp1=jlox;
    t=0;
  end
  if jloy<length(y)
    jloyp1=jloy+1;
    u=(yl-y(jloy))/(y(jloyp1)-y(jloy));
  else
    jloyp1=jloy;
    u=0;
  end
  if jloz<length(z)
    jlozp1=jloz+1;
    s=(zl-z(jloz))/(z(jlozp1)-z(jloz));
  else
    jlozp1=jloz;
    s=0;
  end
        
  f1=f(jlox,jloy,jloz);
  f2=f(jloxp1,jloy,jloz);
  f3=f(jloxp1,jloyp1,jloz);
  f4=f(jlox,jloyp1,jloz);
  fz1 = (1.d0-t)*(1.d0-u)*f1 + t*(1.d0-u)*f2 + ...
        t*u*f3 + (1.d0-t)*u*f4;

  f1=f(jlox,jloy,jlozp1);
  f2=f(jloxp1,jloy,jlozp1);
  f3=f(jloxp1,jloyp1,jlozp1);
  f4=f(jlox,jloyp1,jlozp1);
  fz2 = (1.d0-t)*(1.d0-u)*f1 + t*(1.d0-u)*f2 + ...
        t*u*f3 + (1.d0-t)*u*f4;

  Fl(il) = s*fz2+(1.d0-s)*fz1;
end
