from argparse import ArgumentParser, Namespace
import pathlib
import os
from models import *

model_map = {
    "mom5" : mom5,
    "stub" : stub
}

def setup():
    parser = ArgumentParser(description='Generate transport matrices.')
    parser.add_argument('-s', '--source', metavar='/path/to/model/run', 
                        help='path to original model run outputs', required=True, type=pathlib.Path)
    parser.add_argument('-i', '--source_inputs', metavar='/path/to/original/input',
                        help='parth to original model run inputs', required=False, type=pathlib.Path)
    parser.add_argument('-o', '--output', metavar='/path/to/matrix/output', 
                    help='path to output matrices', default="./matrix_output", type=pathlib.Path)
    parser.add_argument('-m', '--model', metavar='"Model Type"', 
                    help='input model type', default="mom5")
    return parser.parse_args()

def main(args: Namespace):  
    # check for output directory, fail if already exists
    args.output.mkdir(parents=False, exist_ok=False)

    # create a symlink of all files in source directory in temp directory
    tempdir = (args.output / ".temp")
    tempdir.mkdir(parents=False, exist_ok=False)
    os.system('ln -s ' + str(args.source) + '/* ' +str(tempdir))

    # call model preprocess script
    try:
        model_map[args.model].preprocess(args, tempdir)
    except KeyError:
        raise NotImplementedError("No such model as {}!".format(args.model))

def teardown(args: Namespace):
    os.system('rm -rf ' + str(args.output))


args = setup()
main(args)
teardown(args)