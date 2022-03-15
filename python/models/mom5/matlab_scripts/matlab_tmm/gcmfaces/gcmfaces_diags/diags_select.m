function []=diags_select(dirModel,dirMat,setDiags,lChunk,listChunk);
%object:       compute a set of basic diagnostics
%input:        dirModel is the model run directory
%              dirMat is the directory where diagnozed .mat files will be saved
%                     -> set it to '' to use the default [dirModel 'mat/']
%              setDiags is the choice of diagnostics
%                       'A') trasnports (see diags_set_A.m)
%                       'B') air-sea fluxes
%                       'C') state variables
%                       'D') global and regional budgets
%                       'LAYERS') T/S/RHO coordinate overturns
%                       'user') is a placeholder for user diags additions
%              lChunk states how many records are computed at once
%              listChunk states which parts of the records should be
%                     computed (i0+1:i0+lChunk where i0~lTot/lChunk)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%create dirModel/mat if needed:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if lChunk==0; return; end;

dirModel=[dirModel '/'];

if isempty(dirMat); dirMat=[dirModel 'mat/']; end;
if isempty(dir(dirMat)); eval(['!mkdir ' dirMat ';']); end;

%list of subdirectories where to scan for output
listSubdirs={[dirMat 'BUDG/' ],[dirModel 'diags/BUDG/' ],[dirModel 'diags/OTHER/' ],...
    [dirModel 'diags/STATE/' ],[dirModel 'diags/TRSP/'],[dirModel 'diags/' ]};

setDiagsParams=[];
if iscell(setDiags);
    setDiagsParams={setDiags{2:end}};
    setDiags=setDiags{1};
end;

%%%%%%%%%%%%%%%%%%%%%%
%load grid and params:
%%%%%%%%%%%%%%%%%%%%%%

gcmfaces_global; global myparms;
test0=~isempty(dir([dirMat 'diags_grid_parms.mat']));
test1=~isempty(dir([dirMat 'basic_diags_ecco_mygrid.mat']));
if test0;%load mygrid and myparms from file
    eval(['load ' dirMat 'diags_grid_parms.mat;']);
elseif test1;%for backward compatibility
    eval(['load ' dirMat 'basic_diags_ecco_mygrid.mat;']);
else;
    error('could not find diags_grid_parms.mat');
end;

%in case mygrid.memoryLimit=1, load the stuff that was not saved to diags_grid_parms.mat
if mygrid.memoryLimit==1;
        list0={'hFacS','hFacW'};
        for iFld=1:length(list0);
          eval(['mygrid.' list0{iFld} '=rdmds2gcmfaces([mygrid.dirGrid ''' list0{iFld} '*'']);']);
        end;
        %
        mygrid.hFacCsurf=mygrid.hFacC;
        for ff=1:mygrid.hFacC.nFaces; mygrid.hFacCsurf{ff}=mygrid.hFacC{ff}(:,:,1); end;
        %
        mskC=mygrid.hFacC; mskC(mskC==0)=NaN; mskC(mskC>0)=1; mygrid.mskC=mskC;
        mskW=mygrid.hFacW; mskW(mskW==0)=NaN; mskW(mskW>0)=1; mygrid.mskW=mskW;
        mskS=mygrid.hFacS; mskS(mskS==0)=NaN; mskS(mskS>0)=1; mygrid.mskS=mskS;
        %
        gcmfaces_lines_zonal;
        mygrid.LATS=[mygrid.LATS_MASKS.lat]';
        [lonPairs,latPairs,names]=line_greatC_TUV_MASKS_v4;
        gcmfaces_lines_transp(lonPairs,latPairs,names);
end;

%%%%%%%%%%%%%%
%define diags:
%%%%%%%%%%%%%%

userStep=1;
if ~isempty(which(['diags_set_' setDiags]));
    eval(['diags_set_' setDiags]);
else;
    diags_set_user;
end;

%reformat listDiags to cell array:
jj=strfind(listDiags,' '); jj=[0 jj length(listDiags)+1];
for ii=1:length(jj)-1;
    tmp1=listDiags(jj(ii)+1:jj(ii+1)-1);
    if ii==1; listDiags2={tmp1}; else; listDiags2{ii}=tmp1; end;
end;
listDiags=listDiags2; clear listDiags2;

%%%%%%%%%%%%%%
%detect files:
%%%%%%%%%%%%%%

userStep=2;
if ~isempty(which(['diags_set_' setDiags]));
    eval(['diags_set_' setDiags]);
else;
    diags_set_user;
end;

%remove blanks in pkg/diagnostics flds name
listFlds=deblank(listFlds); 
listFldsNames=deblank(listFldsNames);

%set the list of diags times
[listTimes]=diags_list_times(listSubdirs,listFiles);

%then scan directories (listSubdirs) for files (listFiles)
for ii=1:length(listFiles);
    tmp0='';
    for jj=1:length(listSubdirs);
        tmp1=listFiles{ii}; tmp2=listSubdirs{jj};
        if ~isempty(dir([tmp2 '/' tmp1 '*meta']));
            tmp0=[tmp2 '/' tmp1]; listFiles{ii}=tmp0;
        end;
    end;
    if isempty(tmp0); fprintf([' not found: ' tmp1 '\n']); listFiles{ii}=''; end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%loop over chunks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for iChunk=listChunk;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%load records for computation:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%check that all fields were found, and otherwise reduce listFlds
listFldsIsPresent=zeros(1,length(listFldsNames));
for iFld=1:length(listFldsNames);
    fldName=['all_' listFldsNames{iFld}];
    if isempty(who(fldName));
        fprintf([fldName ' is missing \n']);
    else;
        listFldsIsPresent(iFld)=1;
        %    fprintf([fldName ' was found \n']);
    end;
end;
listFldsNames={listFldsNames{find(listFldsIsPresent)}};
listFlds={listFlds{find(listFldsIsPresent)}};

%%%%%%%%%%%%%%%%%%%%
%do the computation:
%%%%%%%%%%%%%%%%%%%%
for ii=i0+1:i1;
    
    tic;
    tt=listTimes(ii);
    
    %get data from buffer
    for jj=1:length(listFldsNames);
        if lChunk==1|length(listTimes)==1;
            eval([listFldsNames{jj} '=all_' listFldsNames{jj} ';']);
        else;
            eval(['tmp1=size(all_' listFldsNames{jj} '{1});']);
            if length(tmp1)==4; eval([listFldsNames{jj} '=all_' listFldsNames{jj} '(:,:,:,ii-i0);']);
            else; eval([listFldsNames{jj} '=all_' listFldsNames{jj} '(:,:,ii-i0);']);
            end;
        end;
    end;
    fprintf([num2str(ii-i0) '/' num2str(i1-i0) ' started \n']);

    %generic output file name (that will potentially be overriden)
    tmp1=setDiags;
    fileMat=['diags_set_' tmp1 '_' num2str(tt) '.mat'];
        
    %the actual computations
    userStep=3;
    if ~isempty(which(['diags_set_' setDiags]));
        eval(['diags_set_' setDiags]);
    else;
        diags_set_user;
    end;
   
    fprintf([num2str(ii) '/' num2str(length(listTimes)) ' done in ' num2str(toc) '\n']);
 
    %package results
    onediag=[];
    onediag.listTimes=myparms.yearFirst(1)+tt*myparms.timeStep/86400/365.25;
    onediag.listSteps=tt;
    for jj=1:length(listDiags);
        eval(['onediag.' listDiags{jj} '=' listDiags{jj} ';']);
    end;

    %write to disk 
    diags_store_to_mat(dirMat,fileMat,onediag);
    
end;%for ii=i0+1:i1;

end;%for iChunk=listChunk;


