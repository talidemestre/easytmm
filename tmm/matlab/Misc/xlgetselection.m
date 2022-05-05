function data = xlgetselection()
%XLGETSELECTION Get range of selected cells from the
%Active Microsoft Excel worksheet.
%data = XLGETRANGE


%   SPK:12/11/97

range = applescript('getxlselectionsize');
range = range(2:end-1);
ci = findstr(range,',');
rows = str2num(range(1:ci-1));
cols = str2num(range(ci+1:end));

result = applescript('xlgetselection');

result = result(2:end-1); % strip leading/trailing quotes
result = sscanf(result, '%g');
data = reshape(result, cols,rows)';
