function write(data,outfile,np)

% write data to 'outfile' using printf.
% USAGE: write(data,'filename2save2')
% data can be a scalar, vector or matrix
% precision of "write" is set to 5 decimal spaces.
% output is as space seperated values.

% Samar Khatiwala (spk@ldeo.columbia.edu)

if nargin<3
  np=5;
end
str=['%10.' int2str(np) 'f '];
fid = fopen(outfile,'w');
[nr,nc] = size(data);
for i = 1:nr
   for j = 1:nc
      fprintf(fid,str,data(i,j));
   end
   fprintf(fid,'\n');
end
fclose(fid);
