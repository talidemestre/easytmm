function write_binary(fldFile,fld,prec,append,recLength,recNumber)

% Function to write data to a binary file (ieee-be)
% USAGE: write_binary(fldFile,fld,prec,append,recLength,recNumber)
%  INPUTS:
%   fldFile: file name to write data to.
%   fld: vector to write to file.  
%   prec: precision of output data (default is 32 bit/float32)
%   append: optional flag indicating whether to append data to an existing file 
%           or to write to new file (the default)
%   recLength: Record length for writing a record to a direct access binary file. You can 
%              use this in combination with the next input parameter to replace/append data 
%              in an existing file. To write data to a new file, you don't need to provide 
%              this information.
%   recNumber: Record number to write. For writing to an existing file, make sure that 
%              recNumber is <= the number of existing records in the file. Otherwise 
%              you will get an error

% Samar Khatiwala (spk@ldeo.columbia.edu)

if nargin<3
  prec='float32';
end
if nargin<4
  append=0;
end

if nargin>4
  if isempty(recLength)
    error('ERROR: Must provide valid record length')
  end
  if isempty(recNumber)
    error('ERROR: Must provide valid record number to start writing at')
  end  
  writeRec=1;
  skipBytes=(str2num(prec(6:end))/8)*recLength*(recNumber-1);
else
  writeRec=0;
end  

if append==0
  fid=fopen(fldFile,'wb','ieee-be'); 
else
  if ~writeRec
	fid=fopen(fldFile,'ab','ieee-be'); 
  else
	fid=fopen(fldFile,'r+b','ieee-be');
%   check size of existing file
	status=fseek(fid,0,'eof');
    currPos=ftell(fid);
    if skipBytes>currPos
      error('ERROR: File contains fewer records than the record number to start writing at')
    else
	  status=fseek(fid,skipBytes,'bof');
	  if status<0
		error('ERROR: There is a problem writing to this file')
	  end
    end    
  end
end
fwrite(fid,fld,prec); 
fclose(fid);
