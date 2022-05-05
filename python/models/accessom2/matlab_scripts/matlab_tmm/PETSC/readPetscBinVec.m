function v = readPetscBinVec(filename,nRec,startRec,displayMsg)

% USAGE: v = readPetscBinVec(filename, [nRec], [startRec])
% read PETSc binary format vector
% INPUTS:
%  filename: name of PETSc file
%  nRec: number of records (vectors) to read
%        if nRec<0, the entire file is read, unless startRec>0. In that case 
%          all records starting at startVec are read.
%  startRec: record (vector) number at which to start reading
%        if startRec<0, the last nRec record(s) is(are) read
%  displayMsg: flag to indicate whether to be verbose or not. Default is to 
%              write out diagnostic information.
% Output:
%  v: vector(s) read from file
% This function does NOT support complex vectors

% Samar Khatiwala (spk@ldeo.columbia.edu)

VEC_FILE_COOKIE=1211214;

if nargin<2 % default is to read one record
  nRec=1;
else
  if isempty(nRec)
    nRec=1;
  end
end

if nargin<3 % default is to start at first vector
  startRec=1;
else
  if isempty(startRec)
    startRec=1;
  end
end

if nargin<4 % default is to be verbose
  displayMsg=1; 
else
  if isempty(displayMsg)
    displayMsg=1;
  end
end

[vecLength,numVecs,numBytes]=getPetscBinVecFileStats(filename);

if nRec<0 % read all vectors
  if startRec>0 % read all records starting at startRec
    nRec=numVecs-startRec+1;
  else % read all vectors
	startRec=1;
	nRec=numVecs;
  end
else
  if startRec<0 % read last nRec records
	startRec=numVecs-nRec+1;
  end
end

if (nRec>numVecs) | (nRec+startRec-1>numVecs)
  error(['ERROR: number of vectors to be read exceeds maximum of ' num2str(numVecs)])
end
if startRec>numVecs
  error(['ERROR: starting record exceeds maximum of ' num2str(numVecs)])
end

fid = fopen(filename, 'r', 'ieee-be');
skipBytes=(8*vecLength+4*2)*(startRec-1);
status=fseek(fid,skipBytes,'bof');
if status<0
  error('ERROR: There is a problem reading this file')
else
  v=repmat(NaN,[vecLength nRec]);
  nRead=0;
  for it=1:nRec
    tmp=read_one_vector(fid);
    if ~isempty(tmp);
      v(:,it) = tmp; %read_one_vector(fid);
      nRead=nRead+1;
    else
      error('ERROR: There is a problem reading this file')      
    end
  end
  fclose(fid);
end

if displayMsg
  disp(['Number of records read: ' num2str(nRead)])
end

% nRead=1;  
% fid = fopen(filename, 'r', 'ieee-be');
% v=read_one_vector(fid);
% fclose(fid);
% 
%     fid = fopen(filename, 'r', 'ieee-be');
%     skipBytes=(8*N+4*2)*(iRec-1)
%     status=fseek(fid,skipBytes,'bof')
% 
% 
% if nRec<0 % read all vectors
%   fid = fopen(filename, 'r', 'ieee-be');
%   v=[];
%   nRead=0;
%   notEOF=1;
%   while notEOF
%     tmp=read_one_vector(fid);
%     if ~isempty(tmp);
%       v=[v tmp];
%       nRead=nRead+1;
%     else
%       notEOF=0;
%     end
%   end
% else  % nRec>=0
%   N=length(v)
%   if iRec>1
%     fid = fopen(filename, 'r', 'ieee-be');
%     skipBytes=(8*N+4*2)*(iRec-1)
%     status=fseek(fid,skipBytes,'bof')
%     ferror(fid)
%     v=repmat(NaN,[N nRec]);
%     nRead=0;
%     for it=1:nRec
%       tmp=read_one_vector(fid);
%       if ~isempty(tmp);
%         v(:,it) = tmp; %read_one_vector(fid);
%       end
%       nRead=nRead+1;
%     end
%     fclose(fid);
%   elseif nRec>1
%     fid = fopen(filename, 'r', 'ieee-be');
%     v=repmat(NaN,[N nRec]);
%     nRead=0;
%     for it=1:nRec
%       v(:,it) = read_one_vector(fid);
%       nRead=nRead+1;
%     end
%     fclose(fid);
%   end
% end

function v=read_one_vector(fid)

VEC_FILE_COOKIE=1211214;

cookie = fread(fid,1,'int');
if isempty(cookie)
  error('ERROR: End of file reached!')  
else
  if (cookie~=VEC_FILE_COOKIE)
    error('ERROR: Not a petsc vector file');
  end
  N=fread(fid,1,'int');
  v=fread(fid,N,'float64');
end
