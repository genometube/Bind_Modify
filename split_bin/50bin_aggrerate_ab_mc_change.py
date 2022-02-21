#*coding=utf-8
import optparse,os,sys
usage='''
Descript:tsv to cov
Author:chenweitian
Email:chenweitian@bgi.com
Date:20210218
'''
option = optparse.OptionParser(usage)
option.add_option('','--cov',help='sort cov',default='' )
(opts, args) = option.parse_args()
cov_opt = opts.cov

def main():
    methy_dict = {}
    flag = 1
    for line in open(cov_opt,'r'):
        line = line.strip().split("\t")
        reads_id = line[4]
        strand = line[5]
        key = "%s\t%s\t%s\t%s\t%s\t%s"%(line[7],line[8],line[9],reads_id,strand,line[6])
        
        methy_stat = int(line[3])
        if flag == 1:#first block
            if key not in methy_dict:
                methy_dict.setdefault(key,[]).append(methy_stat)
                pre_key = key
                flag += 1
                continue
                
        if flag >1 and  key not in  methy_dict:
            #print methy_dict

            if 1 not in methy_dict[pre_key]:
                methy = 0
            else:
                methy = methy_dict[pre_key].count(1)
            if 0 not in methy_dict[pre_key]:
                unmethy = 0
            else:
                unmethy = methy_dict[pre_key].count(0)
            #key_split = '\t'.join(pre_key.split("_"))
            key_split = pre_key
            print ("%s\t%s\t%s\t%s"%(key_split,methy,unmethy,round(float(methy)/(methy+unmethy),2)))
            methy_dict = {}
            methy_dict.setdefault(key,[]).append(methy_stat)
            pre_key = key
            continue
        #-------------------
        if key in methy_dict:
            methy_dict.setdefault(key,[]).append(methy_stat)
    #--------------------
    if 1 not in methy_dict[pre_key]:
        methy = 0
    else:
        methy = methy_dict[pre_key].count(1)
    if 0 not in methy_dict[pre_key]:
        unmethy = 0
    else:
        unmethy = methy_dict[pre_key].count(0)
    #key_split = '\t'.join(pre_key.split("_"))
    key_split = pre_key
    print ("%s\t%s\t%s\t%s"%(key_split,methy,unmethy,round(float(methy)/(methy+unmethy),2)))





        
        
        

if __name__ == '__main__':
    if len(sys.argv)<2:
        os.system("python %s -h"%(sys.argv[0]))
        sys.exit(1)
    else:
        main()
