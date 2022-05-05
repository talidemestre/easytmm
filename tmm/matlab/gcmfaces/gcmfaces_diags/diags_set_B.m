
if userStep==1;%diags to be computed
    %here _s stands for cumulative sum and _2s for cumulative sum of squares
    %the _s should be stated first
    listDiags=['THETA_s SALT_s SIatmQnt_s SIatmFW_s oceQnet_s oceFWflx_s ' ...
               'fldTZ_s fldTM_s curlTau_s fldETAN_s fldETANLEADS_s fldMLD_s ' ...
               'THETA_2s SALT_2s SIatmQnt_2s SIatmFW_2s oceQnet_2s oceFWflx_2s ' ...
               'fldTZ_2s fldTM_2s curlTau_2s fldETAN_2s fldETANLEADS_2s fldMLD_2s'];

elseif userStep==2;%input files and variables
    listFlds={    'THETA','SALT','SIatmQnt','SIatmFW ','oceQnet ','oceFWflx','oceTAUX','oceTAUY','ETAN','sIceLoad','MXLDEPTH'};
    listFldsNames=deblank(listFlds);
    listFiles={'state_3d_set1','state_2d_set1','other_2d_set1'};
    listSubdirs={[dirModel 'diags/OTHER/' ],[dirModel 'diags/STATE/' ]};

elseif userStep==3;%computation
    %mask fields:
    SIatmQnt=SIatmQnt.*mygrid.mskC(:,:,1);
    SIatmFW=SIatmFW.*mygrid.mskC(:,:,1);
    oceQnet=oceQnet.*mygrid.mskC(:,:,1);
    oceFWflx=oceFWflx.*mygrid.mskC(:,:,1);
    fldTX=oceTAUX.*mygrid.mskW(:,:,1);
    fldTY=oceTAUY.*mygrid.mskS(:,:,1);
    %compute Eastward/Northward wind stresses:
    [fldTZ,fldTM]=calc_UEVNfromUXVY(fldTX,fldTY);
    %compute wind stress curl:
    curlTau=calc_UV_curl(fldTX, fldTY,1 );%the doMask argument should not matter as msk was already applied
    %mask and re-arrange fields:
    fldETAN=ETAN.*mygrid.mskC(:,:,1);
    fldETANLEADS=(ETAN+sIceLoad/myparms.rhoconst).*mygrid.mskC(:,:,1);
    fldMLD=MXLDEPTH.*mygrid.mskC(:,:,1);
    %
    THETA=THETA.*mygrid.mskC;
    SALT=SALT.*mygrid.mskC;
    %
    if ii>1;
      fileMatPrev=['diags_set_' tmp1 '_' num2str(listTimes(ii-1)) '.mat'];
      listTimesBak=listTimes;
      load([dirMat fileMatPrev]);
      listTimes=listTimesBak;
    end;
    for jj=1:length(listDiags)/2;
        myDiag=listDiags{jj}(1:end-2);
        if ii==1;
            eval([myDiag '_s=0*' myDiag ';']);
            eval([myDiag '_2s=0*' myDiag '.^2;']);
        end;
        eval([myDiag '_s=' myDiag '_s+' myDiag ';']);
        eval([myDiag '_2s=' myDiag '_2s+' myDiag '.^2;']);
    end;

%===================== COMPUTATIONAL SEQUENCE ENDS =========================%
%===================== PLOTTING SEQUENCE BEGINS    =========================%

elseif userStep==0;%loading / post-processing of mat files

  %load last cumsum
  alldiag=alldiag_load(dirMat,[fileMat '_*.mat'],'',myparms.recInAve(2));
  %load first cumsum
  if myparms.recInAve(1)>1;
    tmpdiag=alldiag_load(dirMat,[fileMat '_*.mat'],'',myparms.recInAve(1)-1);
    for ii=1:length(alldiag.listDiags);
         tmp0=alldiag.listDiags{ii};
         if ~strcmp(tmp0,'listTimes')&~strcmp(tmp0,'listSteps');
           tmp1=getfield(alldiag,alldiag.listDiags{ii});
           tmp2=getfield(tmpdiag,alldiag.listDiags{ii});
           alldiag=setfield(alldiag,tmp0,tmp1-tmp2);
         end;
    end;
  end;
  %accomodate missing fields (old MITgcm version)
  listFlds={'SIatmQnt_s','oceQnet_s','SIatmFW_s','oceFWflx_s',...
            'fldTZ_s','fldTM_s','curlTau_s','fldETAN_s','fldETANLEADS_s',...
            'SIatmQnt_2s','oceQnet_2s','SIatmFW_2s','oceFWflx_2s',...
            'fldTZ_2s','fldTM_2s','curlTau_2s','fldETAN_2s','fldETANLEADS_2s'};
  for ii=1:length(listFlds);
    if ~sum(strcmp(fieldnames(alldiag),listFlds{ii}));
      eval(['alldiag.' listFlds{ii} '=NaN*alldiag.fldETAN_s;']);
    end;
  end;
  %
  n=diff(myparms.recInAve)+1;
  for ii=1:length(alldiag.listDiags)/2;
     tmp0=alldiag.listDiags{ii};
     if ~strcmp(tmp0,'listTimes')&~strcmp(tmp0,'listSteps');
       tmp1=1/n*getfield(alldiag,tmp0);
       tmp2=1/n*getfield(alldiag,[tmp0(1:end-1) '2s']);
       tmp2=(tmp2-tmp1.^2);
       tmp2=n/(n-1)*tmp2;
       %tmp2(tmp2<0)=0;
       tmp2=sqrt(tmp2);
       alldiag=setfield(alldiag,[tmp0(1:end-2) '_mean'],tmp1);
       alldiag=setfield(alldiag,[tmp0(1:end-2) '_std'],tmp2);
     end;
  end;

  diagsWereLoaded=1

elseif userStep==-1;%plotting

    if isempty(setDiagsParams); 
      choicePlot={'all'};
    else;
      choicePlot=setDiagsParams;
    end;

    if sum(strcmp(choicePlot,'all'))|sum(strcmp(choicePlot,'qnet'));

    %qnet from ocean+ice:
    fld=-alldiag.SIatmQnt_mean;
    cc=[[-250:50:-100] [-75 -50] [-35:10:35] [50 75] [100:50:250]]; title0='QNET to ocean+ice';
    if doAnomalies; cc=scaleAnom*[-1:0.1:1]*10; end;
    figureL; m_map_gcmfaces(fld,0,{'myCaxis',cc},{'do_m_coast',1},{'myTitle',title0});
    myCaption={myYmeanTxt,'mean -- QNET to ocean+ice (W/m2)'};
    if addToTex; write2tex(fileTex,2,myCaption,gcf); end;

    %qnet to ocean:
    fld=alldiag.oceQnet_mean;
    cc=[[-250:50:-100] [-75 -50] [-35:10:35] [50 75] [100:50:250]]; title0='QNET to ocean';
    if doAnomalies; cc=scaleAnom*[-1:0.1:1]*10; end;
    figureL; m_map_gcmfaces(fld,0,{'myCaxis',cc},{'do_m_coast',1},{'myTitle',title0});
    myCaption={myYmeanTxt,'mean -- QNET to ocean (W/m2)'};
    if addToTex; write2tex(fileTex,2,myCaption,gcf); end;
   
    if multiTimes;
        %qnet from ocean+ice:
        fld=alldiag.SIatmQnt_std;
        cc=[[0:5:25] 35 [50:25:200] [250 300]]; title0='std(QNET to ocean+ice)';
        if doAnomalies; cc=scaleAnom*[0:0.1:1]*5; end;
        figureL; m_map_gcmfaces(fld,0,{'myCaxis',cc},{'do_m_coast',1},{'myTitle',title0});
        myCaption={myYmeanTxt,'  standard deviation -- QNET to ocean+ice (W/m2)'};
        if addToTex; write2tex(fileTex,2,myCaption,gcf); end;

        %qnet from ocean:
        fld=alldiag.oceQnet_std;
        cc=[[0:5:25] 35 [50:25:200] [250 300]]; title0='std(QNET to ocean)';
        if doAnomalies; cc=scaleAnom*[0:0.1:1]*5; end;
        figureL; m_map_gcmfaces(fld,0,{'myCaxis',cc},{'do_m_coast',1},{'myTitle',title0});
        myCaption={myYmeanTxt,'  standard deviation -- QNET to ocean (W/m2)'};
        if addToTex; write2tex(fileTex,2,myCaption,gcf); end;
    end;

    end;


    if sum(strcmp(choicePlot,'all'))|sum(strcmp(choicePlot,'fwf'));

    %FW flux from ocean+ice:
    fld=-alldiag.SIatmFW_mean/1000;%conversion to m/s
    fld=fld*86400*1000;%conversion to mm/day
    cc=[[-250:50:-100] [-75 -50] [-35:10:35] [50 75] [100:50:250]]*0.06; title0='EMPMR to ocean+ice';
    if doAnomalies; cc=scaleAnom*[-1:0.1:1]*0.5; end;
    figureL; m_map_gcmfaces(fld,0,{'myCaxis',cc},{'do_m_coast',1},{'myTitle',title0});
    myCaption={myYmeanTxt,'mean -- EMPMR from ocean+ice (mm/day)'};
    if addToTex; write2tex(fileTex,2,myCaption,gcf); end;

    %FW flux from ocean:
    fld=-alldiag.oceFWflx_mean/1000;%conversion to m/s
    fld=fld*86400*1000;%conversion to mm/day
    cc=[[-250:50:-100] [-75 -50] [-35:10:35] [50 75] [100:50:250]]*0.06; title0='EMPMR to ocean';
    if doAnomalies; cc=scaleAnom*[-1:0.1:1]*0.5; end;
    figureL; m_map_gcmfaces(fld,0,{'myCaxis',cc},{'do_m_coast',1},{'myTitle',title0});
    myCaption={myYmeanTxt,'mean -- EMPMR from ocean (mm/day)'};
    if addToTex; write2tex(fileTex,2,myCaption,gcf); end;

    if multiTimes;
        %empmr from ocean+ice:
        fld=alldiag.SIatmFW_std*86400;%conversion to mm/day
        cc=[[0:5:25] 35 [50:25:200] [250 300]]*0.04; title0='std(EMPMR to ocean+ice)';
        if doAnomalies; cc=scaleAnom*[0:0.1:1]*0.5; end;
        figureL; m_map_gcmfaces(fld,0,{'myCaxis',cc},{'do_m_coast',1},{'myTitle',title0});
        myCaption={myYmeanTxt,' standard deviation -- EMPMR to ocean+ice (W/m2)'};
        if addToTex; write2tex(fileTex,2,myCaption,gcf); end;

        %empmr from ocean:
        fld=alldiag.oceFWflx_std*86400;%conversion to mm/day
        cc=[[0:5:25] 35 [50:25:200] [250 300]]*0.04; title0='std(EMPMR to ocean)';
        if doAnomalies; cc=scaleAnom*[0:0.1:1]*0.5; end;
        figureL; m_map_gcmfaces(fld,0,{'myCaxis',cc},{'do_m_coast',1},{'myTitle',title0});
        myCaption={myYmeanTxt,' standard deviation -- EMPMR to ocean (W/m2)'};
        if addToTex; write2tex(fileTex,2,myCaption,gcf); end;
    end;

    end;

    if sum(strcmp(choicePlot,'all'))|sum(strcmp(choicePlot,'tau'));

    %zonal wind stress:
    fld=alldiag.fldTZ_mean;
    cc=[[-250:50:-100] [-75 -50] [-35:10:35] [50 75] [100:50:250]]/500; title0='zonal wind stress';
    if doAnomalies; cc=scaleAnom*[-1:0.1:1]*0.01; end;
    figureL; m_map_gcmfaces(fld,0,{'myCaxis',cc},{'do_m_coast',1},{'myTitle',title0});
    myCaption={myYmeanTxt,'mean -- zonal wind stress (N/m2)'};
    if addToTex; write2tex(fileTex,2,myCaption,gcf); end;

    %meridional wind stress:
    fld=alldiag.fldTM_mean;
    cc=[[-250:50:-100] [-75 -50] [-35:10:35] [50 75] [100:50:250]]/500; title0='meridional wind stress';
    if doAnomalies; cc=scaleAnom*[-1:0.1:1]*0.01; end;
    figureL; m_map_gcmfaces(fld,0,{'myCaxis',cc},{'do_m_coast',1},{'myTitle',title0});
    myCaption={myYmeanTxt,'mean -- meridional wind stress (N/m2)'};
    if addToTex; write2tex(fileTex,2,myCaption,gcf); end;

    fld=alldiag.curlTau_mean;
    cc=[[-250:50:-100] [-75 -50] [-35:10:35] [50 75] [100:50:250]]/5e8; title0='wind stress curl';
    if doAnomalies; cc=scaleAnom*[-1:0.1:1]*0.01; end;
    figureL; m_map_gcmfaces(fld,0,{'myCaxis',cc},{'do_m_coast',1},{'myTitle',title0});
    myCaption={myYmeanTxt,'mean -- wind stress curl (N/m3)'};
    if addToTex; write2tex(fileTex,2,myCaption,gcf); end;

    if multiTimes;
        %zonal wind stress:
        fld=alldiag.fldTZ_std;
        cc=[[0:5:25] 35 [50:25:200] [250 300]]/2000; title0='std(tauZ)';
        if doAnomalies; cc=scaleAnom*[0:0.1:1]*0.005; end;
        figureL; m_map_gcmfaces(fld,0,{'myCaxis',cc},{'do_m_coast',1},{'myTitle',title0});
        myCaption={myYmeanTxt,'  standard deviation -- tauZ (W/m2)'};
        if addToTex; write2tex(fileTex,2,myCaption,gcf); end;

        %meridional wind stress:
        fld=alldiag.fldTM_std;
        cc=[[0:5:25] 35 [50:25:200] [250 300]]/2000; title0='std(tauM)';
        if doAnomalies; cc=scaleAnom*[0:0.1:1]*0.005; end;
        figureL; m_map_gcmfaces(fld,0,{'myCaxis',cc},{'do_m_coast',1},{'myTitle',title0});
        myCaption={myYmeanTxt,' standard deviation -- tauM (W/m2)'};
        if addToTex; write2tex(fileTex,2,myCaption,gcf); end;

        fld=alldiag.curlTau_std;
        cc=[[0:5:25] 35 [50:25:200] [250 300]]/1e9; title0='wind stress curl';
        if doAnomalies; cc=scaleAnom*[-1:0.1:1]*0.01; end;
        figureL; m_map_gcmfaces(fld,0,{'myCaxis',cc},{'do_m_coast',1},{'myTitle',title0});
        myCaption={myYmeanTxt,'standard deviation -- tauCurl (N/m3)'};
        if addToTex; write2tex(fileTex,2,myCaption,gcf); end;
    end;

    end;

    if sum(strcmp(choicePlot,'all'))|sum(strcmp(choicePlot,'ssh'));

    %ETAN:
    fld=alldiag.fldETAN_mean;
    cc=[[-250:50:-100] [-75 -50] [-35:10:35] [50 75] [100:50:250]]/100; title0='sea surface height (EXCLUDING ice)';
    if doAnomalies; cc=scaleAnom*[-1:0.1:1]*0.05; end;
    figureL; m_map_gcmfaces(fld,0,{'myCaxis',cc},{'do_m_coast',1},{'myTitle',title0});
    myCaption={myYmeanTxt,'mean -- sea surface height (EXCLUDING ice, in m)'};
    if addToTex; write2tex(fileTex,2,myCaption,gcf); end;

    %ETANLEADS:
    fld=alldiag.fldETANLEADS_mean;
    cc=[[-250:50:-100] [-75 -50] [-35:10:35] [50 75] [100:50:250]]/100; title0='sea surface height (INCLUDING ice)';
    if doAnomalies; cc=scaleAnom*[-1:0.1:1]*0.05; end;
    figureL; m_map_gcmfaces(fld,0,{'myCaxis',cc},{'do_m_coast',1},{'myTitle',title0});
    myCaption={myYmeanTxt,'mean -- sea surface height (INCLUDING ice, in m)'};
    if addToTex; write2tex(fileTex,2,myCaption,gcf); end;

    if multiTimes;
        %ETAN:
        fld=alldiag.fldETAN_std;
        cc=[0:25:500]/2500; title0='std(ETAN)';
        if doAnomalies; cc=scaleAnom*[0:0.1:1]*0.02; end;
        figureL; m_map_gcmfaces(fld,0,{'myCaxis',cc},{'do_m_coast',1},{'myTitle',title0});
        myCaption={myYmeanTxt,' standard deviation -- sea surface height (EXCLUDING ice, in m)'};
        if addToTex; write2tex(fileTex,2,myCaption,gcf); end;

        %ETANLEADS:
        fld=alldiag.fldETANLEADS_std;
        cc=[0:25:500]/2500; title0='std(ETANLEADS)';
        if doAnomalies; cc=scaleAnom*[0:0.1:1]*0.02; end;
        figureL; m_map_gcmfaces(fld,0,{'myCaxis',cc},{'do_m_coast',1},{'myTitle',title0});
        myCaption={myYmeanTxt,' standard deviation -- sea surface height (INCLUDING ice, in m)'};
        if addToTex; write2tex(fileTex,2,myCaption,gcf); end;
    end;

    end;

end;


