from argparse import Namespace
from pathlib import Path

from .check_levels import check_levels
from .make_vert import make_vert
from .matlab_prep import matlab_prep

def preprocess(args: Namespace, tempdir: Path): 
    try:
        assert(args.source_inputs != None)
        
    except:
        raise ValueError("mom5 implementation requires a '--source_input' directory is specified")

    (tempdir / 'ocean_hgrid.nc').symlink_to(args.source_inputs / 'ocean_hgrid.nc')
    (tempdir / 'topog.nc').symlink_to(args.source_inputs / 'topog.nc')
    check_levels(tempdir)
    make_vert(tempdir)
    matlab_prep(tempdir)
