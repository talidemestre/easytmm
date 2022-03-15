function []=prep_files(deltaT)
    make_grid_mom5(deltaT)
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
end