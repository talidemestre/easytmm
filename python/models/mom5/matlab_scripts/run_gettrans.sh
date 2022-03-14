#!/bin/bash
#PBS -P v45
#PBS -q normal
#PBS -l walltime=02:00:00
#PBS -l ncpus=1
#PBS -l mem=4GB
#PBS -l software=matlab_unsw
#PBS -l storage=gdata/hh5+scratch/v45+scratch/y99
#PBS -l wd
#PBS -j oe

module load matlab/R2020b
module load matlab_licence/unsw

matlab -nosplash -nojvm -nodesktop < GetTransport.m > $PBS_JOBID.log
