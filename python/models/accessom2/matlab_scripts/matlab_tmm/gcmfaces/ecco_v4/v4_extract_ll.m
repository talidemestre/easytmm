function [FLD]=v4_extract_ll(fld);

FLD=convert2array(fld); FLD=FLD(:,61:240,:,:); FLD=circshift(FLD,[-218 0 0 0]);






