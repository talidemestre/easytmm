function bigfig(str)

% USAGE: bigfig(orient)
% Function to set figure size to a maximum (US Letter) with 
% orientation given by string 'orient'
% orient = 'l' or 'L' (landscape)
%        = 'p' or 'P' (portrait)

% Samar Khatiwala (spk@ldeo.columbia.edu)

str=lower(str);

if str=='l'
	set(gcf,'PaperOrientation','landscape','PaperPosition',[0.25 0.25 10.5 8]);
elseif str=='p'
	set(gcf,'PaperOrientation','portrait','PaperPosition',[0.25 0.25 8 10.5]);
end
