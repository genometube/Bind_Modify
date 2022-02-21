#*coding=utf-8
import optparse,os,sys
usage='''
Descript:
Author:chenweitian
Email:chenweitian@bgi.com
Date:20210414
'''

option = optparse.OptionParser(usage)
option.add_option('','--mc_table',help='',default='' )
option.add_option('','--read2id',help='',default='' )
option.add_option('','--threshold',help='',default='0.8' )
(opts, args) = option.parse_args()
mc_table_opt = opts.mc_table
read2id_opt = opts.read2id
threshold_opt = float(opts.threshold)


'''
def readid():
    dicta = {}
    for line in open(read2id_opt,'r'):
        line = line.strip().split("\t")
        dicta[line[0]] = line[1]
    return dicta
'''

def readid():
    dicta = {}
    count = 0
    for line in open(read2id_opt,'r'):
        count +=1
        #line = line.strip()
        line = line.strip().split("\t")
        #dicta[line] = count
        dicta[line[0]] = count
    return dicta


def main():
    dicta = readid()
    count = 0
    read_id=""
    for line in open(mc_table_opt,'r'):
        count += 1
        #read_id = "%s_%s"%(line[0],count)
        line = line.strip().split("\t")
        #print line
        if line[6] == "CXX":continue
        if "\'" in line[4]:
            reda_name = line[4].split("\'")[1]            
            if reda_name not in dicta:continue
            read_id = dicta[reda_name]
        pro = float(line[3])
        if pro >= threshold_opt:
            binary_methy = 1
        else:
            binary_methy = 0
        strand = line[5]
        type = line[6]
        #seq = line[7]
        print ("%s\t%s\t%s\t%s\t%s\t%s\t%s"%(line[0],line[1],int(line[1])+1,binary_methy, read_id, strand, type))


if __name__ == '__main__':
    if len(sys.argv)<2:
        os.system("python %s -h"%(sys.argv[0]))
        sys.exit(1)
    else:
        main()

