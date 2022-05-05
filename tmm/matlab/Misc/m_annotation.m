function h=m_annotation(annType,varargin)

units=get(gcf,'units');

switch lower(annType)
   case {'rectangle','ellipse','textbox'}
     pos=varargin{1};
     long=[pos(1) pos(1)+pos(3)];
     lat=[pos(2) pos(2)+pos(4)];
     [xann,yann]=m_ll2xy(long,lat,'clip','off');     
     set(gcf,'Units','normalized');
     [xann,yann]=axescoord2figurecoord(xann,yann);     
     pos=[xann(1) yann(1) xann(2)-xann(1) yann(2)-yann(1)];
     h=annotation(annType,pos,varargin{2:end});     
   case {'line','arrow','doublearrow','textarrow'}
     long=varargin{1};
     lat=varargin{2};
     [xann,yann]=m_ll2xy(long,lat,'clip','off');
     set(gcf,'Units','normalized');
     [xann,yann]=axescoord2figurecoord(xann,yann);     
     h=annotation(annType,xann,yann,varargin{3:end});     
   otherwise
     error(['Unknown annotation type ' annType])
end

set(gcf,'units',units)
