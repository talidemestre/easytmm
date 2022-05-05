function [hp,hb,hw]=errorpoint(x,y,le,ue,w,dir,symb,lspec,ax)

% Function to plot a data point with customized error bar.
% USAGE:  [hp,hb]=errorpoint(x,y,le,ue,w,dir,symb,lspec,ax)
%  INPUTS:
%   x,y:    x and y coordinates of point to plot (MUST be scalars)   
%   le,ue:  lower and upper bounds of error bar. If ue is empty ([]), 
%           it is set equal to le.  
%   w:      width of 'tick mark' of error bar. For a vertical (horizontal) 
%           error bar, the 'tick mark' is horizontal (vertical) and w must 
%           be in units of the x (y)-coordinate.   
%   dir:    direction of error bar: 'v' for vertical and 'h' for horizontal  
%   symb:   optional plot symbol (default is 'ob')
%   lspec:  optional line type for error bar (default is '-b')
%   ax:     axis on which to plot. If not passed or empty, ax is set to the 
%           current axis.
%  OUTPUTS:
%     hp:     handle to data point plot object
%     hb:     handle to error bar plot objects
%     hw:     handle to error bar 'tick' objects
% e.g., 
%   % vertical error bar first
%   [hp,hb,hw]=errorpoint(1985,1.8,.8,[],3,'v','ob','-b');
%   set(hp,'MarkerFaceColor',[0 89/255 255/255],'Color',[0 89/255 255/255])
%   set(hb,'Color',[0 89/255 255/255])
%   set(hw,'Color',[0 89/255 255/255])
%   % horizontal error bar next
%   [hm,hb,hw]=errorpoint(1985,1.8,5,[],.05,'h','ob','-b');
%   set(hm,'MarkerFaceColor',[0 89/255 255/255],'Color',[0 89/255 255/255])
%   set(hb,'Color',[0 89/255 255/255])
%   set(hw,'Color',[0 89/255 255/255])

% Samar Khatiwala (spk@ldeo.columbia.edu)

if nargin<6
  error('ERROR: must pass at least 6 arguments!')
end  

if isempty(ue)
  ue=le;
end 

if nargin<7 || isempty(symb)
  symb='ob';
end

if nargin<8 || isempty(lspec)
  lspec='-b';
end

if nargin<9 || isempty(ax)
  ax=gca;
end

% First plot the data point
[ls,col,mark,msg] = colstyle(symb); 
if ~isempty(msg)
  error(msg);
end
if ~isempty(mark)
  if isempty(col)
    col='b';
  end
  hp=plot(ax,x,y,'Marker',mark,'Color',col);
end

hold on

[ls,col,mark,msg] = colstyle(lspec); 
if ~isempty(msg)
  error(msg); 
end
if isempty(ls)
  ls='-';
end  
if isempty(col)
  col='b';
end

% Now plot the error bar
switch lower(dir)
  case 'v'
%     X=[x x NaN x-w x+w NaN x-w x+w NaN]';
%     Y=[y-le y+ue NaN y+ue y+ue NaN y-le y-le NaN]';    
%     hb=plot(ax,X,Y,'LineStyle',ls,'Color',col);
%   Error bar
    X=[x x]';
    Y=[y-le y+ue]';
    hb=plot(ax,X,Y,'LineStyle',ls,'Color',col);
%   'Tick' mark    
    X=[x-w x+w NaN x-w x+w NaN]';    
    Y=[y+ue y+ue NaN y-le y-le NaN]';
    hw=plot(ax,X,Y,'-','Color',col);
  case 'h'
%     X=[x-le x+ue NaN x+ue x+ue NaN x-le x-le NaN]';
%     Y=[y y NaN y-w y+w NaN y-w y+w NaN]';
%     hb=plot(ax,X,Y,'LineStyle',ls,'Color',col);
%   Error bar
    X=[x-le x+ue]';
    Y=[y y]';
    hb=plot(ax,X,Y,'LineStyle',ls,'Color',col);
%   'Tick' mark        
    X=[x-le x-le NaN x+ue x+ue NaN]';    
    Y=[y-w y+w NaN y-w y+w NaN]';
    hw=plot(ax,X,Y,'-','Color',col);   
end  
    