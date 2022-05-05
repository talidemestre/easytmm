function logplot_grid

% function to create grids for log plots.
% USAGE: logplot_grid will put a grid on the 'coarse' tickmarks.

% Samar Khatiwala (spk@ldeo.columbia.edu)

if(strcmp(get(gca,'XScale'),'log'))
	ix=1;
else
	ix=0;
end
if(strcmp(get(gca,'YScale'),'log'))
	iy=1;
else
	iy=0;
end

yt=get(gca,'YTick');
xt=get(gca,'XTick');
yl=get(gca,'YLim');
xl=get(gca,'XLim');

hold on;

if ix==0
	set(gca,'XGrid','on')
else
	if iy==0
		y=linspace(yl(1),yl(2),100)';
	else
		y=logspace(log10(yl(1)),log10(yl(2)),100)';
	end
	for i=1:length(xt)
		x=xt(i)*ones(size(y));
		plot(x,y,'k:')
	end
end	

if iy==0
	set(gca,'YGrid','on')
else
	if ix==0
		x=linspace(xl(1),xl(2),100)';
	else
		x=logspace(log10(xl(1)),log10(xl(2)),100)';
	end
	for i=1:length(yt)
		y=yt(i)*ones(size(x));
		plot(x,y,'k:')
	end
end
