function [myDiag_cat]=onediag_cat(myDiag_cat,myDiag_more);
%object : concatenate a diagnostic time series
%input :  myDiag_cat is the first part of the time series.
%         myDiag_more is the second part, to be added after myDiag_cat.
%output : myDiag_cat containing the concatenated time series.
%expected input format : myDiag_cat
%         CAN be a gcmfaces object or an array, with any number of dimensions.
%         BUT time is assumed to be the last dimension. 
%         AND myDiag_more accordingly.

%determine the time dimension:
if strcmp(class(myDiag_more),'gcmfaces'); nDim=size(myDiag_more{1}); else; nDim=size(myDiag_more); end;
if ~isempty(find(nDim==0)); nDim=0;
elseif nDim(end)==1; nDim=length(nDim)-1;
else; nDim=length(nDim);
end;
%concatenate along the time dimension:
if nDim>0; myDiag_cat=cat(nDim,myDiag_cat,myDiag_more); end;

