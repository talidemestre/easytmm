f = open('diag_tracers.txt','w')

for i in range(1,51):
    l1 = '"transport_matrix","exp_tm_%02d","exp_tm_%02d" ,"ocean_transport","all",.true.,"none",1\n' % (i,i)
    l2 = '"transport_matrix","imp_tm_%02d","imp_tm_%02d" ,"ocean_transport","all",.true.,"none",1\n' % (i,i)
    f.write(l1)
    f.write(l2)

f.close()
