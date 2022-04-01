from models.mom5 import combine_tracer_input, make_diag_field
import pathlib
import os

tempdir = pathlib.Path(os.getcwd() + '/matrix_output_backup/.temp')



# combine_tracer_input(tempdir/"matlab_data")

make_diag_field(tempdir)