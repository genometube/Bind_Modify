#*coding=utf-8
#merge multiple type
import sys

def read_m6a_read(all_read):
    dicta = {}
    for line in open(all_read,'r'):
        line = line.strip().split("\t")
        key = "%s\t%s\t%s\t%s"%(line[0], line[1], line[2], line[3])
        dicta.setdefault(key,[]).extend([line[4],line[5]])
        #dicta[key] = "%s"%()
    return (dicta)

def read_cpggpc_read(all_read):
    dicta = {}
    for line in open(all_read,'r'):
        line = line.strip().split("\t")
        #line = line.strip().split()
        key = "%s\t%s\t%s\t%s"%(line[0], line[1], line[2], line[3])
        #dicta[key] = "%s"%([line[5],line[6]])
        dicta.setdefault(key,[]).extend([line[5],line[6]])
    return (dicta)



def main():
    m6a = read_m6a_read(sys.argv[1])
    cpg = read_cpggpc_read(sys.argv[2])
    gpc = read_cpggpc_read(sys.argv[3])
    print ("chr_name\tbin_start\tbin_end\tread_name\tstrand\tm6A_methy\tm6A_unmethy\tCpG_methy\tCpG_unmethy\tGpC_methy\tGpC_unmethy")
    for line in open(sys.argv[4],'r'):
        line = line.strip().split("\t")
        key = "%s\t%s\t%s\t%s"%(line[0], line[1], line[2], line[3])
        list = []
        list.append(key)
        #print (line[4])
        #list.append(line[4].split("_")[1])
        list.append(line[4])
        if key in m6a:
            list.extend(m6a[key])
            #print (list)
            #print ("cwt:\t%s\t%s\t%s\t%s"%(key, dicta[key],line[5],line[6]))
        else :
            list.extend([0,0])
            #print ("\t%s\t%s\t%s\t%s"%(key, dicta[key],line[5],line[6]))
            ##############
        if key in cpg:
            #print (cpg[key])
            list.extend(cpg[key])
        else :
            list.extend([0,0])
            ###############3    
        if key in gpc:
            list.extend(gpc[key])
        else :
            list.extend([0,0])
        #print ("\t".join([str(i) for i in list]))
        print ("\t".join([str(i) for i in  list]))
main()
