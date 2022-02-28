#*coding=utf-8
import optparse,os,sys

import math

usage='''
Descript:
Author:chenweitian
Email:chenweitian@bgi.com
Date:20210119
'''
option = optparse.OptionParser(usage)
option.add_option('','--per_read_modified_base',help='linear',default='' )
option.add_option('','--module',help='',default='' )

(opts, args) = option.parse_args()
per_read_modified_base_opt = opts.per_read_modified_base
module_opt = opts.module

def main():
    dict_split = {}
    count = 0
    for line in open(per_read_modified_base_opt,'r'):
        if line.startswith("read_id"):continue
        count += 1
        line1 = line.strip().split("\t")
        if line1[1] not in dict_split:
            if count == 1:
                ph = open('%s.mega.csv'%(line1[1]),'w')
                ph.write("%s"%(line))
                dict_split[line1[1]] = 1

            else:
                
                ph.close()
                ph = open('%s.mega.csv'%(line1[1]),'w')
                ph.write("%s"%(line))
                dict_split[line1[1]] = 1
        else:
            ph.write("%s"%(line))
    ph.close()


            

if __name__ == '__main__':
    if len(sys.argv)<2:
        os.system("python %s -h"%(sys.argv[0]))
        sys.exit(1)
    else:
        main()
