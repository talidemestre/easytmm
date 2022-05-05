function []=diags_driver(dirModel,dirMat,listChunk,setDiags);
%object:       compute the various cost and physics
%              diagnosits from model output
%input:        dirModel is the model directory containing sudirectories 'diags/' etc.
%              dirMat is the directory where diagnozed .mat files will be saved
%                     -> set it to '' to use the default [dirModel 'mat/']
%              listChunk states which part of the computation should be done
%                     set it to e.g. 1:4 to do the first 4 years of physics diags
%                     set listChunk to [] to compute cost terms
%              setDiags is
%notes : eventually should also use dirMat, dirTex interactively for listChunk=[];

gcmfaces_global; global myparms;

%%%%%%%%%%%%%%%
%pre-processing
%%%%%%%%%%%%%%%

myswitch=diags_pre_process(dirModel,dirMat);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%now do the selected computation chunk:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dirModel=[dirModel '/'];
if isempty(dirMat); dirMat=[dirModel 'mat/']; else; dirMat=[dirMat '/']; end;

if ~isempty(who('setDiags'));

    if iscell(setDiags); lChunk=52;
    elseif strcmp(setDiags,'B')&(~isempty(find(listChunk==1))); 
            lChunk=1; listChunk=[1:myparms.recInAve(2)];
    elseif strcmp(setDiags,'B'); lChunk=0;
    elseif strcmp(setDiags,'D'); lChunk=52;
    else; lChunk=12;
    end;
    
    %physical diagnostics
    for iChunk=listChunk;
        diags_select(dirModel,dirMat,setDiags,lChunk,iChunk);
    end;
    
elseif ~isempty(listChunk);
    
    %physical diagnostics
    for iChunk=listChunk;
        diags_select(dirModel,dirMat,'A',12,iChunk);
        if iChunk==1; diags_select(dirModel,dirMat,'B',1,[1:myparms.recInAve(2)]); end;
        diags_select(dirModel,dirMat,'C',12,iChunk);
        if myswitch.doBudget;
            budget_list=1;
            if ~isempty(dir([dirMat 'diags_select_budget_list.mat']));
                eval(['load ' dirMat 'diags_select_budget_list.mat;']);
            end;
            for kk=budget_list;
                diags_select(dirModel,dirMat,{'D',kk},52,iChunk);
            end;
        end;
    end;
    
else;
    
    %in situ profiles fit
    if myswitch.doProfiles; insitu_diags(dirMat,1); end;
    
    %altimeter fit
    if myswitch.doCost; cost_altimeter(dirModel,dirMat); end;
    
    %other cost terms
    if myswitch.doCost; cost_sst(dirModel,dirMat,1); end;
    if myswitch.doCost; cost_bp(dirModel,dirMat,1); end;
    if myswitch.doCost; cost_seaicearea(dirModel,dirMat,1); end;
    
    %controls
    if myswitch.doCtrl; cost_xx(dirModel,dirMat,1); end;
    
end;

