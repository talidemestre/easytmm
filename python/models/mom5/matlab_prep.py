from pathlib import Path
from oct2py import octave

import os
import shutil

def matlab_prep(tempdir: Path):

    # clean up previous runs
    matlab_working_dir = Path(os.getcwd() + '/python/models/mom5/matlab_scripts')

    matlab_output_dir = matlab_working_dir / "Data"
    matlab_output_dir.mkdir(exist_ok=True)

    out_files = ['basis_functions.mat', 'boxes.mat', 'boxnum.mat', 'links.mat', 'matrix_extraction_run_data.mat', 'tracer_tiles.mat']
    for out_file in out_files:
        matlab_working_dir.unlink(out_file, missing_ok=True)
        matlab_output_dir.unlink(out_file, missing_ok=True)


    # run prep_files script
    octave.addpath(os.getcwd() + '/python/models/mom5/matlab_scripts')
    octave.addpath(os.getcwd() + '/python/models/mom5/matlab_scripts/Matrix_extraction_code') 
    octave.run('prep_files(7200)') #TODO pass in deltaT

    # clean up matlab
    for out_file in out_files:
        shutil.move((matlab_working_dir / out_file), (matlab_output_dir / out_file))

    os.system('find ' + str(matlab_output_dir) + ' -name "*.mat" -exec ln -sf {} . \;') #TODO what is this?
