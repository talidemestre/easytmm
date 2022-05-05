function [myswitch]=diags_pre_process(dirModel,dirMat);
%object : pre-processing for grid, model parameters, budgets, 
%         profiles, cost and control, etc.
%         To be called at the the start of diags_driver
%inputs : dirModel is the model run directory name
%         dirMat is the directory where diagnozed .mat files will be saved
%              -> set it to '' to use the default [dirModel 'mat/']
%output : myswitch is the set of switches (doBudget, doProfiles, doCost, doCtrl)
%              that are set here depending on the model output available

gcmfaces_global; global myparms;

dirModel=[dirModel '/'];
if isempty(dirMat); dirMat=[dirModel 'mat/']; else; dirMat=[dirMat '/']; end;

doBudget=~isempty(dir([dirModel 'diags/BUDG/']))
doProfiles=~isempty(dir([dirModel 'profiles/']))
doCost=~isempty(dir([dirModel 'barfiles/']))
doCtrl=~isempty(dir([dirModel 'ADXXfiles/']))

%output switches
myswitch.doBudget=doBudget;
myswitch.doProfiles=doProfiles;
myswitch.doCost=doCost;
myswitch.doCtrl=doCtrl;

%0) create dirMat if needed:
if isempty(dir(dirMat)); eval(['!mkdir ' dirMat ';']); end;

%1) pre-processing diags_grid_parms.mat
test0=isempty(dir([dirMat 'diags_grid_parms.mat']));
test1=isempty(dir([dirMat 'lock_mygrid']));

if test0&test1;%this process will do the pre-processing
    fprintf(['pre-processing : started for mygrid \n']);
    write2file([dirMat 'lock_mygrid'],1);
    %set the list of diags times
    listSubdirs={[dirMat 'BUDG/' ],[dirModel 'diags/BUDG/' ],[dirModel 'diags/OTHER/' ],...
        [dirModel 'diags/STATE/' ],[dirModel 'diags/TRSP/'],[dirModel 'diags/' ]};
    listFiles={'state_2d_set1','diags_2d_set1','monthly_2d_set1'};
    [listTimes]=diags_list_times(listSubdirs,listFiles);
    %set grid and model parameters:
    diags_grid_parms(listTimes);
    %save to disk:
    eval(['save ' dirMat 'diags_grid_parms.mat mygrid myparms;']);
    eval(['!\rm ' dirMat 'lock_mygrid']);
    test1=1;
    fprintf(['pre-processing : completed for mygrid \n\n']);
end;

while ~test1;%this process will wait for pre-processing to complete
    fprintf(['waiting 30s for removal of ' dirMat 'lock_mygrid \n']);
    fprintf(['- That should happen automatically after pre-processing is complete \n']);
    fprintf(['- But if a previous session was interupted, you may need to stop this one, \n ']);
    fprintf(['  remove ' dirMat 'lock_grid manually, and start over. \n\n']);
    test1=isempty(dir([dirMat 'lock_mygrid']));
    pause(30);
end;

%here we always reload the grid from dirMat to make sure the same one is used throughout
eval(['load ' dirMat 'diags_grid_parms.mat;']);

%2) pre-processing profiles
test0=isempty(dir([dirMat 'profiles/']));
test1=isempty(dir([dirMat 'lock_profiles']));

if test0&test1&doProfiles;%this process will do the pre-processing
    fprintf(['pre-processing : started for profiles \n']);
    write2file([dirMat 'lock_profiles'],1);
    eval(['!mkdir ' dirMat 'profiles/;']);
    eval(['!ln -s /net/nares/raid11/ecco-shared/ecco-version-4/input/input_insitu ' dirMat 'profiles/input']);
    eval(['!mkdir ' dirMat 'profiles/output']);
    if dirModel(1)~='/'; dirModelFull=[pwd '/' dirModel]; else; dirModelFull=dirModel; end;
    eval(['!ln -s ' dirModelFull 'profiles/*equi.data ' dirMat 'profiles/.']);
    listModel={'argo_feb2013_1992_to_2007**','argo_feb2013_2008_to_2010*',...
        'argo_feb2013_2011_to_2012*','ctd_feb2013*','itp_feb2013*',...
        'seals_feb2013*','xbt_feb2013*','climode_feb2013*'};
    MITprof_gcm2nc([dirMat 'profiles/'],listModel);
    eval(['!\rm ' dirMat 'lock_profiles']);
    test1=1;
    fprintf(['pre-processing : completed for profiles \n\n']);
end;

while ~test1&doProfiles;%this process will wait for pre-processing to complete
    fprintf(['waiting 30s for removal of ' dirMat 'lock_profiles \n']);
    fprintf(['- That should happen automatically after pre-processing is complete \n']);
    fprintf(['- But if a previous session was interupted, you may need to stop this one, \n ']);
    fprintf(['  remove ' dirMat 'lock_profiles manually, and start over. \n\n']);
    test1=isempty(dir([dirMat 'lock_profiles']));
    pause(30);
end;

%3) budget pre-processing
test0=isempty(dir([dirMat 'BUDG/']));
test1=isempty(dir([dirMat 'lock_budg']));%this aims at having only one process do the

if (test0&test1&doBudget);
    fprintf(['pre-processing : started for budget \n']);
    write2file([dirMat 'lock_budg'],1);
    eval(['!mkdir ' dirMat 'BUDG/;']);
    %compute time derivatives between snwpshots that will be
    %compared in budgets with the time mean flux terms
    v4_diff_snapshots(dirModel,dirMat,'budg2d_snap_set1');
    v4_diff_snapshots(dirModel,dirMat,'budg2d_snap_set2');
    v4_diff_snapshots(dirModel,dirMat,'budg2d_snap_set3');
    %v4_diff_snapshots(dirModel,dirMat,'budg3d_snap_set1');
    budget_list=1;
    for kk=1:length(mygrid.RC);
        tmp1=sprintf('%s/diags/BUDG/budg2d_snap_set3_%02i*',dirModel,kk);
        tmp2=~isempty(dir(tmp1));
        if tmp2;
            budget_list=[budget_list kk];
            tmp1=sprintf('budg2d_snap_set3_%02i',kk);
            v4_diff_snapshots(dirModel,dirMat,tmp1);
        end;
    end;
    eval(['save ' dirMat 'diags_select_budget_list.mat budget_list;']);
    eval(['!\rm ' dirMat 'lock_budg']);
    test1=1;
    fprintf(['pre-processing : completed for budget \n\n']);
end;

while ~test1&doBudget;%this process will wait for pre-processing to complete
    fprintf(['waiting 30s more for removal of ' dirMat 'lock_budg \n']);
    fprintf(['- That should happen automatically after pre-processing is complete \n']);
    fprintf(['- But if a previous session was interupted, you may need to stop this one, \n ']);
    fprintf(['  remove ' dirMat 'lock_budg manually, and start over. \n\n']);
    test1=isempty(dir([dirMat 'lock_budg']));
    pause(30);
end;

