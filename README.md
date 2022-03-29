# easytmm
Program for the simple creation and execution of TMM models.

```
module purge
module load netcdf/4.8.0
module load octave/5.2.0
```

```
qsub -I  -P v45 -l mem=8GB  -l storage=gdata/hh5+gdata/v45+scratch/v45+gdata/e14+gdata/ik11
```