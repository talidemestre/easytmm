function []=extract_latlon(dirModel,nameFld,typeFile,typeFld,varargin);
%object:	extract the lat-lon part of ecco v4 fields
%inputs:	dirModel is the model directory name
%           nameFld is the field name, which must match that in meta files
%           typeFile is the type of file(s) -- 'diag' (for outputs of
%               pkg/diagnostics) or 'other' (e.g. for grid files)
%           typeFld is the type of field -- 'tracer', 'vector' (2 related
%               fields resp. located at U and V points) or 'flow' (same but
%               with directionality, which implies sign changes below)
%optional:  typeFld2 -- for 'flow' and 'vector', it is assumed that nameFld
%               is the first component (e.g. 'U'), and typeFld2 is the second ('V')

gcmfaces_global;

if ~strcmp(typeFld,'tracer'); nameFld2=varargin{1}; end;
if strcmp(typeFld,'flow'); changeSign=-1; else; changeSign=1; end;


%set input directory names and such:
%-----------------------------------
if strcmp(typeFile,'diag');
    
    %set the list of files:
    listFlds={nameFld};
    if ~strcmp(typeFld,'tracer'); listFlds={nameFld,nameFld2}; end;
    listFldsNames=listFlds;
    listFiles={'state_2d_set1','state_3d_set1','trsp_3d_set1','trsp_3d_set2'};
    listSubdirs={'diags/STATE/','diags/TRSP/'};
    %get the list of times:
    listTimes=[];
    tmp1=dir([dirModel listSubdirs{1} '/' listFiles{1}  '.00*meta']);
    for tt=1:length(tmp1); listTimes=[listTimes;str2num(tmp1(tt).name(end-14:end-5))]; end;
    %set chunk size:
    lChunk=36;
    nChunk=ceil(length(listTimes)/lChunk);
    %check that files are there:
    for ii=1:length(listFiles);
        tmp0='';
        for jj=1:length(listSubdirs);
            tmp1=listFiles{ii}; tmp2=listSubdirs{jj};
            if ~isempty(dir([dirModel tmp2 '/' tmp1 '*meta']));
                tmp0=[dirModel tmp2 '/' tmp1]; listFiles{ii}=tmp0;
            end;
        end;
        if isempty(tmp0); fprintf([' not found: ' tmp1 '\n']); listFiles{ii}=''; end;
    end;
    
else;
    
    nChunk=1;
    
end;

%open output file:
%-----------------------------------
if ~isdir([dirModel '/extracts_latlon/']); mkdir([dirModel '/extracts_latlon/']); end;
fid=fopen([dirModel '/extracts_latlon/' nameFld '.latlon.data'],'w','b');
if ~strcmp(typeFld,'tracer');
    %     error('not implemented yet\n');
    fid2=fopen([dirModel '/extracts_latlon/' nameFld2 '.latlon.data'],'w','b');
end;

%loop over input files:
%----------------------
for iChunk=1:nChunk;
    
    if strcmp(typeFile,'diag');%use rdmds2workspace_list
        
        lTot=length(listTimes);
        i0=min(lChunk*(iChunk-1),lTot);
        i1=min(i0+lChunk,lTot);
        
        tic;
        tt=listTimes([i0+1:i1])';
        for iFile=1:length(listFiles);
            fileFld=listFiles{iFile};
            if ~isempty(fileFld);
                rdmds2workspace_list(fileFld,tt,listFlds);
                for ii=1:length(meta.fldList);
                    tmp1=deblank(meta.fldList{ii});
                    jj=find(strcmp(tmp1,listFlds));
                    if ~isempty(jj); eval(['all_' listFldsNames{jj} '=' tmp1 ';']); end;
                    eval(['clear ' tmp1]);
                end;
            end;
        end;
        fprintf([num2str(i1-i0) ' records loaded in ' num2str(toc) '\n']);
        eval(['fld=all_' nameFld ';']);
        if ~strcmp(typeFld,'tracer'); eval(['fld2=all_' nameFld2 ';']); end;
        
    else;%then simply use rdmds2gcmfaces
        
        fld=rdmds2gcmfaces([dirModel nameFld '*']);
        if ~strcmp(typeFld,'tracer'); fld2=rdmds2gcmfaces([dirModel nameFld2 '*']); end;
        
    end;
    
    %the actual extraction:
    if strcmp(typeFld,'tracer');
        FLD=convert2array(fld);
        FLD=FLD(:,62:239,:,:);
        FLD(1:90,:,:,:)=fld{1}(:,62:239,:,:);
        FLD(91:180,:,:,:)=fld{2}(:,62:239,:,:);
        tmp1=flipdim(permute(fld{4},[2 1 3 4]),2);
        FLD(181:270,:,:,:)=tmp1(:,62:239,:,:);
        tmp1=flipdim(permute(fld{5},[2 1 3 4]),2);
        FLD(271:360,:,:,:)=tmp1(:,62:239,:,:);
        FLD=circshift(FLD,[142 0]);
    else;
        %extract first component:
        FLD=convert2array(fld);
        FLD=FLD(:,62:239,:,:);
        FLD(1:90,:,:,:)=fld{1}(:,62:239,:,:);
        FLD(91:180,:,:,:)=fld{2}(:,62:239,:,:);
        tmp1=flipdim(permute(fld2{4},[2 1 3 4]),2);
        FLD(181:270,:,:,:)=tmp1(:,62:239,:,:);
        tmp1=flipdim(permute(fld2{5},[2 1 3 4]),2);
        FLD(271:360,:,:,:)=tmp1(:,62:239,:,:);
        FLD=circshift(FLD,[142 0]);
        %extract second component: note index and sign shift
        FLD2=convert2array(fld2);
        FLD2=FLD2(:,62:239,:,:);
        FLD2(1:90,:,:,:)=fld2{1}(:,62:239,:,:);
        FLD2(91:180,:,:,:)=fld2{2}(:,62:239,:,:);
        tmp1=flipdim(permute(fld{4},[2 1 3 4]),2);
        FLD2(181:270,:,:,:)=changeSign*tmp1(:,61:238,:,:);
        tmp1=flipdim(permute(fld{5},[2 1 3 4]),2);
        FLD2(271:360,:,:,:)=changeSign*tmp1(:,61:238,:,:);
        FLD2=circshift(FLD2,[142 0]);        
    end;%if ~strcmp(typeFld,'tracer');
    
    %write to disk:
    fwrite(fid,FLD,'float32');
    if ~strcmp(typeFld,'tracer'); fwrite(fid2,FLD2,'float32'); end;
    
end;%for iChunk=1:nChunk;

%close output file:
%------------------
fclose(fid);
if ~strcmp(typeFld,'tracer'); fclose(fid2); end;

%now create meta file:
%---------------------
write2meta([dirModel '/extracts_latlon/' nameFld '.latlon.data'],[360 178]);
if ~strcmp(typeFld,'tracer'); write2meta([dirModel '/extracts_latlon/' nameFld2 '.latlon.data'],[360 178]); end;

