from models.mom5 import increment_models, matlab_postprocess, matlab_prep
import pathlib
import os
from scipy.io import loadmat

tempdir = pathlib.Path('/scratch/v45/tm8938/projects/easytmm/alternative_matrix_output_2/.temp')
rundir = pathlib.Path('/scratch/v45/tm8938/projects/easytmm_srcs/1deg_jra55_ryf')

scratchdir = tempdir / 'scratch'
output_dir = tempdir / 'archive' / '1deg_jra55_ryf_red3DSK_C9'

matlab_dir = tempdir / 'scratch' /'matlab_data'

f = loadmat(str(matlab_dir / 'grid.mat'))
print(f.keys())
print(f['deltaT'][0][0])

print(f['nx'][0][0])
print(f['ny'][0][0])
print(f['nz'][0][0])

f = loadmat(str(matlab_dir / 'tracer_tiles.mat'))
print(f.keys())
ntile = f['numGroups'][0][0]
print(type(int(ntile)))
# combine_tracer_input(tempdir/"matlab_data")

# increment_models(scratchdir, output_dir, rundir, ntile)
# matlab_output_dir = matlab_prep(tempdir / 'scratch', output_dir)
matlab_postprocess(output_dir, matlab_dir, tempdir.parent, ntile, 5400)
# generate_transport_matrices(tempdir, output_dir, rundir)
