import numpy as np
import netCDF4 as nc
import matplotlib.pyplot as plt

f = nc.Dataset('topog.nc','r')
levels = f.variables['num_levels'][:]
topog = f.variables['depth'][:]
f.close()

f = nc.Dataset('ht.nc','r')
ht = f.variables['ht'][:]
st = f.variables['st_ocean'][:]
st_e = f.variables['st_edges_ocean'][:]
f.close()
zb = st_e[1:]

f = nc.Dataset('temp.nc','r')
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

# for j in range(ny):
#     for i in range(nx):
#         lev_new[j,i] = (zb < ht[j,i]).argmin() + 1 
# lev_new[ht.mask] = 0

diff = lev_new - levels

f = nc.Dataset('temp_levels.nc','w')
f.history = 'check_levels.py \n '

f.createDimension('nx', nx)
f.createDimension('ny', ny)

lo = f.createVariable('num_levels', 'i4', ('ny','nx'))
lo.long_name = 'levels derived from temperature output'
lo[:] = lev_new[:]

f.close()

# plt.figure(figsize=(4,4))
# plt.pcolor(diff)
# plt.colorbar()
# plt.savefig('diff1.png')

