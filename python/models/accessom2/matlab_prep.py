from pathlib import Path
import matlab.engine
import os
import shutil

out_files = ['basis_functions.mat', 'boxes.mat', 'boxnum.mat', 'links.mat', 'matrix_extraction_run_data.mat', 'tracer_tiles.mat', 'grid.mat']


def matlab_prep(tempdir: Path, model_base_dir: Path, deltaT: int ):
    '''Runs Matlab scripts to create all *.mat files needed before generation of transport matrices.'''

    # define directories for working with Matlab
    matlab_working_dir = Path(os.getcwd())
    matlab_output_dir = tempdir / "matlab_data"
    matlab_output_dir.mkdir(exist_ok=True)
    
    eng = matlab.engine.start_matlab()
    print('Matlab engine started.')

    # add paths with Matlab code we will execute
    eng.addpath("{}".format(str(Path(__file__).parent / "matlab_scripts")),nargout=0)
    eng.addpath("{}".format(str(Path(__file__).parent / "matlab_scripts" / "matlab_tmm" / "gcmfaces")),nargout=0)
    eng.addpath("{}".format(str(Path(__file__).parent / "matlab_scripts" / "matlab_tmm" / "Misc")),nargout=0)
    eng.addpath("{}".format(str(Path(__file__).parent / "matlab_scripts" / "matlab_tmm" / "TMM")),nargout=0)
    eng.addpath("{}".format(str(Path(__file__).parent / "matlab_scripts" / "Matrix_extraction_code")),nargout=0)
    eng.addpath("{}".format(str(matlab_output_dir) ))

    clear_previous(matlab_working_dir, matlab_output_dir)
    prep_files(tempdir, deltaT, eng)
    clear_current(matlab_working_dir, matlab_output_dir)
    makeIni(matlab_working_dir, matlab_output_dir, model_base_dir, eng)

    return matlab_output_dir


def clear_previous(workdir: Path, outdir: Path):
    '''Deletes files previously completed by running these scripts, possibly in a failed run.'''
    for out_file in out_files:
        (workdir / out_file).unlink(missing_ok=True)
        (outdir / out_file).unlink( missing_ok=True)

def prep_files(tempdir: Path, deltaT: int, eng):
    '''Run Matlab prep_files function'''
    eng.prep_files(deltaT, str(tempdir), nargout=0)  #TODO: read in timestep

def clear_current(workdir: Path, outdir: Path):
    '''Move all files created by Matlab in working directory to the matlab output directory.'''
    for out_file in out_files:
        shutil.move((workdir / out_file), (outdir / out_file))

def makeIni(workdir: Path, matlab_outdir: Path, model_base_dir : Path, eng):
    '''Run Matlab MakeIni function'''
    highest_restart = os.popen('ls ' + str(model_base_dir) + " | grep '^restart[0-9]\+$' |  sort -n | tail -n1").read()[:-1] 
    eng.MakeIni(str(Path(__file__).parent /"matlab_scripts"/'matlab_tmm'), str(matlab_outdir), str(model_base_dir / highest_restart / "ocean" /"ocean_age.res.nc"), nargout=0)
