from argparse import Namespace
from pathlib import Path

from .check_levels import check_levels
from .make_vert import make_vert
from .matlab_prep import matlab_prep
from .process_ocean_nc_files import process_ocean_nc_files
from .combine_tracer_input import combine_tracer_input
from .make_diag_field import make_diag_field

def preprocess(args: Namespace, tempdir: Path): 
    try:
        assert(args.source_inputs != None)
        
    except:
        raise ValueError("mom5 implementation requires a '--source_input' directory is specified")

    (tempdir / 'ocean_hgrid.nc').symlink_to(args.source_inputs / 'ocean_hgrid.nc')
    (tempdir / 'topog.nc').symlink_to(args.source_inputs / 'topog.nc')

    process_ocean_nc_files(tempdir) #extract additional nc files
    check_levels(tempdir) # create temp_levels.nc
    make_vert(tempdir) # create ocean_vert.nc
    matlab_output_dir = matlab_prep(tempdir) # matlab creates preprocessing files
    combine_tracer_input(matlab_output_dir) # combine preprocessing inputs
    make_diag_field(tempdir) # add diagnostics to tracer file
