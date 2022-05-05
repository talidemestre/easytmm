
%select kBudget:
if ~isempty(setDiagsParams);
  kBudget=setDiagsParams{1};
else;
  kBudget=1;
end;

%override default file name:
%---------------------------
tmp1=setDiags;
if kBudget>1;
    tmp1=sprintf('D%02i',kBudget);
end;
fileMat=['diags_set_' tmp1];

if userStep==1;%diags to be computed
    listDiags=['glo_vol_ocn glo_vol_tot glo_vol_ice glo_bp'];
    listDiags=[listDiags ' north_vol_ocn north_vol_tot north_vol_ice north_bp'];
    listDiags=[listDiags ' south_vol_ocn south_vol_tot south_vol_ice south_bp'];
    listDiags=[listDiags ' glo_heat_ocn glo_heat_tot glo_heat_ice'];
    listDiags=[listDiags ' north_heat_ocn north_heat_tot north_heat_ice'];
    listDiags=[listDiags ' south_heat_ocn south_heat_tot south_heat_ice'];
    listDiags=[listDiags ' glo_salt_ocn glo_salt_tot glo_salt_ice'];
    listDiags=[listDiags ' north_salt_ocn north_salt_tot north_salt_ice'];
    listDiags=[listDiags ' south_salt_ocn south_salt_tot south_salt_ice'];

elseif userStep==2;%input files and variables
    listFlds={    'ETAN','SIheff','SIhsnow','THETA   ','SALT    ','PHIBOT'};
    listFlds={listFlds{:},'SIatmFW ','oceFWflx','SItflux','TFLUX','SFLUX','oceSPflx','SRELAX'};
    listFlds={listFlds{:},'oceQnet ','SIatmQnt','SIaaflux','SIsnPrcp','SIacSubl'};
    listFlds={listFlds{:},'TRELAX','WTHMASS','WSLTMASS','oceSflux','oceQsw','oceSPtnd'};
    if kBudget>1;
        listFlds={listFlds{:},'ADVr_TH','DFrE_TH','DFrI_TH','ADVr_SLT','DFrE_SLT','DFrI_SLT','WVELMASS'};
    end;
    listFlds={listFlds{:},'SDIAG1','SDIAG2','SDIAG3'};
    listFlds={listFlds{:},'UVELMASS','VVELMASS','AB_gT','AB_gS'};
    listFlds={listFlds{:},'ADVx_TH ','ADVy_TH ','DFxE_TH ','DFyE_TH '};
    listFlds={listFlds{:},'ADVx_SLT','ADVy_SLT','DFxE_SLT','DFyE_SLT'};
    listFlds={listFlds{:},'ADVxHEFF','ADVyHEFF','DFxEHEFF','DFyEHEFF'};
    listFlds={listFlds{:},'ADVxSNOW','ADVySNOW','DFxESNOW','DFyESNOW'};
    listFldsNames=deblank(listFlds);
    %
    listFiles={'rate_budg2d_snap_set1','budg2d_hflux_set1','budg2d_zflux_set1','budg2d_zflux_set2'};
    if kBudget==1;
        listFiles={listFiles{:},'rate_budg2d_snap_set2','budg2d_hflux_set2'};
    else;
        tmp1=sprintf('rate_budg2d_snap_set3_%02i',kBudget);
        tmp2=sprintf('budg2d_zflux_set3_%02i',kBudget);
        tmp3=sprintf('budg2d_hflux_set3_%02i',kBudget);
        listFiles={listFiles{:},tmp1,tmp2,tmp3};
    end;
    listSubdirs={[dirMat 'BUDG/' ],[dirModel 'diags/BUDG/']};

elseif userStep==3;%computational part;

    %preliminary tests
    test1=isempty(dir([dirModel 'diags/BUDG/budg2d_snap_set1*']));
    test2=isempty(dir([dirMat 'BUDG/rate_budg2d_snap_set1*']));

    if (strcmp(setDiags,'D')&test1&test2);
        fprintf('\n abort : global and regional budgets, due to missing \n');
        fprintf(['\n   ' dirModel 'diags/BUDG/budg2d_snap_set1* \n']);
        return;
    end;

    if (strcmp(setDiags,'D')&test2);
        fprintf('\n abort : global and regional budgets, due to missing \n');
        fprintf(['\n   ' dirModel 'diags/BUDG/rate_budg2d_snap_set1* \n']);
        return;
    end;
    
    %override default file name:
    %---------------------------
    tmp1=setDiags;
    if kBudget>1;
        tmp1=sprintf('D%02i',kBudget);
    end;
    fileMat=['diags_set_' tmp1 '_' num2str(tt) '.mat'];
        
    %fill in optional fields:
    %------------------------
    if isempty(who('TRELAX')); TRELAX=0*mygrid.XC; end;
    if isempty(who('SRELAX')); SRELAX=0*mygrid.XC; end;
    if isempty(who('AB_gT')); AB_gT=0*mygrid.XC; end;
    if isempty(who('AB_gS')); AB_gS=0*mygrid.XC; end;
    if isempty(who('oceSPtnd')); oceSPtnd=0*mygrid.XC; end;
    if isempty(who('oceSPflx')); oceSPflx=0*mygrid.XC; end;
    if isempty(who('PHIBOT')); PHIBOT=0*mygrid.XC; end;

    %aliases from development phase (applies to 2012 core runs)
    %---------------------------------------------------------
    if ~isempty(who('SDIAG1')); SRELAX=SDIAG1; end;
    if ~isempty(who('SDIAG2')); SIatmFW=SDIAG2; end;
    if ~isempty(who('SDIAG3')); SItflux=SDIAG3; end;

    
    %=======MASS=========
    
    %compute mapped budget:
    %----------------------
    
    %mass = myparms.rhoconst * sea level
    contOCN=ETAN*myparms.rhoconst;
    contICE=(SIheff*myparms.rhoi+SIhsnow*myparms.rhosn);
    %for deep ocean layer :
    if kBudget>1&myparms.useNLFS<2;
        contOCN=0;
    elseif kBudget>1;%rstar case
        tmp1=mk3D(mygrid.DRF,mygrid.hFacC).*mygrid.hFacC;
        tmp2=sum(tmp1(:,:,kBudget:length(mygrid.RC)),3)./mygrid.Depth;
        contOCN=tmp2.*ETAN*myparms.rhoconst;
    end;
    %
    contTOT=contOCN+contICE;
    %vertical divergence (air-sea fluxes or vertical advection)
    zdivOCN=oceFWflx;
    zdivICE=SIatmFW-oceFWflx;
    %in virtual salt flux we omit :
    if ~myparms.useRFWF; zdivOCN=0*zdivOCN; end;
    %for deep ocean layer :
    if kBudget>1; zdivOCN=-WVELMASS*myparms.rhoconst; end;
    %
    zdivTOT=zdivOCN+zdivICE;
    %horizontal divergence (advection and ice diffusion)
    hdivOCN=myparms.rhoconst*calc_UV_div(UVELMASS,VVELMASS,{'dh'}); %for 2D, already vertically integrated, fields
    tmpU=(myparms.rhoi*DFxEHEFF+myparms.rhosn*DFxESNOW+myparms.rhoi*ADVxHEFF+myparms.rhosn*ADVxSNOW);
    tmpV=(myparms.rhoi*DFyEHEFF+myparms.rhosn*DFyESNOW+myparms.rhoi*ADVyHEFF+myparms.rhosn*ADVySNOW);
    hdivICE=calc_UV_div(tmpU,tmpV); %no dh needed here
    hdivTOT=hdivOCN+hdivICE;
    
    %bottom pressure for comparison:
    bp=myparms.rhoconst/9.81*PHIBOT;
    
    %compute global integrals:
    %-------------------------
    msk=mygrid.mskC(:,:,kBudget);
    glo_vol_tot=calc_budget_mean_mask(contTOT,zdivTOT,hdivTOT,msk);
    glo_vol_ocn=calc_budget_mean_mask(contOCN,zdivOCN,hdivOCN,msk);
    glo_vol_ice=calc_budget_mean_mask(contICE,zdivICE,hdivICE,msk);
    glo_bp=nansum(bp.*msk.*mygrid.RAC)/nansum(msk.*mygrid.RAC);
    
    %compute northern hemisphere integrals:
    msk=mygrid.mskC(:,:,kBudget).*(mygrid.YC>0);
    north_vol_tot=calc_budget_mean_mask(contTOT,zdivTOT,hdivTOT,msk);
    north_vol_ocn=calc_budget_mean_mask(contOCN,zdivOCN,hdivOCN,msk);
    north_vol_ice=calc_budget_mean_mask(contICE,zdivICE,hdivICE,msk);
    north_bp=nansum(bp.*msk.*mygrid.RAC)/nansum(msk.*mygrid.RAC);
    
    %and southern hemisphere integrals:
    msk=mygrid.mskC(:,:,kBudget).*(mygrid.YC<=0);
    south_vol_tot=calc_budget_mean_mask(contTOT,zdivTOT,hdivTOT,msk);
    south_vol_ocn=calc_budget_mean_mask(contOCN,zdivOCN,hdivOCN,msk);
    south_vol_ice=calc_budget_mean_mask(contICE,zdivICE,hdivICE,msk);
    south_bp=nansum(bp.*msk.*mygrid.RAC)/nansum(msk.*mygrid.RAC);
    
    %=======HEAT=======
    
    contOCN=myparms.rcp*THETA-myparms.rcp*AB_gT;
    contICE=-myparms.flami*(SIheff*myparms.rhoi+SIhsnow*myparms.rhosn);
    contTOT=contOCN+contICE;
    %vertical divergence (air-sea fluxes or vertical adv/dif)
    zdivOCN=TFLUX;
    zdivICE=-(SItflux+TFLUX-TRELAX);
    %in linear surface we omit :
    if ~myparms.useNLFS; zdivOCN=zdivOCN-myparms.rcp*WTHMASS; end;
    %in virtual salt flux we omit :
    if ~myparms.useRFWF|~myparms.useNLFS; zdivICE=zdivICE+SIaaflux; end;
    %working approach for real fresh water (?) and virtual salt flux
    if 0; zdivICE=-oceQnet-SIatmQnt-myparms.flami*(SIsnPrcp-SIacSubl); end;
    %for deep ocean layer :
    if kBudget>1;
        zdivOCN=-(ADVr_TH+DFrE_TH+DFrI_TH)./mygrid.RAC*myparms.rcp;
        dd=mygrid.RF(kBudget); msk=mygrid.mskC(:,:,kBudget);
        swfrac=0.62*exp(dd/0.6)+(1-0.62)*exp(dd/20);
        if dd<-200; swfrac=0; end;
        zdivOCN=zdivOCN+swfrac*oceQsw;%.*msk;
    end;
    %
    zdivTOT=zdivOCN+zdivICE;
    %horizontal divergence (advection and diffusion)
    tmpU=myparms.rcp*(ADVx_TH+DFxE_TH); tmpV=myparms.rcp*(ADVy_TH+DFyE_TH);
    hdivOCN=calc_UV_div(tmpU,tmpV);
    tmpU=-myparms.flami*(myparms.rhoi*DFxEHEFF+myparms.rhosn*DFxESNOW+myparms.rhoi*ADVxHEFF+myparms.rhosn*ADVxSNOW);
    tmpV=-myparms.flami*(myparms.rhoi*DFyEHEFF+myparms.rhosn*DFyESNOW+myparms.rhoi*ADVyHEFF+myparms.rhosn*ADVySNOW);
    hdivICE=calc_UV_div(tmpU,tmpV); %no dh needed here
    hdivTOT=hdivOCN+hdivICE;
    
    %compute global integrals:
    %-------------------------
    msk=mygrid.mskC(:,:,kBudget);
    glo_heat_tot=calc_budget_mean_mask(contTOT,zdivTOT,hdivTOT,msk);
    glo_heat_ocn=calc_budget_mean_mask(contOCN,zdivOCN,hdivOCN,msk);
    glo_heat_ice=calc_budget_mean_mask(contICE,zdivICE,hdivICE,msk);
    
    %compute northern hemisphere integrals:
    msk=mygrid.mskC(:,:,kBudget).*(mygrid.YC>0);
    north_heat_tot=calc_budget_mean_mask(contTOT,zdivTOT,hdivTOT,msk);
    north_heat_ocn=calc_budget_mean_mask(contOCN,zdivOCN,hdivOCN,msk);
    north_heat_ice=calc_budget_mean_mask(contICE,zdivICE,hdivICE,msk);
    
    %and southern hemisphere integrals:
    msk=mygrid.mskC(:,:,kBudget).*(mygrid.YC<=0);
    south_heat_tot=calc_budget_mean_mask(contTOT,zdivTOT,hdivTOT,msk);
    south_heat_ocn=calc_budget_mean_mask(contOCN,zdivOCN,hdivOCN,msk);
    south_heat_ice=calc_budget_mean_mask(contICE,zdivICE,hdivICE,msk);
    
    %=======SALT=======
    
    contOCN=myparms.rhoconst*SALT-myparms.rhoconst*AB_gS;
    contICE=myparms.SIsal0*myparms.rhoi*SIheff;
    contTOT=contOCN+contICE;
    %vertical divergence (air-sea fluxes or vertical adv/dif)
    zdivOCN=SFLUX+oceSPflx;
    zdivICE=-zdivOCN+SRELAX;
    %in linear surface we omit :
    if ~myparms.useNLFS; zdivOCN=zdivOCN-myparms.rhoconst*WSLTMASS; end;
    %working approach for real fresh water (?) and virtual salt flux
    if ~myparms.useRFWF|~myparms.useNLFS; zdivICE=-oceSflux; end;
    %for deep ocean layer :
    if kBudget>1;
        zdivOCN=-(ADVr_SLT+DFrE_SLT+DFrI_SLT)./mygrid.RAC*myparms.rhoconst;
        zdivOCN=zdivOCN+oceSPtnd;%.*msk;
    end;
    zdivTOT=zdivOCN+zdivICE;
    %horizontal divergence (advection and diffusion)
    tmpU=myparms.rhoconst*(ADVx_SLT+DFxE_SLT); tmpV=myparms.rhoconst*(ADVy_SLT+DFyE_SLT);
    hdivOCN=calc_UV_div(tmpU,tmpV);
    tmpU=myparms.SIsal0*(myparms.rhoi*DFxEHEFF+myparms.rhoi*ADVxHEFF);
    tmpV=myparms.SIsal0*(myparms.rhoi*DFyEHEFF+myparms.rhoi*ADVyHEFF);
    hdivICE=calc_UV_div(tmpU,tmpV); %no dh needed here
    hdivTOT=hdivOCN+hdivICE;
    
    %compute global integrals:
    %-------------------------
    msk=mygrid.mskC(:,:,kBudget);
    glo_salt_tot=calc_budget_mean_mask(contTOT,zdivTOT,hdivTOT,msk);
    glo_salt_ocn=calc_budget_mean_mask(contOCN,zdivOCN,hdivOCN,msk);
    glo_salt_ice=calc_budget_mean_mask(contICE,zdivICE,hdivICE,msk);
    
    %compute northern hemisphere integrals:
    msk=mygrid.mskC(:,:,kBudget).*(mygrid.YC>0);
    north_salt_tot=calc_budget_mean_mask(contTOT,zdivTOT,hdivTOT,msk);
    north_salt_ocn=calc_budget_mean_mask(contOCN,zdivOCN,hdivOCN,msk);
    north_salt_ice=calc_budget_mean_mask(contICE,zdivICE,hdivICE,msk);
    
    %and southern hemisphere integrals:
    msk=mygrid.mskC(:,:,kBudget).*(mygrid.YC<=0);
    south_salt_tot=calc_budget_mean_mask(contTOT,zdivTOT,hdivTOT,msk);
    south_salt_ocn=calc_budget_mean_mask(contOCN,zdivOCN,hdivOCN,msk);
    south_salt_ice=calc_budget_mean_mask(contICE,zdivICE,hdivICE,msk);

%===================== COMPUTATIONAL SEQUENCE ENDS =========================%
%===================== PLOTTING SEQUENCE BEGINS    =========================%

elseif userStep==-1;%plotting

    if isempty(setDiagsParams);
      choicePlot={'all'};
    elseif isnumeric(setDiagsParams{1})&length(setDiagsParams)==1;
      choicePlot={'all'};
    elseif isnumeric(setDiagsParams{1});
      choicePlot={setDiagsParams{2:end}};
    else;
      choicePlot=setDiagsParams;
    end;

    tt=[1:length(alldiag.listTimes)];
    TT=alldiag.listTimes(tt);
    nt=length(TT);

    if (kBudget==1)&(sum(strcmp(choicePlot,'all'))|sum(strcmp(choicePlot,'mass')));

        %1.1) ocean+seaice mass budgets
        %------------------------------
        figureL;
        %global volume budget:
        subplot(3,1,1); disp_budget_mean_mask(TT,alldiag.glo_vol_tot,'kg/m2','Global Mean Mass (incl. ice)');
        %add bp:
        dt=median(diff(TT))*86400; bp=dt*cumsum(alldiag.glo_bp);
        plot(TT,bp,'k'); aa=legend; bb=get(aa,'String'); bb={bb{:},'bp'}; legend(bb,'Orientation','horizontal');
        %northern hemisphere budget:
        subplot(3,1,2); disp_budget_mean_mask(TT,alldiag.north_vol_tot,'kg/m2','Northern Mean Mass (incl. ice)');
        %add bp:
        dt=median(diff(TT))*86400; bp=dt*cumsum(alldiag.north_bp);
        plot(TT,bp,'k'); aa=legend; bb=get(aa,'String'); bb={bb{:},'bp'}; legend(bb,'Orientation','horizontal');
        %southern hemisphere budget:
        subplot(3,1,3); disp_budget_mean_mask(TT,alldiag.south_vol_tot,'kg/m2','Southern Mean Mass (incl. ice)');
        %add bp:
        dt=median(diff(TT))*86400; bp=dt*cumsum(alldiag.south_bp);
        plot(TT,bp,'k'); aa=legend; bb=get(aa,'String'); bb={bb{:},'bp'}; legend(bb,'Orientation','horizontal');
        %add to tex file
        myCaption={myYmeanTxt,' global (upper) north (mid) and south (lower), '};
        myCaption={myCaption{:},'mass budget (ocean+ice) in kg/m2.'};
        if addToTex&multiTimes; write2tex(fileTex,2,myCaption,gcf); elseif ~multiTimes; close; end;

        %1.2) ice mass budgets
        %---------------------
        figureL;
        subplot(3,1,1); disp_budget_mean_mask(TT,alldiag.glo_vol_ice,'kg/m2','Global Mean Mass (only ice)');
        dt=median(diff(TT))*86400; bp=dt*cumsum(alldiag.glo_bp);
        plot(TT,bp,'k'); aa=legend; bb=get(aa,'String'); bb={bb{:},'bp'}; legend(bb,'Orientation','horizontal');
        subplot(3,1,2); disp_budget_mean_mask(TT,alldiag.north_vol_ice,'kg/m2','Northern Mean Mass (only ice)');
        dt=median(diff(TT))*86400; bp=dt*cumsum(alldiag.north_bp);
        plot(TT,bp,'k'); aa=legend; bb=get(aa,'String'); bb={bb{:},'bp'}; legend(bb,'Orientation','horizontal');
        subplot(3,1,3); disp_budget_mean_mask(TT,alldiag.south_vol_ice,'kg/m2','Southern Mean Mass (only ice)');
        dt=median(diff(TT))*86400; bp=dt*cumsum(alldiag.south_bp);
        plot(TT,bp,'k'); aa=legend; bb=get(aa,'String'); bb={bb{:},'bp'}; legend(bb,'Orientation','horizontal');
        %add to tex file
        myCaption={myYmeanTxt,' global (upper) north (mid) and south (lower), '};
        myCaption={myCaption{:},'mass budget (ice only) in kg/m2.'};
        if addToTex&multiTimes; write2tex(fileTex,2,myCaption,gcf); elseif ~multiTimes; close; end;

    end;

    if (sum(strcmp(choicePlot,'all'))|sum(strcmp(choicePlot,'mass')));

    %1.3) ocean mass budgets
    %-----------------------
    figureL;
    %global volume budget:
    subplot(3,1,1); disp_budget_mean_mask(TT,alldiag.glo_vol_ocn,'kg/m2','Global Mean Mass (only ocean)');
    dt=median(diff(TT))*86400; bp=dt*cumsum(alldiag.glo_bp);
    plot(TT,bp,'k'); aa=legend; bb=get(aa,'String'); bb={bb{:},'bp'}; legend(bb,'Orientation','horizontal');
    subplot(3,1,2); disp_budget_mean_mask(TT,alldiag.north_vol_ocn,'kg/m2','Northern Mean Mass (only ocean)');
    dt=median(diff(TT))*86400; bp=dt*cumsum(alldiag.north_bp);
    plot(TT,bp,'k'); aa=legend; bb=get(aa,'String'); bb={bb{:},'bp'}; legend(bb,'Orientation','horizontal');
    subplot(3,1,3); disp_budget_mean_mask(TT,alldiag.south_vol_ocn,'kg/m2','Southern Mean Mass (only ocean)');
    dt=median(diff(TT))*86400; bp=dt*cumsum(alldiag.south_bp);
    plot(TT,bp,'k'); aa=legend; bb=get(aa,'String'); bb={bb{:},'bp'}; legend(bb,'Orientation','horizontal');
    %add to tex file
    myCaption={myYmeanTxt,' global (upper) north (mid) and south (lower), '};
    myCaption={myCaption{:},'mass budget (ocean only) in kg/m2.'};
    if addToTex&multiTimes; write2tex(fileTex,2,myCaption,gcf); elseif ~multiTimes; close; end;

    end;

    if (kBudget==1)&(sum(strcmp(choicePlot,'all'))|sum(strcmp(choicePlot,'heat')));

        %2.1) ocean+seaice heat budgets
        %------------------------------
        figureL;
        subplot(3,1,1); disp_budget_mean_mask(TT,alldiag.glo_heat_tot,'J/m2','Global Mean Ocean Heat (incl. ice)');
        subplot(3,1,2); disp_budget_mean_mask(TT,alldiag.north_heat_tot,'J/m2','Northern Mean Ocean Heat (incl. ice)');
        subplot(3,1,3); disp_budget_mean_mask(TT,alldiag.south_heat_tot,'J/m2','Southern Mean Ocean Heat (incl. ice)');
        %add to tex file
        myCaption={myYmeanTxt,' global (upper) north (mid) and south (lower), '};
        myCaption={myCaption{:},'heat budget (ocean+ice) in J/m2.'};
        if addToTex&multiTimes; write2tex(fileTex,2,myCaption,gcf); elseif ~multiTimes; close; end;

        %2.2) ice heat budgets
        %---------------------
        figureL;
        subplot(3,1,1); disp_budget_mean_mask(TT,alldiag.glo_heat_ice,'J/m2','Global Mean Ocean Heat (only ice)');
        subplot(3,1,2); disp_budget_mean_mask(TT,alldiag.north_heat_ice,'J/m2','Northern Mean Ocean Heat (only ice)');
        subplot(3,1,3); disp_budget_mean_mask(TT,alldiag.south_heat_ice,'J/m2','Southern Mean Ocean Heat (only ice)');
        %add to tex file
        myCaption={myYmeanTxt,' global (upper) north (mid) and south (lower), '};
        myCaption={myCaption{:},'heat budget (ice only) in J/m2.'};
        if addToTex&multiTimes; write2tex(fileTex,2,myCaption,gcf); elseif ~multiTimes; close; end;

    end;

    if (sum(strcmp(choicePlot,'all'))|sum(strcmp(choicePlot,'heat')));

    %2.3) ocean heat budgets
    %-----------------------
    figureL;
    subplot(3,1,1); disp_budget_mean_mask(TT,alldiag.glo_heat_ocn,'J/m2','Global Mean Ocean Heat (only ocean)');
    subplot(3,1,2); disp_budget_mean_mask(TT,alldiag.north_heat_ocn,'J/m2','Northern Mean Ocean Heat (only ocean)');
    subplot(3,1,3); disp_budget_mean_mask(TT,alldiag.south_heat_ocn,'J/m2','Southern Mean Ocean Heat (only ocean)');
    %add to tex file
    myCaption={myYmeanTxt,' global (upper) north (mid) and south (lower), '};
    myCaption={myCaption{:},'heat budget (ocean only) in J/m2.'};
    if addToTex&multiTimes; write2tex(fileTex,2,myCaption,gcf); elseif ~multiTimes; close; end;

    end;

    if (kBudget==1)&(sum(strcmp(choicePlot,'all'))|sum(strcmp(choicePlot,'salt')));

        %3.1) ocean+seaice salt budgets
        %------------------------------
        figureL;
        subplot(3,1,1); disp_budget_mean_mask(TT,alldiag.glo_salt_tot,'g/m2','Global Mean Ocean Salt (incl. ice)');
        subplot(3,1,2); disp_budget_mean_mask(TT,alldiag.north_salt_tot,'g/m2','Northern Mean Ocean Salt (incl. ice)');
        subplot(3,1,3); disp_budget_mean_mask(TT,alldiag.south_salt_tot,'g/m2','Southern Mean Ocean Salt (incl. ice)');
        %add to tex file
        myCaption={myYmeanTxt,' global (upper) north (mid) and south (lower), '};
        myCaption={myCaption{:},'salt budget (ocean+ice) in g/m2.'};
        if addToTex&multiTimes; write2tex(fileTex,2,myCaption,gcf); elseif ~multiTimes; close; end;

        %2.2) ice salt budgets
        %---------------------
        figureL;
        subplot(3,1,1); disp_budget_mean_mask(TT,alldiag.glo_salt_ice,'g/m2','Global Mean Ocean Salt (only ice)');
        subplot(3,1,2); disp_budget_mean_mask(TT,alldiag.north_salt_ice,'g/m2','Northern Mean Ocean Salt (only ice)');
        subplot(3,1,3); disp_budget_mean_mask(TT,alldiag.south_salt_ice,'g/m2','Southern Mean Ocean Salt (only ice)');
        %add to tex file
        myCaption={myYmeanTxt,' global (upper) north (mid) and south (lower), '};
        myCaption={myCaption{:},'salt budget (ice only) in g/m2.'};
        if addToTex&multiTimes; write2tex(fileTex,2,myCaption,gcf); elseif ~multiTimes; close; end;

    end;


    if (sum(strcmp(choicePlot,'all'))|sum(strcmp(choicePlot,'salt')));

    %3.3) ocean salt budgets
    %-----------------------
    figureL;
    subplot(3,1,1); disp_budget_mean_mask(TT,alldiag.glo_salt_ocn,'g/m2','Global Mean Ocean Salt (incl. ice)');
    subplot(3,1,2); disp_budget_mean_mask(TT,alldiag.north_salt_ocn,'g/m2','Northern Mean Ocean Salt (incl. ice)');
    subplot(3,1,3); disp_budget_mean_mask(TT,alldiag.south_salt_ocn,'g/m2','Southern Mean Ocean Salt (incl. ice)');
    %add to tex file
    myCaption={myYmeanTxt,' global (upper) north (mid) and south (lower), '};
    myCaption={myCaption{:},'salt budget (ocean only) in g/m2.'};
    if addToTex&multiTimes; write2tex(fileTex,2,myCaption,gcf); elseif ~multiTimes; close; end;

    end;

end;
