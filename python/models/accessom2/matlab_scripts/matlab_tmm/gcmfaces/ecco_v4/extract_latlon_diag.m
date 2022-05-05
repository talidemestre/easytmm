function []=extract_latlon_diag(dirDiag);
%object : applies extract_latlon to part of a diagnostics directory, 
%         hence the lat-lon part of the GRID THETA, SALT, ETAN, UVELMASS/VVELMASS

extract_latlon(dirDiag,'THETA','diag','tracer');
extract_latlon(dirDiag,'SALT','diag','tracer');
extract_latlon(dirDiag,'ETAN','diag','tracer');
extract_latlon(dirDiag,'UVELMASS','diag','flow','VVELMASS');

