#*coding=utf-8

import optparse,os,sys



usage='''
Descript: 
Author:chenweitian
Email:chenweitian@bgi.com
Date:20210218
python merge_cov2_wig.py  --cov  merge.cov > merge.merge.cov
'''
option = optparse.OptionParser(usage)
option.add_option('','--cov',help='',default='' )

(opts, args) = option.parse_args()
cov_opt = opts.cov


def main():
    dicta = {}
    wm6a_ratio = open("m6A_ratio.wig",'w')
    wm6a_count = open("m6A_count.wig",'w')
    wcpg_ratio = open("cpg_ratio.wig",'w')
    wcpg_count = open("cpg_count.wig",'w')
    wgpc_ratio = open("gpc_ratio.wig",'w')
    wgpc_count = open("gpc_count.wig",'w')
    for line in open(cov_opt, 'r'):
        if line.startswith("chr_name"):continue
        line = line.strip().split("\t")
        key = "%s\t%s\t%s"%(line[0], line[1], line[2]) 
        dicta.setdefault(key,{}).setdefault('m6A',[]).append(int(line[5]))
        dicta.setdefault(key,{}).setdefault('Nm6A',[]).append(int(line[6]))
        dicta.setdefault(key,{}).setdefault('cpg',[]).append(int(line[7]))
        dicta.setdefault(key,{}).setdefault('Ncpg',[]).append(int(line[8]))
        dicta.setdefault(key,{}).setdefault('gpc',[]).append(int(line[9]))
        dicta.setdefault(key,{}).setdefault('Ngpc',[]).append(int(line[10]))


    for key in dicta:
        m6A_ratio = 0
        cpg_ratio = 0
        gpc_ratio = 0
        m6A = sum(dicta[key]['m6A'])
        Nm6A = sum(dicta[key]['Nm6A']) 
        cpg = sum(dicta[key]['cpg'])
        Ncpg = sum(dicta[key]['Ncpg'] )
        gpc = sum(dicta[key]['gpc'])
        Ngpc = sum(dicta[key]['Ngpc'] )
        print ("%s\t%s\t%s\t%s\t%s\t%s\t%s"%(key, m6A, Nm6A, cpg, Ncpg, gpc, Ngpc))

        if m6A+Nm6A >0:
            m6A_ratio = round(float(m6A)/(m6A+Nm6A),3)
        if cpg+Ncpg >0 :
            cpg_ratio = round(float(cpg)/(cpg+Ncpg),3)
        if gpc+Ngpc >0:
            gpc_ratio = round(float(gpc)/(gpc+Ngpc),3)
        wm6a_ratio.write("%s\t%s\n"%(key,m6A_ratio))
        wm6a_count.write("%s\t%s\n"%(key,m6A))
        wcpg_ratio.write("%s\t%s\n"%(key,cpg_ratio))
        wcpg_count.write("%s\t%s\n"%(key,cpg))
        wgpc_ratio.write("%s\t%s\n"%(key,gpc_ratio))
        wgpc_count.write("%s\t%s\n"%(key,gpc))
   
if __name__ == '__main__':
    if len(sys.argv)<2:
        os.system("python %s -h"%(sys.argv[0]))
        sys.exit(1)
    else:
        main()
