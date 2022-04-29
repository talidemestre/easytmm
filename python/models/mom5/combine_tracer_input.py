from pathlib import Path
from tqdm import tqdm

import netCDF4 as nc
import numpy as np

import os

def combine_tracer_input(outdir: Path, nx: int, ny: int, nz: int, ntiles: int):
    '''Combines each set of tracers into a tile of tracers for that field.'''
    print("Combining tracer input:")
    for i in tqdm(range(1,ntiles+1)):
        file_tmp = "{}/tracer_set_tmp.nc".format(str(outdir))
        file_out = "{}/tracer_set_{:02d}.nc".format(str(outdir), i)
        fo = nc.Dataset(file_tmp, 'w')
        fo.history = 'combine_tracer_input.py on set %02d \n' % i

        fo.createDimension('xaxis_1', nx)
        fo.createDimension('yaxis_1', ny)
        fo.createDimension('zaxis_1', nz)
        fo.createDimension('Time', 0)

        xo = fo.createVariable('xaxis_1', 'f8', ('xaxis_1'))
        xo.cartesian_axis='X'
        xo[:] = np.arange(1,nx+1)

        yo = fo.createVariable('yaxis_1', 'f8', ('yaxis_1'))
        yo.cartesian_axis='Y'
        yo[:] = np.arange(1,ny+1)

        zo = fo.createVariable('zaxis_1', 'f8', ('zaxis_1'))
        zo.cartesian_axis='X'
        zo[:] = np.arange(1,nz+1)

        to = fo.createVariable('Time', 'f8', ('Time'))
        to.cartesian_axis='T'
        to[:] = 1. 

        for j in range(1,nz+1):
            file_in = "{}/set_{:02d}/ptr_{:02d}.nc".format(str(outdir), i, j)
            var_in = 'ptr_%02d' % j
            fin = nc.Dataset(file_in, 'r')
            var = fin.variables[var_in][:]
            fin.close()
            var_o = fo.createVariable(var_in, 'f8', ('Time','zaxis_1','yaxis_1','xaxis_1'))
            var_o[:] = var[:]
        fo.close()
        
        # os.system('rm {}/set_{:02d}/ptr_??.nc'.format(str(outdir), i))
        os.system('nccopy -d5 %s %s' % (file_tmp, file_out))
        os.system('rm {}'.format((file_tmp)))
