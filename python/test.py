from models.mom5 import generate_transport_matrices, matlab_postprocess, matlab_prep
import pathlib
import os
from scipy.io import loadmat

tempdir = pathlib.Path('/scratch/v45/tm8938/projects/easytmm/matrix_output_duplicate/.temp')
rundir = pathlib.Path('/scratch/v45/tm8938/projects/easytmm_srcs/1deg_jra55_ryf')

output_dir = tempdir / 'archive' / '1deg_jra55_ryf_red3DSK_C9'

matlab_dir = tempdir / 'scratch' /'matlab_data'

f = loadmat(str(matlab_dir / 'grid.mat'))
print(f.keys())
print(f['nx'][0][0])
print(f['ny'][0][0])
print(f['nz'][0][0])

f = loadmat(str(matlab_dir / 'tracer_tiles.mat'))
print(f.keys())
print(f['numGroups'][0][0])

# combine_tracer_input(tempdir/"matlab_data")


# matlab_output_dir = matlab_prep(tempdir / 'scratch', output_dir)
# matlab_postprocess(output_dir)
# generate_transport_matrices(tempdir, output_dir, rundir)
