% !rm -f basis_functions.mat boxes.mat boxnum.mat links.mat matrix_extraction_run_data.mat tracer_tiles.mat
addpath('/scratch/v45/dkh157/TMM_workflow/MatrixExtractionCode');
make_grid_mom5
clear
make_box_data
clear
make_linkage_map_fast
clear
make_basis_functions
clear
make_tracer_tiles_horiz_using_graph_partitioning_with_overflows
clear
make_matrix_extraction_run_data
clear
make_profile_data
clear

% !mkdir -p Data
% !mv basis_functions.mat boxes.mat boxnum.mat links.mat matrix_extraction_run_data.mat tracer_tiles.mat profile_data.mat Data
% !find ../Data -name "*.mat" -exec ln -sf {} . \;

