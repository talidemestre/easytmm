% Compute horizontal tiles using graph partitioning
% base_path=fileparts(fileparts(pwd));
gridFile='grid';
load(gridFile,'gridType','useOverflows')

if useOverflows
  load overflow
else
  overflows=[];
end

load boxnum

if strcmp(gridType,'llc_v4')
  load boxes ixBoxFace iyBoxFace izBoxFace boxnumglob

  Ib=cellfun(@(x)find(x==1),izBoxFace,'UniformOutput',0);

  nFaces=length(Ib);
    
  ia=[];
  ja=[];
  
  for iF=1:nFaces  
	nbb=length(Ib{iF});
	ib=[];
	ib.facenum=iF;	
	for i=1:nbb
	  iBoxLoc=Ib{iF}(i); % local box number
	  iBoxGlob=boxnumglob{iF}(iBoxLoc); % global box number	  
	  ib.locnum=iBoxLoc;
      ib.globnum=iBoxGlob; 
	  halo=get_halo3(ib,nhh,0,0,nbhalo,boxnum,ixBoxFace,iyBoxFace,izBoxFace,overflows,1); % horizontal halo+surface overflow
	  nhalo=length(halo);
	  ia=[ia;repmat(iBoxGlob,[nhalo 1])];
	  ja=[ja;halo];
	end
  end  
  nbb=0;
  for iF=1:nFaces  
	nbb=nbb+length(Ib{iF});
  end
  S=sparse(ia,ja,1,nbb,nbb);


else
  load boxes ixBox iyBox izBox
  
  Ib=find(izBox==1);

  nbb=length(Ib);
  
  ia=[];
  ja=[];
  for i=1:nbb
	ib=Ib(i);
	halo=get_halo3(ib,nhh,0,0,nbhalo,boxnum,ixBox,iyBox,izBox,overflows,1); % horizontal halo+surface overflow
	nhalo=length(halo);
	ia=[ia;repmat(ib,[nhalo 1])];
	ja=[ja;halo];
  end
  
  S=sparse(ia,ja,1,nbb,nbb);
end

g=colgroup(S');

numGroups=length(unique(g));
for ir=1:numGroups
  tracerTiles{ir}=find(g==ir);
end

save tracer_tiles tracerTiles nhh numGroups overflows

