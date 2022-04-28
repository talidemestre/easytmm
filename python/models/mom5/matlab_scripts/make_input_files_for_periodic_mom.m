% % Set toplevel path to GCMs configuration
% base_path='/scratch/v45/dkh157/TMM/Matrix_a38';
% % base_path='/data2/spk/TransportMatrixConfigs/MITgcm_2.8deg';

% addpath(genpath('/scratch/v45/dkh157/matlab'));
function []=make_input_files_for_periodic_mom(base_path, matlab_file_path, boundary_condition_file)

	periodicMatrix=1

	dt=7200; % time step to use

	rearrangeProfiles=0 % DON'T CHANGE!!
	bigMat=0
	writeFiles=1
	writeTMs=1
	useCoarseGrainedMatrix=0

	% Set path names, etc.
	% load(fullfile(base_path,'config_data'))

	explicitMatrixFileBase='matrix_nocorrection';
	implicitMatrixFileBase='matrix_nocorrection';


	explicitMatrixFileBase=fullfile(base_path,explicitMatrixFileBase);
	implicitMatrixFileBase=fullfile(base_path,implicitMatrixFileBase);

	% gcmDataPath=fullfile(base_path,'GCM');

	%
	gridFile=fullfile(matlab_file_path,'grid.mat');
	boxFile=fullfile(matlab_file_path,'boxes.mat');
	% profilesFile=fullfile(base_path,'profile_data');

	load(gridFile,'nx','ny','nz','x','y','z','deltaT','gridType')

	dtMultiple=dt/deltaT;
	if rem(dt,deltaT)
	error('ERROR: Incorrect time step specified! dt must be divisible by deltaT.')
	end
	disp(['dtMultiple is set to ' num2str(dtMultiple)])

	load(boxFile,'izBox','nb')

	Ib=find(izBox==1);
	Ii=find(~ismember([1:nb]',Ib));
	nbb=length(Ib);
	nbi=length(Ii);

	if useCoarseGrainedMatrix
	error('NOT FULLY IMPLEMENTED YET!')
	end

	numTracers=1;

	nd_in = ncread(boundary_condition_file,'temp');
	nd_in = reshape(nd_in, nx, ny, nz, 1);
	nd_in = repmat(nd_in, [1,1,1,12]);

	Nd_steady = gridToMatrix(nd_in,[],boxFile,gridFile);

	clear Nd_dist; 

	% Boundary conditions
	Cbc{1}=Nd_steady(Ib,:);

	% Initial condition
	Cini{1}=Nd_steady(Ii,1);

	if rearrangeProfiles
	error('ERROR: rearrangeProfiles must be set to 0!')
	end  

	if writeFiles
	calc_periodic_times_for_tmm('monthly-365-day year','periodic_times_365d.bin');
	calc_periodic_times_for_tmm('monthly-360-day year','periodic_times_360d.bin');  
	% Transport matrices
	if writeTMs
	%   Explicit transport matrix
		I=speye(nb,nb);
		
		% load each month from separate file
		disp('loading monthly mean explicit TMs')	      
		for im=1:12 
		fn=[explicitMatrixFileBase '_' sprintf('%02d',im) '.mat'];
		load(fn,'Aexp')
		if rearrangeProfiles
			Aexp=Aexp(Ir_pre,Ir_pre); % rearrange
		end
		% make discrete
		Aexp=dt*Aexp;
		Aexp=I+Aexp;
		[Ae1,Be,Ii]=split_transport_matrix(Aexp,Ib);
		writePetscBin(['Ae1_' sprintf('%02d',im-1)],Ae1,[],1)
		writePetscBin(['Be_' sprintf('%02d',im-1)],Be,[],1)		
		clear Aexp Ae1 Be

		end
	%   Implicit transport matrix
		% load each month from separate file
		disp('loading monthly mean implicit TMs')	      	  
		for im=1:12
		fn=[implicitMatrixFileBase '_' sprintf('%02d',im)];		
		load(fn,'Aimp')
		if dtMultiple~=1
			if bigMat % big matrix. do it a block at a time.		
			for is=1:nbb % change time step multiple
				Aimp(Ip_pre{is},Ip_pre{is})=Aimp(Ip_pre{is},Ip_pre{is})^dtMultiple;
			end
			else
			Aimp=Aimp^dtMultiple;		
			end
		end  
		if rearrangeProfiles
			Aimp=Aimp(Ir_pre,Ir_pre); % rearrange
		end
		[Ai1,Bi,Ii]=split_transport_matrix(Aimp,Ib);
		writePetscBin(['Ai1_' sprintf('%02d',im-1)],Ai1,[],1)
		writePetscBin(['Bi_' sprintf('%02d',im-1)],Bi,[],1)		  
		clear Aimp Ai1 Bi
		end
	end
	% Initial conditions  
	for itr=1:numTracers
		writePetscBin('Ndini.petsc',Cini{itr})
	end
	% Boundary conditions
	for itr=1:numTracers
		for im=1:12
		writePetscBin(['Ndbc_' sprintf('%02d',im-1)],Cbc{itr}(:,im))
		end    
	end
	
	% Grid data

	% Profile data
	if rearrangeProfiles
		if ~useCoarseGrainedMatrix
		gStartIndices=cellfun(@(x)x(1),Ip);
		gEndIndices=cellfun(@(x)x(end),Ip);
		else % useCoarseGrainedMatrix
		gStartIndices=cellfun(@(x)x(1),Ipcg);
		gEndIndices=cellfun(@(x)x(end),Ipcg);
		end  
		write_binary('gStartIndices.bin',[length(gStartIndices);gStartIndices],'int')
		write_binary('gEndIndices.bin',[length(gEndIndices);gEndIndices],'int')
	end
	end
