load('matrix_extraction_run_data')
maxNumTend=1;
matrix_path='./matrix_output_mean/';

totNumRuns=length(tracer_run_data.groups);
Ir=[1:totNumRuns]';
Itend=[1:maxNumTend]';

Aexpms=assemble_transport_matrix_DH(Ir,matrix_path,11,Itend,[],1,maxNumTend);
Aimpms=assemble_transport_matrix_DH(Ir,matrix_path,11,Itend,[],2,maxNumTend);

save matrix_nocorrection_annualmean -v7.3 Aexpms Aimpms

!mkdir -p ./TMs
!mv matrix_nocorrection_annualmean.mat ./TMs/
