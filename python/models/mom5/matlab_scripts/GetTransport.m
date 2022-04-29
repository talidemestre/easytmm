function []=GetTransport(filedir, ntiles)
	try

	numExpTend=12;
	numImpTend=12;
	maxVal=0;
	minVal=1e-30;
	fileroot='transport_';
		
	load grid nx ny nz gridType
	load matrix_extraction_run_data
	load boxes nb ixBox iyBox izBox
	load tracer_tiles
	load boxnum

	nhv_e=nhh;
	nhv_i=-1;

	for runId = 1:ntiles;

	depths=tracer_run_data.depths(:,runId);
	iSet=tracer_run_data.groups(runId);
	maxTracers=length(depths);
	iTiles=tracerTiles{iSet};
	numTiles=length(iTiles);

	disp(['Computing transport for run ' int2str(runId) ' ...'])

	% Explicit matrix:
	% precompute halos 
	disp('Explicit matrix ...')
	maxhalo=(((2*nhh+1)^2)*(2*nhv_e+1));
	ia=repmat(0,[numTiles*maxTracers*maxhalo 1]);
	ja=repmat(0,[numTiles*maxTracers*maxhalo 1]);
	itr=repmat(0,[numTiles*maxTracers*maxhalo 1]);
	is=0;
	ie=0;  
	for ib=1:numTiles % loop over each (surface) box
		iBox=iTiles(ib);	
	local_column=get_halo3(iBox,0,1,-1,nbhalo,boxnum,ixBox,iyBox,izBox); % local water column boxes	
	nv=length(local_column);
	iloc=depths(find(depths<=nv));
	if ~isempty(iloc)
			deltas=local_column(iloc);
			nd=length(deltas);
			for iz=1:nd  % loop over all points where delta was placed
				iDelta=deltas(iz); % box where delta was placed
			halo=get_halo3(iDelta,nhh,2,nhv_e,nbhalo,boxnum,ixBox,iyBox,izBox,overflows,0); % halo for explicit transport			
			nh=length(halo);
			is=ie+1;
			ie=is+nh-1;
			ia(is:ie)=halo;
				ja(is:ie)=repmat(iDelta,[nh 1]);       
			itr(is:ie)=repmat(iz,[nh 1]);
			end
	end
	end
	ia=ia(1:ie);
	ja=ja(1:ie);
	itr=itr(1:ie);  
	index=sub2ind([nx ny nz maxTracers],ixBox(ia),iyBox(ia),izBox(ia),itr);

	disp('Done precomputing explicit matrix halos')
	disp('Processing explicit matrix')

	TE=repmat(0,[nx ny nz maxTracers]);
	for im=1:numExpTend % for each month
	for iTracerNum=1:maxTracers
		varName=['exp_tm_' sprintf('%02d',iTracerNum)];
		fn=fullfile(filedir,[fileroot sprintf('%02d',runId) '.nc']);      
		tmp=ncread(fn,varName,[1 1 1 im],[nx ny nz 1]); % (x,y,z)
		TE(:,:,:,iTracerNum)=tmp;
	end
	
		aa=TE(index); % tendency at iRow due to delta at iDelta
	aa=aa+minVal;
	if numExpTend>1
		suff=['_' sprintf('%02d',im)];
	else
		suff='';
	end    

		if maxVal>0
		k=find(abs(aa)>=maxVal); ia1=ia(k);ja1=ja(k);aa1=aa(k);     
		Aexp=sparse(ia1,ja1,aa1,nb,nb);
		else
		Aexp=sparse(ia,ja,aa,nb,nb);
		end
		save(fullfile(filedir, ['Aexp' sprintf('%02d',runId) suff]),'Aexp','-v7.3')
		clear Aexp
	end % end explicit matrix

	% Implicit matrix
	% precompute halos
	disp('Implicit matrix...')
	maxhalo=nz
	ia=repmat(0,[numTiles*maxTracers*maxhalo 1]);
	ja=repmat(0,[numTiles*maxTracers*maxhalo 1]);
	itr=repmat(0,[numTiles*maxTracers*maxhalo 1]);
	is=0;
	ie=0;  
	for ib=1:numTiles % loop over each (surface) box
		iBox=iTiles(ib);
	local_column=get_halo3(iBox,0,1,-1,nbhalo,boxnum,ixBox,iyBox,izBox); % local water column boxes	
	nv=length(local_column);
	iloc=depths(find(depths<=nv));
	if ~isempty(iloc)     
			deltas=local_column(iloc);
			nd=length(deltas);
			halo=local_column; % halo for implicit vertical transport
			nh=length(halo);
			for iz=1:nd  % loop over all points where delta was placed
			iDelta=deltas(iz); % box where delta was placed
			is=ie+1;
			ie=is+nh-1;
			ia(is:ie)=halo;
			ja(is:ie)=repmat(iDelta,[nh 1]);
			itr(is:ie)=repmat(iz,[nh 1]);         
			end
	end
	end
	ia=ia(1:ie);
	ja=ja(1:ie);
	itr=itr(1:ie);
	index=sub2ind([nx ny nz maxTracers],ixBox(ia),iyBox(ia),izBox(ia),itr);
	
	disp('Done precomputing implicit matrix halos')  
	disp('Processing implicit matrix') 
	TE=repmat(0,[nx ny nz maxTracers]);

	for im=1:numImpTend % for each month
	for iTracerNum=1:maxTracers
		varName=['imp_tm_' sprintf('%02d',iTracerNum)]; 
		fn=fullfile(filedir,[fileroot sprintf('%02d',runId) '.nc']);       
		tmp=ncread(fn,varName,[1 1 1 im],[nx ny nz 1]); % (x,y,z)        	  
		TE(:,:,:,iTracerNum)=tmp; 
	end   
		aa=TE(index); % tendency at iRow due to delta at iDelta
	aa=aa+minVal;
	if numImpTend>1
			suff=['_' sprintf('%02d',im)];
	else
			suff='';
	end  
	if maxVal>0
			k=find(abs(aa)>=maxVal); ia1=ia(k);ja1=ja(k);aa1=aa(k);     
			Aimp=sparse(ia1,ja1,aa1,nb,nb);
	else
			Aimp=sparse(ia,ja,aa,nb,nb);
	end
	save(fullfile(filedir, ['Aimp' sprintf('%02d',runId) suff]),'Aimp','-v7.3')
	clear Aimp
	end % end implicit matrix


	end

	catch
	lasterr
	end

