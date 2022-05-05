from pathlib import Path

import subprocess

def process_ocean_nc_files(tempdir: Path):
    '''Extracts fields from some NetCDF files into their own file. '''
    subprocess.check_call('ncks -v ht,area_t {}/ocean_grid.nc {}/ht.nc'.format(str(tempdir), str(tempdir)), shell=True)
    subprocess.check_call('ncks -d time,0,0 -v temp {}/ocean.nc {}/temp.nc'.format(str(tempdir), str(tempdir)), shell=True)
    subprocess.check_call('ncks -d time,0,0 -v dzt,st_edges_ocean {}/ocean.nc {}/dzt.nc'.format(str(tempdir), str(tempdir)), shell=True)