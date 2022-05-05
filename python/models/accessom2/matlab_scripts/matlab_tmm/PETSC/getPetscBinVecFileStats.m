function [vecLength,numVecs,numBytes]=getPetscBinVecFileStats(filename)

% USAGE: [vecLength,numVecs,numBytes]=getPetscBinVecFileStats(filename)
% Utility function to obtain information about a PETSc binary file

% Samar Khatiwala (spk@ldeo.columbia.edu)

VEC_FILE_COOKIE = 1211214;

fid = fopen(filename,'r','ieee-be');
cookie = fread(fid,1,'int');
if (cookie ~= VEC_FILE_COOKIE)
  error('ERROR: Not a petsc vector file.');
end
vecLength = fread(fid,1,'int');

status=fseek(fid,0,'eof'); % go to end of file
numBytes=ftell(fid);
numVecs=numBytes/(vecLength*8+4*2);
fclose(fid);

