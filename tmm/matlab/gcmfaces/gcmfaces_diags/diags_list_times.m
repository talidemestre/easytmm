function [listTimes]=diags_list_times(listSubdirs,listFiles);
%object : get the list of diags times by scanning pkg/diagnostics files
%inputs : listSubdirs is the cell array of directories to scan, in order
%         listFiles is the list of files to scan for, in order
%example: listSubdirs={[dirMat 'BUDG/' ],[dirModel 'diags/BUDG/' ],[dirModel 'diags/OTHER/' ],...
%                      [dirModel 'diags/STATE/' ],[dirModel 'diags/TRSP/'],[dirModel 'diags/' ]};
%         listFiles={'state_2d_set1.','diags_2d_set1.','monthly_2d_set1.'};

listTimes=[];
for kk=1:length(listFiles);
    if isempty(listTimes);
        for jj=1:length(listSubdirs);
            tmp1=dir([listSubdirs{jj} '/' listFiles{kk} '.*meta']);
            if ~isempty(tmp1);
                for tt=1:length(tmp1); listTimes=[listTimes;str2num(tmp1(tt).name(end-14:end-5))]; end;
            end;
        end;
    end;
end;

%if no files were found then stop
if isempty(listTimes); error('no files were found'); end;
