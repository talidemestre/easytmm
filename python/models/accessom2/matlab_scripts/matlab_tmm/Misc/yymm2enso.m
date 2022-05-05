function Tenso = yymm2enso(year,month)

% USAGE: Tenso = mmyy2enso(year,month)
% returns months since 1960-01-01
% Jan 1960 is 0.5, ..., Dec 1960 is 11.5, etc

% Samar Khatiwala (spk@ldeo.columbia.edu)

Tenso = (year-1960)*12 + (month-0.5);
