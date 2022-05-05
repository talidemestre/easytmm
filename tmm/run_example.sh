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
  -me Ae1 -mi Ai1 -mbe Be -mbi Bi \
  -t0 0.0 -iter0 0 \
  -deltat_clock 0.00017123287671232877 \ # fraction of timestep over 1 year
  -max_steps 5840 \ # number of timesteps in 1 year
  -write_time_steps 5840 \ # number of timesteps in 1 year
  -o Tracer.petsc \
  -obc Tracer_bc_out.petsc \
  -periodic_matrix \
  -matrix_cycle_period 1.0 -matrix_num_per_period 12 -matrix_periodic_times_file periodic_times_365d.bin \
  -prescribed_bc \
  -bc_files Tracer_bc \
  -periodic_bc \
  -bc_cycle_period 1.0 -bc_num_per_period 12 -bc_periodic_times_file periodic_times_365d.bin \
  -time_avg -avg_start_time_step 1 -avg_time_steps 5840 \ # number of timesteps in 1 year
  -avg_files Tracer_avg.petsc \
  -bcavg_files Tracer_bc_avg.petsc \
  > log


### Run matlab averages

module load matlab/R2020b
module load matlab_licence/anu
matlab -nosplash -nojvm -nodesktop < load_avg.m > matlab.log

### make Time the record dimension
ncks -O --mk_rec_dmn Time Tracer.nc Tracer.nc

### compress output
nccopy -d5 Tracer.nc tmp.nc
if [ $? -eq 0 ]; then
   mv tmp.nc Tracer.nc
fi
 