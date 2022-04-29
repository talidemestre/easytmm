from pathlib import Path

import os

def make_diag_field(tempdir: Path, nz: int):
    '''Generate a diagnostic field for our model run and write it to our temp directory.'''
    diag_file = tempdir / 'diag_table'

    f = open(str(diag_file),'r')
    header = f.readlines()[0:2]
    f.close()

    if diag_file.is_symlink():
        os.system("cp --remove-destination `readlink {0}` {0}".format(str(diag_file)))
    
    f = open(str(diag_file),'w')
    f.write(header[0])
    f.write(header[1])
    f.write('"ocean_transport",      1,  "months", 1, "days", "time",\n\n')


    for i in range(1,nz+1):
        l1 = '"transport_matrix","exp_tm_%02d","exp_tm_%02d" ,"ocean_transport","all",.true.,"none",1\n' % (i,i)
        l2 = '"transport_matrix","imp_tm_%02d","imp_tm_%02d" ,"ocean_transport","all",.true.,"none",1\n' % (i,i)
        f.write(l1)
        f.write(l2)

    f.close()

