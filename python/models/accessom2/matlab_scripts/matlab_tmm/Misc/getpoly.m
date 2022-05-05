function [xi,yi] = getpoly()
% getpoly returns the vertices of a CLOSED polygon.
% User selects vertices by pressing the left mouse
% button (mouse button or "1" on the Mac). To terminate 
% input, press the right mouse button ("3" on the Mac). 
% getpoly plots the sides of the polygon after each button press.

% Samar Khatiwala (spk@ldeo.columbia.edu)

lbut = 49;
mbut = 50;
rbut = 51;
i=1;
[xi(1),yi(1),but]=ginput(1);
while(but~=rbut)
   i=i+1;
   [xi(i),yi(i),but]=ginput(1);
   if (but~=rbut)
      plot([xi(i-1) xi(i)],[yi(i-1) yi(i)],'k')
   end
end
xi(i)=xi(1);
yi(i)=yi(1);
plot([xi(i-1) xi(i)],[yi(i-1) yi(i)],'k');
xi=xi';
yi=yi';

