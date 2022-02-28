#*coding=utf-8
import optparse,os,sys

import math

usage='''
Descript:linear megalodon
Author:chenweitian
Email:chenweitian@bgi.com
Date:20210119
'''
option = optparse.OptionParser(usage)
option.add_option('','--per_read_modified_base',help='',default='' )
option.add_option('','--module',help='',default='' )

(opts, args) = option.parse_args()
per_read_modified_base_opt = opts.per_read_modified_base
module_opt = opts.module


def filter_read():
    for line in open(per_read_modified_base_opt,'r'):
        line = line.strip().split("\t")
        reads = line[0]
        ref_id = line[1].split("|")[0]
        if reads  == ref_id:
            print ("%s\t%s\t%s\t%s\t%s\t%s\t%s"%(line[0],line[1],line[2],line[3],math.exp( float(line[4] )),math.exp(float(line[5])),line[6]))
    #python extract_ecDNA_per_read_modified_base.py megalodon_results/per_read_modified_base_calls.txt >megalodon_results/ecDNA.per_read_modified_base_calls.txt



def to_smac():
    m6A = open("%s.m6A.tsv"%(per_read_modified_base_opt ),'w')
    F5C = open("%s.5mC.tsv"%(per_read_modified_base_opt ),'w')
    Ymod = {}
    Zmod = {}
    count6 = 0 
    count5 = 0
    Ymod_read_tag = ""
    Zmod_read_tag = ""
    for line in open(per_read_modified_base_opt,'r'):
        if line.startswith("read_id\tchrm"):continue
        line = line.strip().split("\t")
        reads = line[0]
        chr = line[1]
        #ccb53a77-4ad2-48be-a97a-fdd9f2f2be74
        mod = round(math.exp( float(line[4] )),2)
        con = round(math.exp( float(line[5] )),2)
        pos = line[3]
        strand = line[2]
        #if mod >=0.5 and mod > con:
        if 1:
            if line[-1] == "Y":
                count6 += 1
                if line[0] not in Ymod :
                    if count6 == 1:
                        pos_m6A_list = []
                        mod_m6A_list = []
                        pos_m6A_list.append(str(pos))
                        mod_m6A_list.append(str(mod))
                        Ymod[line[0]] = strand
                    else:
                        pos_m6A = "%s"%(','.join(pos_m6A_list))
                        mod_m6A = "%s"%(','.join(mod_m6A_list))
                        reads = Ymod_read_tag.split("|")[0]
                        chr =  Ymod_read_tag.split("|")[1]
                        m6A.write("%s\t%s\t%s\t%s\tb'%s'\t.\t%s\t%s\n"%( chr,pos_m6A.split(',')[0],pos_m6A.split(',')[-1],Ymod[reads],reads,pos_m6A,mod_m6A))
                        pos_m6A_list = []
                        mod_m6A_list = []
                        pos_m6A_list.append(str(pos))
                        mod_m6A_list.append(str(mod))
                        Ymod[line[0]] = strand
                else:
                    pos_m6A_list.append(str(pos))
                    mod_m6A_list.append(str(mod))
                    Ymod_read_tag = "%s|%s"%(line[0],line[1])
            if line[-1] == "Z":
                if line[0] not in Zmod :
                    count5 += 1
                    if count5 == 1:
                        pos_m5C_list = []
                        mod_m5C_list = []
                        pos_m5C_list.append(str(pos))
                        mod_m5C_list.append(str(mod))
                        Zmod[line[0]] = strand
                    else:
                        pos_m5C = "%s"%(','.join(pos_m5C_list))
                        mod_m5C = "%s"%(','.join(mod_m5C_list))
                        reads = Zmod_read_tag.split("|")[0]
                        chr =  Zmod_read_tag.split("|")[1]
                        F5C.write("%s\t%s\t%s\t%s\tb'%s'\t.\t%s\t%s\n"%(chr,pos_m5C.split(',')[0],pos_m5C.split(',')[-1],Zmod[reads],reads,pos_m5C,mod_m5C))
                        pos_m5C_list = []
                        mod_m5C_list = []
                        pos_m5C_list.append(str(pos))
                        mod_m5C_list.append(str(mod))
                        Zmod[line[0]] = strand
                else:
                    pos_m5C_list.append(str(pos))
                    mod_m5C_list.append(str(mod))
                    #Zmod_read_tag = line[1]
                    Zmod_read_tag = "%s|%s"%(line[0],line[1])
    pos_m5C = "%s"%(','.join(pos_m5C_list))
    mod_m5C = "%s"%(','.join(mod_m5C_list))
    reads = Zmod_read_tag.split("|")[0]
    F5C.write("%s\t%s\t%s\t%s\tb'%s'\t.\t%s\t%s\n"%(Zmod_read_tag.split("|")[1],pos_m5C.split(',')[0],pos_m5C.split(',')[-1],Zmod[reads],reads,pos_m5C,mod_m5C))

    pos_m6A = "%s"%(','.join(pos_m6A_list))
    mod_m6A = "%s"%(','.join(mod_m6A_list))
    reads = Ymod_read_tag.split("|")[0]
    m6A.write("%s\t%s\t%s\t%s\tb'%s'\t.\t%s\t%s\n"%(Ymod_read_tag.split("|")[1]
,pos_m6A.split(',')[0],pos_m6A.split(',')[-1],Ymod[reads],reads,pos_m6A,mod_m6A))


if __name__ == '__main__':
    if len(sys.argv)<2:
        os.system("python %s -h"%(sys.argv[0]))
        sys.exit(1)
    else:
        #filter_read()
        to_smac()
