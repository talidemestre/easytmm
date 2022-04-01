from pathlib import Path
import matlab.engine
import os
import shutil

out_files = ['basis_functions.mat', 'boxes.mat', 'boxnum.mat', 'links.mat', 'matrix_extraction_run_data.mat', 'tracer_tiles.mat']


def matlab_prep(tempdir: Path):
    matlab_working_dir = Path(os.getcwd())
    matlab_output_dir = tempdir / "matlab_data"
    matlab_output_dir.mkdir(exist_ok=True)
    
    print(matlab.__file__)
    eng = matlab.engine.start_matlab()
    print('Matlab engine started.')
    eng.addpath("{}".format(os.getcwd() + '/python/models/mom5/matlab_scripts'),nargout=0)
    eng.addpath("{}".format(os.getcwd() + '/python/models/mom5/matlab_scripts/Matrix_extraction_code'),nargout=0)
    eng.addpath("{}".format(str(matlab_output_dir) ))

    clear_previous(matlab_working_dir, matlab_output_dir)
    prep_files(tempdir, eng)
    clear_current(matlab_working_dir, matlab_output_dir)
    makeIni(matlab_working_dir, matlab_output_dir, eng)

    return matlab_output_dir


def clear_previous(workdir: Path, outdir: Path):
    for out_file in out_files:
        (workdir / out_file).unlink(missing_ok=True)
        (outdir / out_file).unlink( missing_ok=True)

def prep_files(tempdir: Path, eng):
    # run prep_files script
    eng.prep_files(7200, str(tempdir), nargout=0)

def clear_current(workdir: Path, outdir: Path):
    # clean up matlab
    for out_file in out_files:
        shutil.move((workdir / out_file), (outdir / out_file))

    # os.system('find ' + str(outdir) + ' -name "*.mat" -exec ln -sf {} . \;') #TODO what is this?

def makeIni(workdir: Path, outdir: Path, eng):
    eng.MakeIni(os.getcwd() + '/python/models/mom5/matlab_scripts/matlab_tmm', str(outdir), '/g/data/e14/rmh561/access-om2/archive/1deg_jra55_ryf_red3DSK_C9/restart100/ocean/ocean_age.res.nc', nargout=0)
