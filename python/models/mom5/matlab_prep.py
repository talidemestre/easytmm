from pathlib import Path
from oct2py import octave

import os
import shutil

out_files = ['basis_functions', 'boxes', 'boxnum', 'links', 'matrix_extraction_run_data', 'tracer_tiles']

def matlab_prep(tempdir: Path):
    matlab_working_dir = Path(os.getcwd())
    matlab_output_dir = tempdir / "matlab_data"
    matlab_output_dir.mkdir(exist_ok=True)
    octave.eval('pkg load netcdf')

    clear_previous(matlab_working_dir, matlab_output_dir)
    prep_files(tempdir)
    clear_current(matlab_working_dir, matlab_output_dir)
    makeIni(matlab_working_dir, matlab_output_dir)

def clear_previous(workdir: Path, outdir: Path):
    for out_file in out_files:
        (workdir / out_file).unlink(missing_ok=True)
        (outdir / out_file).unlink( missing_ok=True)

def prep_files(tempdir: Path):
    # run prep_files script
    octave.addpath(os.getcwd() + '/python/models/mom5/matlab_scripts')
    octave.addpath(os.getcwd() + '/python/models/mom5/matlab_scripts/Matrix_extraction_code')
    octave.feval('prep_files', '7200', str(tempdir)) #TODO pass in deltaT

def clear_current(workdir: Path, outdir: Path):
    # clean up matlab
    for out_file in out_files:
        shutil.move((workdir / out_file), (outdir / out_file))

    os.system('find ' + str(outdir) + ' -name "*.mat" -exec ln -sf {} . \;') #TODO what is this?

def makeIni(workdir: Path, outdir: Path):
    octave.addpath(os.getcwd() + '/python/models/mom5/matlab_scripts')
    octave.addpath(os.getcwd() + '/python/models/mom5/matlab_scripts/Matrix_extraction_code')
    octave.addpath(str(outdir))
    octave.feval('MakeIni', os.getcwd() + '/python/models/mom5/matlab_scripts/matlab_tmm')