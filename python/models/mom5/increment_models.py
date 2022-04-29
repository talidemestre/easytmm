from pathlib import Path
from tqdm import tqdm 
from time import sleep

import subprocess
import os
import shutil

def increment_models(scratchdir: Path, output_dir: Path, rundir: Path, ntiles: int):
    '''Set up model runs and run for one year to generate next step in transport matrices.'''
    field_table_input = '''
"tracer_packages","ocean_mod","transport_matrix"
names = '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '40', '41', '42', '43', '44', '45', '46', '47', '48', '49', '50'
horizontal-advection-scheme = mdfl_sweby
vertical-advection-scheme = mdfl_sweby
restart_file = tracer_set_{:02d}.nc
const_init_tracer = .false.
const_init_value = 1.0
/
    '''

    config_yaml_input = '''
laboratory: {}
experiment: {}
jobname: {}
runlog: False
    '''

    name = output_dir.stem

    temp_run_output = output_dir.parent
    print (temp_run_output)
    highest_output = os.popen('ls ' + str(output_dir) + " | grep '^output[0-9]\+$' |  sort -n | tail -n1").read()[:-1]
    highest_restart = os.popen('ls ' + str(output_dir) + " | grep '^restart[0-9]\+$' |  sort -n | tail -n1").read()[:-1]

    parent_run_dir = (scratchdir / "run_dirs")
    parent_run_dir.mkdir(exist_ok=True)

    job_list = []

    print("setting up model runs:")
    for i in tqdm(range(1,ntiles+1)):
        current_tile = "{}_{:02d}".format(name,i)
        current_output_tile = temp_run_output / current_tile
        current_output_tile.mkdir(exist_ok=True)

        # Get output and restart directories
        shutil.copytree((output_dir / highest_output), (current_output_tile / highest_output))
        shutil.copytree((output_dir / highest_restart), (current_output_tile / highest_restart), symlinks=True)

        # add tracer set to restart directories
        tracer = "tracer_set_{:02d}.nc".format(i)
        shutil.copyfile((scratchdir / "matlab_data" / tracer), (current_output_tile / highest_restart / "ocean" / tracer))
        
        # set up run directories
        current_run_dir = (parent_run_dir / "model_run_{:02d}".format(i))
        
        shutil.copytree(rundir, current_run_dir)

        # write lab and run directory to config file
        config_file = str(current_run_dir / "config.yaml")
        f = open(config_file, "a")
        job_name = "etmm_tile_{:02d}".format(i)
        f.write(config_yaml_input.format(scratchdir.parent, current_tile, job_name))
        f.close()
        job_list.append(job_name)
        
        # write tracers to field_table file
        field_table_file = str(current_run_dir / "ocean" / "field_table")
        f = open(field_table_file, "a")
        f.write(field_table_input.format(i))
        f.close()

        # overwrite max_tracers in ocean.nml
        ocean_input_nml = str(current_run_dir / "ocean" / "input.nml")
        temp_file = ''
        f = open(ocean_input_nml, 'r')
        for line in f.readlines():
            if "max_tracers" in line:
                temp_file += '\tmax_tracers = 100\n'
            else:
                temp_file += line
        f.close()
        f = open(ocean_input_nml, 'w')
        f.write(temp_file)
        f.close()

        subprocess.check_call("rm {}".format(str(current_run_dir / "ocean" / "diag_table")), shell=True)
        (current_run_dir / "ocean" / "diag_table").symlink_to(scratchdir / "diag_table")

        subprocess.check_call('payu sweep; payu run'.format(current_run_dir), cwd=str(current_run_dir), shell=True, stdout=subprocess.DEVNULL)
      
        # TODO: make period only 1 year always
        # accessom2nml_file = str(current_run_dir / "model_run_{:02d}".format(i) / "accessom2.nml")
        # subprocess.call("cp --remove-destination `readlink {0}` {0}".format(accessom2nml_file), shell=True)

        # f = open(accessom2nml_file, "a")
        # for line in file:
        #     line = line.strip()
        #     changes = line.replace("hardships", "situations")
        #     replacement = replacement + changes + "\n"
        # f.close()

    #Block until jobs are done
    print("Waiting for jobs...")
    for job_name in tqdm(job_list):
        while True: 
            job_status = os.popen('qstat | grep {}'.format(job_name)).read()[:-1]
            if job_status != "":
                sleep(2)
            else:
                break
