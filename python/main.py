from argparse import ArgumentParser, Namespace
from pathlib import Path

import subprocess
import os

from models import *

model_map = {
    "mom5" : mom5,
    "stub" : stub
}

def setup():
    parser = ArgumentParser(description='Generate transport matrices.')
    parser.add_argument('-s', '--source', metavar='/path/to/model/run', 
                        help='path to original model run outputs', required=True, type=Path)
    parser.add_argument('-i', '--source_inputs', metavar='/path/to/original/input',
                        help='path to original model run inputs', required=False, type=Path)
    parser.add_argument('-r', '--run_directory', metavar='/path/to/original/run/directory',
                        help='path to original model run directory', required=False, type=Path)
    parser.add_argument('-o', '--output', metavar='/path/to/matrix/output', 
                    help='path to output matrices', default=str(Path(__file__).parent.parent / "matrix_output"), type=Path)
    parser.add_argument('-m', '--model', metavar='"Model Type"', 
                    help='input model type: mom5, stub', default="mom5")
    return parser.parse_args()

def main(args: Namespace):  
    # check for output directory, fail if already exists
    # args.output.mkdir(parents=False, exist_ok=False)


    # establish a temp directory
    tempdir = (args.output / ".temp")
    tempdir.mkdir(parents=False, exist_ok=False)

    print("main")
    print(str(tempdir))

    # call model preprocess script
    try:
        model_map[args.model].preprocess(args, tempdir)
    except KeyError:
        teardown(args)
        raise NotImplementedError("No such model as {}!".format(args.model))
    except Exception as e:
        teardown(args)
        raise e

def teardown(args: Namespace):
    print("stubbing teardown")
    # os.system('rm -rf ' + str(args.output))


args = setup()
main(args)
teardown(args)