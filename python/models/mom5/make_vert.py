from pathlib import Path

import netCDF4 as nc
import numpy as np

## Modified from code written by David K. Hutchinson
## TODO: Ask Dave for Comments
def make_vert(tempdir: Path):
    f = nc.Dataset((tempdir / 'ocean_hgrid.nc'),'r')
    x = f.variables['x'][:]
    y = f.variables['y'][:]
    f.close()

    xvert_0 = x[0:-1:2,0:-1:2]
    xvert_1 = x[0:-1:2,2::2]
    xvert_2 = x[2::2,2::2]
    xvert_3 = x[2::2,0:-1:2]

    yvert_0 = y[0:-1:2,0:-1:2]
    yvert_1 = y[0:-1:2,2::2]
    yvert_2 = y[2::2,2::2]
    yvert_3 = y[2::2,0:-1:2]

    ny, nx = xvert_0.shape

    xvert = np.zeros((4, ny, nx))
    yvert = np.zeros((4, ny, nx))

    xvert[0,:,:] = xvert_0
    xvert[1,:,:] = xvert_1
    xvert[2,:,:] = xvert_2
    xvert[3,:,:] = xvert_3

    yvert[0,:,:] = yvert_0
    yvert[1,:,:] = yvert_1
    yvert[2,:,:] = yvert_2
    yvert[3,:,:] = yvert_3

    # unlink file to ensure we are creating in temp directory
    (tempdir / 'ocean_vert.nc').unlink(missing_ok=True)
    f = nc.Dataset((tempdir / 'ocean_vert.nc'),'w')
    f.history = 'make_vert.py \n '

    f.createDimension('vertex', 4)
    f.createDimension('nx', nx)
    f.createDimension('ny', ny)

    xo = f.createVariable('x_vert_T', 'f8', ('vertex', 'ny', 'nx'))
    xo.long_name = 'Geographic longitude of T_cell vertices begin southwest counterclockwise'
    xo.units = 'degree_east'
    xo[:] = xvert[:]

    yo = f.createVariable('y_vert_T', 'f8', ('vertex', 'ny', 'nx'))
    yo.long_name = 'Geographic latitude of T_cell vertices begin southwest counterclockwise'
    yo.units = 'degree_north'
    yo[:] = yvert[:]

    f.close()
