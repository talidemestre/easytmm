function [yy,mm] = enso2yymm(tenso)

% USAGE: [yy,mm] = enso2yymm(tenso)
% returns year and month of tenso. This routine will only
% correctly deal with tenso corresponding to the MIDDLE 
% of a month, i.e., 0.5,1.5, etc.

% Samar Khatiwala (spk@ldeo.columbia.edu)

tm=tenso-0.5;

yy=1960+floor(tm/12);
mm=1+mod(tm,12);

