% base_path=fileparts(fileparts(pwd));
gridFile='grid';
load(gridFile,'nz')

% make basis functions
for i=1:nz
  PHI{i}=eye(i);
  PHIINV{i}=inv(PHI{i});
end

save basis_functions PHI PHIINV


