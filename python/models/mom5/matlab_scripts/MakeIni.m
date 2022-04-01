function []=MakeIni(tmm_libs, outdir, mom5TemplateFile)


    % matrixCalcInfo
    runId=1
    numExpTend=12;
    numImpTend=12;
    maxVal=0;
    minVal=1e-30;
    ptrName='ptr';
    mygcm='MOM5';
    tendFile='MATRIX';  

    try

    addpath(fullfile(tmm_libs,'Misc'))
    addpath(fullfile(tmm_libs,'TMM'))
    addpath(fullfile(tmm_libs,'gcmfaces'))
 
    load grid nx ny nz gridType
    load matrix_extraction_run_data
    load boxes nb ixBox iyBox izBox
    load tracer_tiles
    load boxnum

    ntile = length(tracerTiles)

    for runId=1:ntile
        depths=tracer_run_data.depths(:,runId);
        iSet=tracer_run_data.groups(runId);
        maxTracers=length(depths);
        iTiles=tracerTiles{iSet};
        numTiles=length(iTiles);
        dd=sprintf(strcat(outdir, '/set_%02d'), runId);
        mkdir(dd)

        disp(['Generating ICs for Set ' int2str(iSet)])

        for iTracerNum=1:maxTracers
            iz=depths(iTracerNum);
            disp(['Generating ICs for Set ' int2str(iSet) ' at depth level ' int2str(iz)])
            
            TRb=zeros(nb,1);  
            for ib=1:numTiles % loop over each (surface) box          
                iBox=iTiles(ib);
                local_column=get_halo3(iBox,0,1,-1,nbhalo,boxnum,ixBox,iyBox,izBox); % local water column boxes     
                nv=length(local_column);
                % Set tracer IC at specified depth  
                if iz<=nv
                    % disp(['z=',int2str(iz),', iBox=',int2str(iBox)])             
                    TRb(local_column(iz))=1;
                end
            end
            TR=matrixToGrid(TRb,[],'boxes','grid');
            TR(isnan(TR))=0;

            % write to file
            varName=[ptrName '_' sprintf('%02d',iTracerNum)];        
            fn=[varName '.nc'];
            copyfile(mom5TemplateFile, fn)
            ncid = netcdf.open(fn,'NC_WRITE');  
            varId = netcdf.inqVarID(ncid,'age_global');      
            netcdf.reDef(ncid);
            netcdf.renameVar(ncid,varId,varName);
            netcdf.endDef(ncid);
            netcdf.putVar(ncid,varId,TR);
            netcdf.close(ncid)   
            movefile(fn, dd)
        end
        disp(['Okay to start run number ' sprintf('%02d',runId)])
    end 

    catch
    lasterr
    end
end