# easytmm
## Setup
The recommended environment for using this program is a node running on the _National Computing Infrastructure_.
### 1. Open the repository
```
git clone https://github.com/talidemestre/easytmm.git
cd easytmm
```
### 2. Create a Virtual Environment for Python
To create a virtual environment (or `venv`) for python, you will need to run the command.
```
$ python3 -m venv /path/to/new/virtual/environment
```
### 3. Install Matlab Engine API for Python
[MathWorks has official instruction on how to install their API for Python.](https://au.mathworks.com/help/matlab/matlab_external/get-started-with-matlab-engine-for-python.html) Due to permissions issues with Gadi, I was unable to isntall using this method.

Instead, I had to copy Matlab to a local directory, and then install the engine from that directroy.
```
$ cp /apps/matlab/R2021b matlab_install
$ cd matlab_install/R2021b/extern/engines/python/setup.py
$ python setup.py install
```
### 4. Install Other Requirements
```
$ pip install -r requirements.txt
``` 

## Running the Program
Running `easytmm` requires various user arguments, and which of these are required will differ between the model being run for. Currently, only _ACCESS-OM2_ is supported. The instructions for that model are detailed below.
### ACCESS-OM2
To generate a set of transport matrices `easytmm` requires multiple user arguments.

| Argument                 | Description                                             | Default       |
| ------------------------ | ------------------------------------------------------- | ------------- |
| -s, --source             | The source directory of ACCESS-OM2 model runs.          | None          |
| -i, --source_inputs      | The source input directory to model runs.               | None          |
| -r, --run_directory      | The directory from which the model was run.             | None          |
| -c, --initial_conditions | Path to initial / boundary conditions in netCDF format. | None          |
| -t, --timestep           | The base timestep of the model in seconds.              | None          |
| -o, --output             | The directory to write transport matrices too.          | matrix_output |
| -m, --model              | The model being used, in this case, ACCESS-OM2.         | om2           |

It is recommended to run this job with `qsub`, allocating at least 32GB of memory. Please ensure that your script is able to write to whichever working directory you have configured. To change the working directroy you can add `cd <directory>` to the start of your script.

Please ensure that the latest `output_XX` and `restart_XX` folders within your `--source` directory are completed runs, and match in number.

This pipeline was created in reference to Ryan Holmes [1 degree ACCESS-OM2 experiment](https://github.com/rmholmes/1deg_jra55_ryf), but it will likely work with other configurations.

You may wish to submit the job via a script similar to:

```bash
#PBS -l storage=gdata/hh5+gdata/v45+scratch/v45+gdata/e14+gdata/ik11
#PBS -l mem=32GB
#PBS -N runscript_alt_7

source /scratch/v45/tm8938/projects/easytmm/venv/bin/activate

echo $PWD
cd /scratch/v45/tm8938/projects/easytmm/
echo $PWD

module load matlab/R2021b
module load matlab_licence/anu

python3 /scratch/v45/tm8938/projects/easytmm/python/main.py -s /scratch/v45/tm8938/projects/easytmm_srcs/1deg_jra55_ryf_red3DSK_C9 -i /g/data/ik11/inputs/access-om2/input_20200530/mom_1deg --run_directory /scratch/v45/tm8938/projects/easytmm_srcs/1deg_jra55_ryf -m mom5 -c /scratch/v45/tm8938/projects/easytmm/sst_access_om2.nc -t 5400
```
## Using the Transport Matrices
Here is an example of how to use the transport matrices once they have been created.

The following code block will build the `tmm` driver and put it in your output directory.
```
$ cd ~
$ git clone https://github.com/samarkhatiwala/tmm
$ cd tmm 
$ export TMMROOT=$PWD
$ cd driver/current
$ make
$ cp tmm <matrix output directory>
```

You will need a `run.sh` file, which may look something like this:
```bash
#!/bin/bash
#PBS -P v45
#PBS -N tmm_test
#PBS -q normal
#PBS -l walltime=01:00:00
#PBS -l ncpus=48
#PBS -l mem=192GB
#PBS -l software=matlab_anu
#PBS -l storage=gdata/hh5+scratch/v45
#PBS -l wd
#PBS -j oe


### Run model 
mpiexec -np 48 ./tmm -numtracers 1 \
  -i Tracer_ini.petsc \
  -max_steps 16200 \
  -write_time_steps 16200 \
  -me \
  -mi  \
  -o Tracer.petsc \
  -obc Tracer_bc_out.petsc \
  -periodic_matrix \
  -matrix_cycle_period 1.0 -matrix_num_per_period 12 -matrix_periodic_times_file periodic_times_365d.bin \
  -prescribed_bc \
  -bc_files Tracer_bc \
  -periodic_bc \
  -bc_cycle_period 1.0 -bc_num_per_period 12 -bc_periodic_times_file periodic_times_365d.bin \
  -time_avg -avg_start_time_step 1 -avg_time_steps 2190 \
  -avg_files Tracer_avg.petsc \
  -bcavg_files Tracer_bc_avg.petsc \
  > log
```

You can then submit this as a job.

```
$ cd <matrix output directory>
$ qsub run.sh
```