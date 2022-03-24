from pathlib import Path

import os

def process_ocean_nc_files(tempdir: Path):
    os.system('ncks -v ht,area_t {}/ocean_grid.nc {}/ht.nc'.format(str(tempdir), str(tempdir)))
    os.system('ncks -d time,0,0 -v temp {}/ocean.nc {}/temp.nc'.format(str(tempdir), str(tempdir)))
    os.system('ncks -d time,0,0 -v dzt,st_edges_ocean {}/ocean.nc {}/dzt.nc'.format(str(tempdir), str(tempdir)))

