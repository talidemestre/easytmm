function decdate=mdy2decdate(mm,dd,yy)

% USAGE: decdate=mdy2decdate(mm,dd,yy)
% Returns decimal date from mm,dd,yy

% Samar Khatiwala (spk@ldeo.columbia.edu)

decdate=yy+((mm-1)/12)+((dd-1)/365);
