from argparse import Namespace
from pathlib import Path

import numpy as np
import netCDF4 as nc
import os

def preprocess(args: Namespace, tempdir: Path): 
    try:
        assert(args.source_inputs != None)
        
    except:
        raise ValueError("mom5 implementation requires a '--source_input' directory is specified")

    (tempdir / 'ocean_hgrid.nc').symlink_to(args.source_inputs / 'ocean_hgrid.nc')
    (tempdir / 'topog.nc').symlink_to(args.source_inputs / 'topog.nc')
    check_levels(tempdir)
    make_vert(tempdir)

## Modified from code written by David K. Hutchinson
## TODO: Ask Dave for Comments
def check_levels(tempdir: Path):
    f = nc.Dataset((tempdir / 'topog.nc'),'r')
    levels = f.variables['num_levels'][:]
    topog = f.variables['depth'][:]
    f.close()

    f = nc.Dataset((tempdir / 'ht.nc'),'r')
    ht = f.variables['ht'][:]
    st = f.variables['st_ocean'][:]
    st_e = f.variables['st_edges_ocean'][:]
    f.close()
    zb = st_e[1:]

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

    diff = lev_new - levels

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

