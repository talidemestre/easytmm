function [mm,dd,yr]=decdate2mdy(dyr)

% USAGE: [mm,dd,yr]=decdate2mdy(dyr)
% Function to return month, day, year from decimal date

% Samar Khatiwala (spk@ldeo.columbia.edu)

yr=floor(dyr);
atday=(dyr-floor(dyr))*365;
mm=floor(mod(atday,365)/30.4167)+1;
dd=round(atday-((mm-1)*365/12)+1);
