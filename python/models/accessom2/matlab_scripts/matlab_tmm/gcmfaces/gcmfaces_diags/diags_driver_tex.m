function []=diags_driver_tex(dirMat,setDiags,dirTex,nameTex);
%object:        build tex file from a set of diagnostics
%input:         dirMat is the directory where diagnozed .mat files are.
%                  dirMat is usually specified as a chararcter string, but 
%                  user can also specify dirMat as {dirMat,dirMatRef} 
%                  in order to plot the dirMat-dirMatRef anlomalies.
%               setDiags is the choice of diagnostics set. The default
%                  is {'profiles','cost','A','B','C','D','controls'} where
%                       'profiles') model to insitu data comparison
%                       'cost') ssh etc. cost functions
%                       'A') trasnports
%                       'B') air-sea fluxes
%                       'C') state variables
%                       'D') global and regional budgets
%                       'controls') estimated control vector
%               dirTex is the directory where tex and figures files are created
%               nameTex is the tex file name (default : 'myPlots')
%note: e.g. to plot just the budgets setDiags={'D'}, and
%           to plot just the subsurface budgets setDiags={{'D',11}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%determine input/output params:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%directory names:
if iscell(dirMat); dirMatRef=dirMat{2}; dirMat=dirMat{1}; end;
dirMat=[dirMat '/'];
if isempty(who('dirMatRef')); dirMatRef='';
elseif ~isempty(dirMatRef); dirMatRef=[dirMatRef '/'];
end;
if isempty(who('dirTex')); dirTex=''; else; dirTex=[dirTex '/']; end;
if isempty(who('nameTex')); nameTex='myPlots'; end;

%set default setDiags
if isempty(setDiags);
  setDiags={'profiles','cost','A','B','C','D','controls'};
end;

%set fileTex and create dirTex if needed
if isempty(dirTex); error('dirTex must be specified'); end;
fileTex=[dirTex nameTex '.tex'];
if isempty(dir(dirTex)); eval(['!mkdir ' dirTex ';']); end;

%%%%%%%%%%%%%%%%%%%%%%
%load grid and params:
%%%%%%%%%%%%%%%%%%%%%%

gcmfaces_global; global myparms;
test1=~isempty(dir([dirMat 'basic_diags_ecco_mygrid.mat']));
test2=~isempty(dir([dirMat 'diags_grid_parms.mat']));
if ~test1&~test2;
  error('missing diags_grid_parms.mat')
elseif test2;
  nameGrid='diags_grid_parms.mat';
  suffDiag='diags_set_';
  budgetList='diags_select_budget_list.mat';
else;
  nameGrid='basic_diags_ecco_mygrid.mat';
  suffDiag='basic_diags_ecco_';
  budgetList='basic_diags_ecco_budget_list.mat';
end;

%here we always reload the grid from dirMat to make sure the same one is used throughout
eval(['load ' dirMat nameGrid ';']);

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%finalize listDiags
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%determined where to display anomalies between runs
doAnomalies=~isempty(dirMatRef);

%check if result is here to plot
doBudget=~isempty(dir([dirMat suffDiag 'D_*']));
doProfiles=~isempty(dir([dirMat 'insitu_cost_all.mat']));
doCost=~isempty(dir([dirMat 'cost_altimeter_obs.mat']));
doCtrl=~isempty(dir([dirMat 'cost_xx_aqh.mat']));

%the following have no code for diff between runs
if doAnomalies;
    doProfiles=0;
    doCost=0;
    doCtrl=0;
end;

%reduce setDiags if needed:
doDiags=ones(1,length(setDiags));
%
for ii=1:length(setDiags);
  if iscell(setDiags{ii});
    if ~doBudget&strcmp(setDiags{ii}{1},'D'); doDiags(ii)=0; end;
  elseif ~doBudget&strcmp(setDiags{ii},'D'); doDiags(ii)=0; 
  elseif ~doProfiles&strcmp(setDiags{ii},'profiles'); doDiags(ii)=0;   
  elseif ~doCost&strcmp(setDiags{ii},'cost'); doDiags(ii)=0;   
  elseif ~doCtrl&strcmp(setDiags{ii},'controls'); doDiags(ii)=0;   
  end;
end;
%
setDiags={setDiags{find(doDiags)}};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%initialize tex file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tmp1=dirMat; tmp2=strfind(tmp1,'_'); tmp1(tmp2)=' ';
myTitle={'my standard analysis of the solution in',tmp1};
if ~isempty(dirMatRef);
    tmp1=dirMat; tmp2=strfind(tmp1,'_'); tmp1(tmp2)=' ';
    myTitle={'my standard analysis of the solution in',tmp1};
    tmp1=dirMatRef; tmp2=strfind(tmp1,'_'); tmp1(tmp2)=' ';
    myTitle={myTitle{:},' minus ',tmp1};
end;
write2tex(fileTex,0,myTitle);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%augment tex file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for ii=1:length(setDiags);

  if iscell(setDiags{ii});
    ttl=input('specify tex file section title:\n');
    write2tex(fileTex,1,ttl,1);
    diags_display({dirMat,dirMatRef},setDiags{ii},dirTex,nameTex);

  elseif strcmp(setDiags{ii},'profiles');
        %in situ profiles fit
        write2tex(fileTex,1,'fit to in situ data',1);
        insitu_diags(dirMat,0,dirTex,nameTex);
    
  elseif strcmp(setDiags{ii},'cost');
        %altimeter fit
        write2tex(fileTex,1,'fit to altimeter data',1);
        cost_altimeter_disp(dirMat,2,'modMobs',dirTex,nameTex);
        cost_altimeter_disp(dirMat,1,'modMobs',dirTex,nameTex);
        cost_altimeter_disp(dirMat,3,'modMobs',dirTex,nameTex);
        cost_altimeter_disp(dirMat,1,'obs',dirTex,nameTex);
        cost_altimeter_disp(dirMat,1,'mod',dirTex,nameTex);
        
        %other cost terms
        write2tex(fileTex,1,'fit to sst data',1);
        cost_sst('',dirMat,0,dirTex,nameTex);
        write2tex(fileTex,1,'fit to grace data',1);
        cost_bp('',dirMat,0,dirTex,nameTex);
        write2tex(fileTex,1,'fit to nsidc data',1);
        cost_seaicearea('',dirMat,0,dirTex,nameTex);
    
  elseif strcmp(setDiags{ii},'A');
      write2tex(fileTex,1,'volume, heat and salt transports',1);
      diags_display({dirMat,dirMatRef},'A',dirTex,nameTex);

  elseif strcmp(setDiags{ii},'B');
    write2tex(fileTex,1,'mean and variance maps',1);
    diags_display({dirMat,dirMatRef},'B',dirTex,nameTex);

  elseif strcmp(setDiags{ii},'C');
    write2tex(fileTex,1,'global, zonal, regional averages',1);
    diags_display({dirMat,dirMatRef},'C',dirTex,nameTex);

  elseif strcmp(setDiags{ii},'D');
        budget_list=1;
        if ~isempty(dir([dirMat budgetList]));
            eval(['load ' dirMat budgetList ';']);
        end;
        for kk=budget_list;
            if kk==1;
                tmp1='(top to bottom)';
            else;
                tmp1=sprintf('(%im to bottom)',round(-mygrid.RF(kk)));
            end;
            write2tex(fileTex,1,['budgets : volume, heat and salt ' tmp1],1);
            diags_display({dirMat,dirMatRef},{'D',kk},dirTex,nameTex);
        end;

  elseif strcmp(setDiags{ii},'controls');
        %controls
        write2tex(fileTex,1,'controls',1);
        cost_xx('',dirMat,0,dirTex,nameTex);

  else;
    ttl=input('specify tex file section title:\n');
    write2tex(fileTex,1,ttl,1);
    diags_display({dirMat,dirMatRef},setDiags{ii},dirTex,nameTex);

  end;%if iscell(setDiags{ii});
end;%for ii=1:length(setDiags);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%finalize tex file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

write2tex(fileTex,4);
%write2tex(fileTex,5);

