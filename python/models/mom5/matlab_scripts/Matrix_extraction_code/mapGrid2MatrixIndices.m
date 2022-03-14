function Ib=mapGrid2MatrixIndices(Ig,boxNumFile)

load(boxNumFile,'boxnum','nbhalo')

boxn=boxnum(nbhalo+1:end-nbhalo,nbhalo+1:end-nbhalo,:);
Ib=boxn(Ig); 
