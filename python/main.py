from argparse import ArgumentParser, Namespace
import pathlib
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
                        help='path to original model run outputs', required=True, type=pathlib.Path)
    parser.add_argument('-i', '--source_inputs', metavar='/path/to/original/input',
                        help='path to original model run inputs', required=False, type=pathlib.Path)
    parser.add_argument('-o', '--output', metavar='/path/to/matrix/output', 
                    help='path to output matrices', default="./matrix_output", type=pathlib.Path)
    parser.add_argument('-m', '--model', metavar='"Model Type"', 
                    help='input model type: mom5, stub', default="mom5")
    parser.add_argument('-n', '--name', metavar='"Model Type"', 
                    help='input model name')
    return parser.parse_args()

def main(args: Namespace):  
    # check for output directory, fail if already exists
    args.output.mkdir(parents=False, exist_ok=False)


    # create a symlink of all files in source directory in temp directory
    tempdir = (args.output / ".temp")
    tempdir.mkdir(parents=False, exist_ok=False)

    print("main")
    print(str(tempdir))
    
    subprocess.check_call('ln  -s ' + str(args.source) + '/* ' + str(tempdir), shell=True) # TODO, find a better war to do this

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
    # subprocess.run(['cp', 'matrix_output', 'matrix_output_duplicate', '-r']) #TODO make this take temp directory arg
    os.system('rm -rf ' + str(args.output))


args = setup()
main(args)
teardown(args)