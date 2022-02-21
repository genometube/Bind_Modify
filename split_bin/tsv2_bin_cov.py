#*coding=utf-8
import optparse,os,sys
usage='''
Descript:tsv to cov
Author:chenweitian
Email:chenweitian@bgi.com
Date:20210218
'''
option = optparse.OptionParser(usage)
option.add_option('','--tsv',help='chr20    50279162    50316454    -   434a9802-52d4-47eb-9f22-bec3a7987d07|9482@-,chr20:50314215-50316454,50279162-50306653,29730 . 5  0.75',default='' )
option.add_option('','--threshold',help='',default='0.6' )
option.add_option('','--id',help='',default='0.6' )
(opts, args) = option.parse_args()
tsv_opt = opts.tsv
threshold_opt = float(opts.threshold)
id_opt = opts.id

def read_id():
    dicta = {}
    count = 0
    for line in open(id_opt,'r'):
        count +=1
        #line = line.strip()
        line = line.strip().split("\t")
        #dicta[line] = count
        dicta[line[0]] = count
    return (dicta)
def main():
    count = 0
    methy_dict = {}
    dict_read = read_id()
    for line in open(tsv_opt,'r'):
        count += 1
        line = line.strip().split("\t")
        Chr = line[0]
        if "\'" in line[4]:
            read = line[4].split("'")[1]
        else:
            read = line[4]
        if read not in dict_read:continue
        if len(line) <7:continue 
        pos = line[6].split(",")
        methy = line[7].split(",")
        single_read_name = "%s_%s"%(Chr, dict_read[read])
        for i in range(len(pos)):
            key = "%s\t%s\t%s"%(Chr,pos[i],int(pos[i])+1)
            if float(methy[i]) < threshold_opt:
                value = 0
            else:
                value = 1
            #print

            print ("%s\t%s\t%s"%(key, single_read_name, value))

if __name__ == '__main__':
    if len(sys.argv)<2:
        os.system("python %s -h"%(sys.argv[0]))
        sys.exit(1)
    else:
        main()

