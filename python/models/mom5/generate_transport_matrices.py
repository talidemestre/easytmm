from pathlib import Path
from tqdm import tqdm 
from time import sleep

import subprocess
import os

def generate_transport_matrices(scratchdir: Path, output_dir: Path, rundir: Path):
    ntile = 38

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
    highest_output = "output050"   #TODO: not this
    highest_restart = "restart050" #TODO: not this

    parent_run_dir = (scratchdir / "run_dirs")
    parent_run_dir.mkdir(exist_ok=True)

    job_list = []

    print("setting up model runs:")
    for i in tqdm(range(1,ntile+1)):
        current_tile = "{}_{:02d}".format(name,i)
        current_output_tile = temp_run_output / current_tile
        current_output_tile.mkdir(exist_ok=True)

        # Get output and restart directories
        subprocess.call("cp -sr {} {}".format(str(output_dir / highest_output), str(current_output_tile )), shell=True)
        subprocess.call("cp -rL {} {}".format(str(output_dir / highest_restart), str(current_output_tile)), shell=True)

        # add tracer set to restart directories
        subprocess.call("cp {} {}".format(str(scratchdir / "matlab_data" / "tracer_set_{:02d}.nc".format(i)), str(current_output_tile / highest_restart / "ocean")), shell=True)

        # remove existing field_table
        subprocess.call("cp --remove-destination `readlink {}` {}".format( str(current_output_tile / highest_output/ "ocean" / "field_table"), str(current_output_tile / highest_output/ "ocean" / "field_table")), shell=True) #TODO: unduplicate arguments

        # next block, run directories TODO: better comments
        current_run_dir = (parent_run_dir / "model_run_{:02d}".format(i))
        
        subprocess.call("cp -sr {} {}".format(str(rundir), str(current_run_dir), i), shell=True)

        # write lab and run directory to config file
        config_file = str(current_run_dir / "config.yaml")
        subprocess.call("cp --remove-destination `readlink {}` {}".format(config_file, config_file), shell=True) #TODO: unduplicate arguments
        f = open(config_file, "a")
        job_name = "etmm_tile_{:02d}".format(i)
        f.write(config_yaml_input.format(scratchdir.parent, current_tile, job_name))
        f.close()
        job_list.append(job_name)
        
        # write tracers to field_table file
        field_table_file = str(current_run_dir / "ocean" / "field_table")
        subprocess.call("cp --remove-destination `readlink {}` {}".format(field_table_file, field_table_file), shell=True) #TODO: unduplicate arguments
        f = open(field_table_file, "a")
        f.write(field_table_input.format(i))
        f.close()

        # overwrite max_tracers in ocean.nml
        ocean_input_nml = str(current_run_dir / "ocean" / "input.nml")
        subprocess.call("cp --remove-destination `readlink {}` {}".format(ocean_input_nml, ocean_input_nml), shell=True) #TODO: unduplicate arguments
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



        subprocess.call("cp {} {}".format(str(scratchdir / "diag_table"), str(current_run_dir / "ocean" / "diag_table"), i), shell=True)

        subprocess.call('payu sweep; payu run'.format(current_run_dir), cwd=str(current_run_dir), shell=True, stdout=subprocess.DEVNULL)
      
        # TODO: make period only 1 year always
        # accessom2nml_file = str(current_run_dir / "model_run_{:02d}".format(i) / "accessom2.nml")
        # subprocess.call("cp --remove-destination `readlink {}` {}".format(accessom2nml_file, accessom2nml_file), shell=True) #TODO: unduplicate arguments

        # f = open(accessom2nml_file, "a")
        # for line in file:
        #     line = line.strip()
        #     changes = line.replace("hardships", "situations")
        #     replacement = replacement + changes + "\n"
        # f.close()

        #TODO: block on qsub jobs https://stackoverflow.com/questions/11525214/wait-for-set-of-qsub-jobs-to-complete 

    #Block until jobs are done
    print("Waiting for jobs...")
    for job_name in tqdm(job_list):
        while True: 
            job_status = os.popen('qstat | grep {}'.format(job_name)).read()[:-1]
            if job_status != "":
                sleep(2)
            else:
                break
