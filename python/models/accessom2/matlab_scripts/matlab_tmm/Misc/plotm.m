function plotm(long,lat,sym)

% USAGE: plotm(long,lat,'color&symbol string')
% This function plots lat,long data to the current plot
% using the projection initialized by m_proj.
% long and lat vectors are positions of points you want to plot.
% plotm converts from geographic to plotting (x,y)
% coordinates. The color and symbol used for plotting
% must be passed in the text string sym. 
% REQURES: m_map toolbox

% Samar Khatiwala (spk@ldeo.columbia.edu)

[x,y] = m_ll2xy(long,lat,'clip','off');
cmd = ['plot(x,y,' char(39) sym char(39) ')'];
eval(cmd);
