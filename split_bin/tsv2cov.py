#*coding=utf-8

import optparse,os,sys



usage='''
Descript: stat bed intersect 
Author:chenweitian
Email:chenweitian@bgi.com
Date:20210218
'''
option = optparse.OptionParser(usage)
option.add_option('','--bed',help='',default='CpG.txt' )


(opts, args) = option.parse_args()
bed_opt = opts.bed


'''
chr20   43838788        43838789        0       1       f       CpG
chr20   43839407        43839408        1       1       f       CpG
chr20   43839489        43839490        1       1       f       CpG
chr20   43839610        43839611        1       1       f       CpG
chr20   43839736        43839737        1       1       f       CpG
chr20   43839879        43839880        1       1       f       CpG
'''

def main():
    dicta = {}

    for line in open(bed_opt, 'r'):
        line = line.strip().split("\t")
        dicta.setdefault(line[0],{}).setdefault(line[1],[]).append(line[3])
    for Chr in dicta:
        for pos in  dicta[Chr]:
            methy = dicta[Chr][pos].count('1')
            unmethy = dicta[Chr][pos].count('0')
            ratio = round(float(methy)/(methy+unmethy),2)
            #print ("%s\t%s\t%s"%(pos,methy,unmethy))
            print ("%s\t%s\t%s\t%s\t%s\t%s"%(Chr, pos, int(pos)+1,methy, unmethy, ratio))
   
if __name__ == '__main__':
    if len(sys.argv)<2:
        os.system("python %s -h"%(sys.argv[0]))
        sys.exit(1)
    else:
        main()
