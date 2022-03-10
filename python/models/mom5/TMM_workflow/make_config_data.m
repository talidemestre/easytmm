gcmConfigName='UVic';
matrixPath='Matrix1';
pcMatrixPath='[]';

explicitMatrixFileBase=fullfile(matrixPath,'TMs','matrix_nocorrection');
implicitMatrixFileBase=fullfile(matrixPath,'TMs','matrix_nocorrection');

explicitAnnualMeanMatrixFile=fullfile(matrixPath,'TMs','matrix_nocorrection_annualmean');
implicitAnnualMeanMatrixFile=fullfile(matrixPath,'TMs','matrix_nocorrection_annualmean');

if ~isempty(pcMatrixPath)
  preconditionerMatrixFile=fullfile(pcMatrixPath,'TMs','matrix_nocorrection');
else
  preconditionerMatrixFile=[];
end

fixEmP=0;
empFixFile=[];
useAreaWeighting=[];

rescaleForcing=0;

if rescaleForcing~=0
  rescaleForcingFile=fullfile(matrixPath,'TMs','Rfs');
else
  rescaleForcingFile=[];
end

save config_data gcmConfigName matrixPath pcMatrixPath ...
	 explicitMatrixFileBase implicitMatrixFileBase ...
	 explicitAnnualMeanMatrixFile implicitAnnualMeanMatrixFile ...
	 preconditionerMatrixFile ...
	 fixEmP empFixFile useAreaWeighting rescaleForcing rescaleForcingFile
