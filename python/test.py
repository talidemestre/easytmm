from models.mom5 import generate_transport_matrices, matlab_postprocess, matlab_prep
import pathlib
import os

tempdir = pathlib.Path('/scratch/v45/tm8938/projects/easytmm/matrix_output_duplicate/.temp')
rundir = pathlib.Path('/scratch/v45/tm8938/projects/easytmm_srcs/1deg_jra55_ryf')

output_dir = tempdir / 'archive' / '1deg_jra55_ryf_red3DSK_C9'


# combine_tracer_input(tempdir/"matlab_data")


# matlab_output_dir = matlab_prep(tempdir / 'scratch')
matlab_postprocess(output_dir)
# generate_transport_matrices(tempdir, output_dir, rundir)
