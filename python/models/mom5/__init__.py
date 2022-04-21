from argparse import Namespace
from pathlib import Path
import subprocess
import os

from .check_levels import check_levels
from .make_vert import make_vert
from .matlab_prep import matlab_prep
from .process_ocean_nc_files import process_ocean_nc_files
from .combine_tracer_input import combine_tracer_input
from .make_diag_field import make_diag_field
from .generate_transport_matrices import generate_transport_matrices
from .matlab_postprocess import matlab_postprocess

def preprocess(args: Namespace, tempdir: Path): 
    try:
        assert(args.source_inputs != None)
    except:
        raise ValueError("mom5 implementation requires a '--source_input' directory is specified")

    try:
        assert(args.name != None)
    except:
        raise ValueError("mom5 implementation requires a '--name' is specified for the climate model run")


    try:
        assert(args.run_directory != None)
    except:
        raise ValueError("mom5 implementation requires a '--run_directory' is specified for the climate model run")


    # get latest run and softlink files to .temp
    output_dir = args.source
    highest_output = os.popen('ls ' + str(output_dir) + " | grep '^output[0-9]\+$' |  sort -n | tail -n1").read()[:-1] #TODO better way for this 
    output_dir_ocean = output_dir / highest_output / 'ocean'
    subprocess.check_call('ln -s ' + str(output_dir_ocean) + '/* ' +  str(tempdir), shell=True) # TODO, find a better war to do this

    (tempdir / 'ocean_hgrid.nc').symlink_to(args.source_inputs / 'ocean_hgrid.nc')
    (tempdir / 'topog.nc').symlink_to(args.source_inputs / 'topog.nc')

    process_ocean_nc_files(tempdir) #extract additional nc files
    check_levels(tempdir) # create temp_levels.nc
    make_vert(tempdir) # create ocean_vert.nc
    matlab_output_dir = matlab_prep(tempdir) # matlab creates preprocessing files
    combine_tracer_input(matlab_output_dir) # combine preprocessing inputs
    make_diag_field(tempdir) # add diagnostics to tracer filetempdir    
    
    base_model_out = generate_transport_matrices(tempdir, output_dir)
    matlab_postprocess(base_model_out)
