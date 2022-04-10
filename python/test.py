from models.mom5 import generate_transport_matrices
import pathlib
import os

tempdir = pathlib.Path(os.getcwd() + '/matrix_output_duplicate/.temp')


output_dir = tempdir / 'archive' / '1deg_jra55_ryf_red3DSK_C9'


# combine_tracer_input(tempdir/"matlab_data")

generate_transport_matrices(tempdir, output_dir, '1deg_jra55_ryf_red3DSK_C9')