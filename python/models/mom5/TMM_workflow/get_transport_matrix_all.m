load('matrix_extraction_run_data')
maxNumTend=12;
matrix_path='./matrix_output/';

totNumRuns=length(tracer_run_data.groups);
Ir=[1:totNumRuns]';

!mkdir -p ./TMs

for im=1:maxNumTend
  Aexp=assemble_transport_matrix_DH(Ir,matrix_path,12,im,[],1,maxNumTend);
  Aimp=assemble_transport_matrix_DH(Ir,matrix_path,12,im,[],2,maxNumTend);
  matFile=['matrix_nocorrection_' sprintf('%02d',im)];
  save(matFile,'Aexp','Aimp','-v7.3')
  eval(['!mv ' matFile '.mat ./TMs/']);
  clear Aexp Aimp
end
