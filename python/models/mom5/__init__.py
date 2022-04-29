from argparse import Namespace
from pathlib import Path
import subprocess
import os

from scipy.io import loadmat

from .check_levels import check_levels
from .make_vert import make_vert
from .matlab_prep import matlab_prep
from .process_ocean_nc_files import process_ocean_nc_files
from .combine_tracer_input import combine_tracer_input
from .make_diag_field import make_diag_field
from .increment_models import increment_models
from .matlab_postprocess import matlab_postprocess


def preprocess(args: Namespace, tempdir: Path): 
    '''Takes input arguments, and outputs path to transport matrices ready to be run via the TMM driver.'''
    try:
        assert(args.source_inputs != None)
    except:
        raise ValueError("mom5 implementation requires a '--source_input' directory is specified")

    try:
        assert(args.run_directory != None)
    except:
        raise ValueError("mom5 implementation requires a '--run_directory' is specified for the climate model run")


    # make a copy of a successful run as a base reference
    output_dir = tempdir / 'archive' / args.source.stem
    output_dir.mkdir(parents=True)
    subprocess.check_call('ln  -s ' + str(args.source) + '/* ' + str(output_dir), shell=True) # TODO, find a better war to do this

    # get latest run and softlink files to a scratch directory
    scratch_dir = tempdir / 'scratch'
    scratch_dir.mkdir()
    highest_output = os.popen('ls ' + str(output_dir) + " | grep '^output[0-9]\+$' |  sort -n | tail -n1").read()[:-1] #TODO better way for this 
    output_dir_ocean = args.source / highest_output / 'ocean'
    subprocess.check_call('ln -s ' + str(output_dir_ocean) + '/* ' +  str(scratch_dir), shell=True) # TODO, find a better war to do this

    # symlink required files from source input directory
    (scratch_dir / 'ocean_hgrid.nc').symlink_to(args.source_inputs / 'ocean_hgrid.nc')
    (scratch_dir / 'topog.nc').symlink_to(args.source_inputs / 'topog.nc')

    # transform some NetCDF files for additional processing
    process_ocean_nc_files(scratch_dir) #extract additional nc files
    check_levels(scratch_dir) # create temp_levels.nc
    make_vert(scratch_dir) # create ocean_vert.nc

    # create .mat files used in transport pointer generation
    matlab_output_dir = matlab_prep(scratch_dir, output_dir)

    # extract model dimensions for processing    
    grid = loadmat(str(matlab_output_dir / 'grid.mat'))
    nx = grid['nx'][0][0]
    ny = grid['ny'][0][0]
    nz = grid['nz'][0][0]

    tracer_tiles = loadmat(str(matlab_output_dir / 'tracer_tiles.mat'))
    ntiles = tracer_tiles['numGroups'][0][0]

    combine_tracer_input(matlab_output_dir, nx, ny, nz, ntiles) # combine preprocessing inputs
    make_diag_field(scratch_dir, nz) # add diagnostics to tracer filetempdir    
    
    # generate transport matrices and output in petsc format
    increment_models(scratch_dir, output_dir, args.run_directory, ntiles)
    matlab_postprocess(output_dir, matlab_output_dir, args.out, ntiles)

    return args.output


