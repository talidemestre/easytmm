from pathlib import Path

import netCDF4 as nc
import numpy as np

## Modified from code written by David K. Hutchinson
## TODO: Ask Dave for Comments
def check_levels(tempdir: Path):
    f = nc.Dataset((tempdir / 'ht.nc'),'r')
    ht = f.variables['ht'][:]
    f.close()

    f = nc.Dataset((tempdir / 'temp.nc'),'r')
    temp = f.variables['temp'][:]
    f.close()

    temp = np.squeeze(temp)
    nz, ny, nx = temp.shape

    lev_new = np.zeros((ny, nx), 'i4')
    for j in range(ny):
        for i in range(nx):
            t = temp[:,j,i]
            lev_new[j,i] = t.mask.argmax()
            if not t.mask[nz-1]:
                lev_new[j,i] = nz

    # unlink file to ensure we are creating in temp directory
    (tempdir / 'temp_levels.nc').unlink(missing_ok=True)
    f = nc.Dataset((tempdir / 'temp_levels.nc'),'w')
    f.history = 'check_levels.py \n '

    f.createDimension('nx', nx)
    f.createDimension('ny', ny)

    lo = f.createVariable('num_levels', 'i4', ('ny','nx'))
    lo.long_name = 'levels derived from temperature output'
    lo[:] = lev_new[:]

    f.close()