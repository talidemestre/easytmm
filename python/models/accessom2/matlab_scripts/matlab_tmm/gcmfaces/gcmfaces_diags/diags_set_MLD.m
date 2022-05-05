

if userStep==1;%diags to be computed
    listDiags='fldMldBoyer fldMldSuga fldMldKara';
elseif userStep==2;%input files and variables
    listFlds={    'THETA','SALT'};
    listFldsNames=deblank(listFlds);
    listFiles={'monthly_2d_set1','monthly_3d_set1','state_2d_set1','other_2d_set1','state_3d_set1'};
elseif userStep==3;%computational part;
        fldT=THETA.*mygrid.mskC; fldS=SALT.*mygrid.mskC;
        %
        %prepare to compute potential density:
        fldP=0*mygrid.mskC; for kk=1:length(mygrid.RC); fldP(:,:,kk)=-mygrid.RC(kk); end;
        T=convert2vector(fldT);
        S=convert2vector(fldS);
        msk=convert2vector(mygrid.mskC);
        P=convert2vector(fldP);
        %compute potential density:
        RHO=0*msk; alpha=0*msk;
        tmp1=find(~isnan(msk));
        RHO(tmp1) = density(T(tmp1),S(tmp1),P(tmp1));
        fldRhoPot=convert2vector(RHO);
        alpha(tmp1) = density(T(tmp1)+1e-4,S(tmp1),P(tmp1));
        fldAlpha=(convert2vector(alpha)-fldRhoPot)/1e-4;

        clear T S P msk RHO RHOis tmp1;

        %compute mld:
        tmp1=NaN*mygrid.mskC(:,:,1);
        for kk=1:50;
          tmp2=fldRhoPot(:,:,kk)-fldRhoPot(:,:,1);
          %if we pass RHO(1)+0.03 for the first time (or we reach the bottom)
          %then mld is the velocity point above RC(kk), which is RF(kk)
          jj=find((tmp2>0.03|isnan(tmp2))&isnan(tmp1));
         tmp1(jj)=-mygrid.RF(kk);
        end;
        fldMldBoyer=tmp1;

        %compute mld:
        tmp1=NaN*mygrid.mskC(:,:,1);
        for kk=1:50;
          tmp2=fldRhoPot(:,:,kk)-fldRhoPot(:,:,1);
          %if we pass RHO(1)+0.125 for the first time (or we reach the bottom)
          %then mld is the velocity point above RC(kk), which is RF(kk)
          jj=find((tmp2>0.125|isnan(tmp2))&isnan(tmp1));
         tmp1(jj)=-mygrid.RF(kk);
        end;
        fldMldSuga=tmp1;

        %compute mld:
        tmp1=NaN*mygrid.mskC(:,:,1);
        fldRhoPotMax=fldRhoPot(:,:,1)-0.8*fldAlpha(:,:,1);
        for kk=1:50;
          tmp2=fldRhoPot(:,:,kk)-fldRhoPotMax;
          %if we pass RHO(1)+0.8*alpha(1) for the first time (or we reach the bottom)
          %then mld is the velocity point above RC(kk), which is RF(kk)
          jj=find((tmp2>0|isnan(tmp2))&isnan(tmp1));
         tmp1(jj)=-mygrid.RF(kk);
        end;
        fldMldKara=tmp1;

elseif userStep==-1;%computational part;
		
        fld=mean(alldiag.fldMldKara(:,:,tt),3);
        cc=[[0:20:100] [150:50:300] 400 [500:200:1100] [1500:500:2000]]; title0='Mixed Layer Depth (Kara)';
        if doAnomalies; cc=scaleAnom*[-5:0.5:5]; end;
        figureL; m_map_gcmfaces(fld,0,{'myCaxis',cc},{'do_m_coast',1},{'myTitle',title0});
        myCaption={myYmeanTxt,'mean -- Kara mld (m)'};
        if addToTex; write2tex(fileTex,2,myCaption,gcf); end;

        fld=mean(alldiag.fldMldSuga(:,:,tt),3);
        cc=[[0:20:100] [150:50:300] 400 [500:200:1100] [1500:500:2000]]; title0='Mixed Layer Depth (Suga)';
        if doAnomalies; cc=scaleAnom*[-5:0.5:5]; end;
        figureL; m_map_gcmfaces(fld,0,{'myCaxis',cc},{'do_m_coast',1},{'myTitle',title0});
        myCaption={myYmeanTxt,'mean -- Suga mld (m)'};
        if addToTex; write2tex(fileTex,2,myCaption,gcf); end;

        fld=mean(alldiag.fldMldBoyer(:,:,tt),3);
        cc=[[0:20:100] [150:50:300] 400 [500:200:1100] [1500:500:2000]]; title0='Mixed Layer Depth (Boyer)';
        if doAnomalies; cc=scaleAnom*[-5:0.5:5]; end;
        figureL; m_map_gcmfaces(fld,0,{'myCaxis',cc},{'do_m_coast',1},{'myTitle',title0});
        myCaption={myYmeanTxt,'mean -- Boyer mld (m)'};
        if addToTex; write2tex(fileTex,2,myCaption,gcf); end;

end;


