function varargout=rect(x,y,w,h,ang,varargin)

% USAGE: [h,x1,y1]=rect(x,y,w,h,ang,[line properties])
% Function to plot a rectangle of width 'w' and height 'h' 
% with origin (x,y) and orientation 'ang' (degrees). 
% Outputs: 
%   h: handle to line object
%   (x1,y1): coordinates of points plotted

% Samar Khatiwala (spk@ldeo.columbia.edu)

if nargin<5
  ang=90;
end

ang=ang*pi/180;

axes(gca)

z=h/sin(ang);

x1=x + [0 w w+z*cos(ang) z*cos(ang) 0];
y1=y + [0 0 z*sin(ang) z*sin(ang) 0];
h=line(x1,y1);

if nargin>5
  set(h,varargin{:})
end

if nargout==1
  varargout{1}=h;
end
if nargout==2
  varargout{1}=h;
  varargout{2}=x1;
end
if nargout==3
  varargout{1}=h;
  varargout{2}=x1;
  varargout{3}=y1;
end

