import numpy as np
import netCDF4 as nc
import os
# import argparse

ntile = 38
nz = 50
ny = 175
nx = 240
for i in range(2,ntile+1):
    print 'Combining set %02d' % i
    os.chdir('set_%02d' % i)
    file_tmp = 'tracer_set.nc'
    file_out = 'tracer_set_%02d.nc' % i
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
        file_in = 'ptr_%02d.nc' % j
        var_in = 'ptr_%02d' % j
        fin = nc.Dataset(file_in, 'r')
        var = fin.variables[var_in][:]
        fin.close()
        var_o = fo.createVariable(var_in, 'f8', ('Time','zaxis_1','yaxis_1','xaxis_1'))
        var_o[:] = var[:]
    fo.close()
    os.system('rm ptr_??.nc')
    os.system('nccopy -d5 %s %s' % (file_tmp, file_out))
    os.system('rm %s' % (file_tmp))
    os.chdir('..')