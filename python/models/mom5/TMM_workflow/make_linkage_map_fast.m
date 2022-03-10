% Script to generate linkage map
load boxnum boxnum nbhalo
% base_path=fileparts(fileparts(pwd));
gridFile='grid';
load(gridFile,'nz','gridType')

if strcmp(gridType,'llc_v4')
  load(gridFile,'nFaces')
  load boxes ixBoxFace iyBoxFace izBoxFace nbFace
  
  links=cell(nFaces,1);

  for iF=1:nFaces
    boxf=boxnum{iF}; % extract this here to speedup code
	tmp=repmat(NaN,[nbFace(iF) 6]); % W E S N D U  
	for ib=1:nbFace(iF)
	  ii=ixBoxFace{iF}(ib)+nbhalo;
	  jj=iyBoxFace{iF}(ib)+nbhalo;
	  kk=izBoxFace{iF}(ib);
	
	  tmp(ib,1)=boxf(ii-1,jj,kk); % W
	  tmp(ib,2)=boxf(ii+1,jj,kk); % E
	  tmp(ib,3)=boxf(ii,jj-1,kk); % S
	  tmp(ib,4)=boxf(ii,jj+1,kk); % N
	  if kk<nz
		tmp(ib,5)=boxf(ii,jj,kk+1); % D
	  end
	  if kk>1
		tmp(ib,6)=boxf(ii,jj,kk-1); % U
	  end
	end
	links{iF}=tmp;
  end
else
  load boxes ixBox iyBox izBox nb
  links=repmat(NaN,[nb 6]); % W E S N D U
  for ib=1:nb
	ii=ixBox(ib)+nbhalo;
	jj=iyBox(ib)+nbhalo;
	kk=izBox(ib);
  
	links(ib,1)=boxnum(ii-1,jj,kk); % W
	links(ib,2)=boxnum(ii+1,jj,kk); % E
	links(ib,3)=boxnum(ii,jj-1,kk); % S
	links(ib,4)=boxnum(ii,jj+1,kk); % N
	if kk<nz
	  links(ib,5)=boxnum(ii,jj,kk+1); % D
	end
	if kk>1
	  links(ib,6)=boxnum(ii,jj,kk-1); % U
	end
  end
end
 
save links links

