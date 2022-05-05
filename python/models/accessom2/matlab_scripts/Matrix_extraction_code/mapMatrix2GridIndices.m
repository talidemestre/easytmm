function Ig=mapMatrix2GridIndices(Ib,boxFile,gridFile)

load(boxFile,'ixBox','iyBox','izBox')
load(gridFile,'nx','ny','nz')

Ig=sub2ind([nx ny nz],ixBox(Ib),iyBox(Ib),izBox(Ib))';    
