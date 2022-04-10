from pathlib import Path
from tokenize import String
from tqdm import tqdm 

import subprocess
import os

def generate_transport_matrices(tempdir: Path, output_dir: Path, name: String):
    ntile = 38

    field_table_input = '''
"tracer_packages","ocean_mod","transport_matrix"
names = '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '40', '41', '42', '43', '44', '45', '46', '47', '48', '49', '50'
horizontal-advection-scheme = mdfl_sweby
vertical-advection-scheme = mdfl_sweby
restart_file = tracer_set_{:02d}.nc
const_init_tracer = .false.
const_init_value = 1.0
    '''

    temp_run_output = tempdir / "archive_tracer"
    temp_run_output.mkdir(exist_ok=True)

    highest_output = os.popen('ls ' + str(output_dir) + " | grep '^output[0-9]\+$' |  sort -n | tail -n1").read()[:-1]
    highest_restart = os.popen('ls ' + str(output_dir) + " | grep '^restart[0-9]\+$' |  sort -n | tail -n1").read()[:-1]


    print("setting up model runs:")
    for i in tqdm(range(1,ntile+1)):
        current_tile = "{}_{:02d}".format(name,i)

        # ceate directory for tile
        subprocess.call("rm -rf {}/{}".format(temp_run_output, current_tile), shell=True)
        subprocess.call("mkdir {}/{}".format(temp_run_output, current_tile), shell=True)
        subprocess.call("mkdir {}/{}".format(temp_run_output, current_tile), shell=True)

        # Get output and restart directories
        subprocess.call("cp -sr {} {}/".format(str(output_dir / highest_output), str(temp_run_output / current_tile )), shell=True)
        subprocess.call("cp -sr {} {}/".format(str(output_dir / highest_restart), str(temp_run_output / current_tile)), shell=True)

        # add tracer set to restart directories
        subprocess.call("cp {} {}".format(str(tempdir / "matlab_data" / "tracer_set_{:02d}.nc".format(i)), str(temp_run_output / current_tile / highest_restart / "ocean")), shell=True)

        # remove existing field_table
        subprocess.call("rm {}".format( str(temp_run_output / current_tile / highest_output/ "ocean" / "field_table")), shell=True)

        # write tracers to field_table file
        f = open(str(temp_run_output / current_tile / highest_output/ "ocean" / "field_table"), "w")
        f.write(field_table_input.format(i))
        f.close()
