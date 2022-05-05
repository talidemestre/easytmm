from argparse import ArgumentParser, Namespace
from pathlib import Path

import subprocess
import os

from models import *

model_map = {
    "mom5" : mom5,
    "stub" : stub
}


def setup_parser():
    '''Returns an argument parser with our arguments included.'''
    parser = ArgumentParser(description='Generate transport matrices.')
    parser.add_argument('-s', '--source', metavar='/path/to/model/run', 
                        help='path to original model run outputs', required=True, type=Path)
    parser.add_argument('-i', '--source_inputs', metavar='/path/to/original/input',
                        help='path to original model run inputs', required=False, type=Path)
    parser.add_argument('-r', '--run_directory', metavar='/path/to/original/run/directory',
                        help='path to original model run directory', required=False, type=Path)
    parser.add_argument('-c', '--initial_conditions', metavar='/path/to/initial/tracer/conditions',
                        help='path to initial conditions', required=True, type=Path)
    parser.add_argument('-t', '--timestep', metavar='integer timestep (s)',
                        help='base timestep of model run', required=True, type=int)
    parser.add_argument('-o', '--output', metavar='/path/to/matrix/output', 
                        help='path to output matrices', default=str(Path(__file__).parent.parent / "matrix_output"), type=Path)
    parser.add_argument('-m', '--model', metavar='"Model Type"', 
                        help='input model type: mom5, stub', default="mom5")
    return parser.parse_args()

def main(args: Namespace):  
    '''Define and set up directories for any implementation.'''
    # Create the output directory, fail if already exists.
    args.output.mkdir(parents=False, exist_ok=False)


    # Create a temporary directory inside the output directory.
    tempdir = (args.output / ".temp").resolve()
    tempdir.mkdir(parents=False, exist_ok=False)

    # Call the implementation for preprocessing the model.
    try:
        model_map[args.model].preprocess(args, tempdir)
    except KeyError:
        teardown(args, tempdir)
        raise NotImplementedError("No such model as {}!".format(args.model))
    except Exception as e:
        teardown(args, tempdir)
        raise e

    return tempdir

def teardown(args: Namespace, tempdir: Path):
    '''Deletes the temporary directory after the model output is finished.'''
    print("stubbing teardown")
    os.system('rm -rf ' + str(tempdir))


args = setup_parser()
tempdir = main(args)
teardown(args, tempdir)