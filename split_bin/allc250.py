#*coding=utf-8

#*coding=utf-8
import optparse,os,sys
usage='''
Descript:tsv to cov
Author:chenweitian
Email:chenweitian@bgi.com
Date:20210813
'''
option = optparse.OptionParser(usage)
option.add_option('','--tsv',help='chr20    50279162    50316454    -   434a9802-52d4-47eb-9f22-bec3a7987d07|9482@-,chr20:50314215-50316454,50279162-50306653,29730 . 5  0.75',default='' )
#option.add_option('','--threshold',help='',default='0.8' )
option.add_option('','--fasta',help='',default='' )
option.add_option('','--chr',help='',default='' )
(opts, args) = option.parse_args()
tsv_opt = opts.tsv
#threshold_opt = float(opts.threshold)
fasta_opt = opts.fasta
chr_opt = opts.chr


def get_chromosome_sequence(fasta_name,query_chrom):
    chrom_pointer = None
    with open(fasta_name+".fai",'r') as f:
        for line in f:
            fields = line.split("\t")
            if fields[0] == query_chrom:
                chrom_pointer = int(fields[2])
    if chrom_pointer is None: return(None)

    seq = ""
    with open(fasta_name,'r') as f:
        f.seek(chrom_pointer)
        for line in f:
            if line[0] == ">": break
            seq += line.rstrip("\n")
    return(seq)



def main_no_consider_cpg_gpc_overlap():
    # header = ['chr_name','position','probability','read_id','strand','type','base']
    header = ['chr_name','start','end','probability','read_id','strand','type','base']
    #chrY.mega.sort.csv.5mC.tsv
    os.system("echo -e %s >header.txt"%(header))
    Chr = chr_opt
    seq = get_chromosome_sequence(fasta_opt,Chr)
    count = 0
    for line in open(tsv_opt,'r'):
        line = line.strip().split("\t")
        strand = line[3]

        #if "'" in line[4]:
        #    read_name = line[4].split("'")[1]
        count += 1
        ##read_name = "%s_%s"%(line[0],count)
        read_name = line[4]
        pos = line[6].split(",")
        pro = line[7].split(",")
        if strand == "+":
            for i in range(len(pos)):
                site = int(pos[i])
                #print "cwt:%s"%(seq[site:site+2].upper() )
                if seq[site:site+2].upper() == "CG":
                    print ("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s"%(Chr,pos[i],int(pos[i])+1,pro[i],read_name,"f","CpG",seq[site:site+3].upper()))
                elif seq[site+2].upper() == "G":#the third base site :CHG
                    print ("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s"%(Chr,pos[i],int(pos[i])+1,pro[i],read_name,"f","CHG",seq[site:site+3].upper()))
                else:
                    #CHH
                    print ("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s"%(Chr,pos[i],int(pos[i])+1,pro[i],read_name,"f","CHH",seq[site:site+3].upper()))
                if seq[site-1].upper() == "G":
                    print ("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s"%(Chr,pos[i],int(pos[i])+1,pro[i],read_name,"f","GC",seq[site-1:site+1].upper()))

        if strand == "-":
            for i in range(len(pos)):
                site = int(pos[i])
                #print "cwt:%s"%(seq[site:site+2].upper() )
                if seq[site-1:site+1].upper() == "CG":
                    print ("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s"%(Chr,pos[i],int(pos[i])+1,pro[i],read_name,"r","CpG",seq[site-2:site+1].upper()))
                elif seq[site-2].upper() == "C":#the third base site :CHG
                    print ("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s"%(Chr,pos[i],int(pos[i])+1,pro[i],read_name,"r","CHG",seq[site-2:site+1].upper()))
                else:
                    #CHH
                    print ("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s"%(Chr,pos[i],int(pos[i])+1,pro[i],read_name,"r","CHH",seq[site-2:site+1].upper()))
                if seq[site+1].upper() == "C":
                    print ("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s"%(Chr,pos[i],int(pos[i])+1,pro[i],read_name,"r","GC",seq[site:site+2].upper()))


def main_consider_cpg_gpc_overlap():
    # header = ['chr_name','position','probability','read_id','strand','type','base']
    header = ['chr_name','start','end','probability','read_id','strand','type','base']
    #chrY.mega.sort.csv.5mC.tsv
    os.system("echo -e %s >header.txt"%(header))
    Chr = chr_opt
    seq = get_chromosome_sequence(fasta_opt,Chr)
    count = 0
    for line in open(tsv_opt,'r'):
        line = line.strip().split("\t")
        strand = line[3]

        #if "'" in line[4]:
        #    read_name = line[4].split("'")[1]
        count += 1
        ##read_name = "%s_%s"%(line[0],count)
        read_name = line[4]
        pos = line[6].split(",")
        pro = line[7].split(",")
        if strand == "+":
            for i in range(len(pos)):
                site = int(pos[i])
                #print "cwt:%s"%(seq[site:site+2].upper() )
                if seq[site-1:site+1].upper() == "GC" and seq[site:site+2].upper() != "CG" :
                    print ("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s"%(Chr,pos[i],int(pos[i])+1,pro[i],read_name,"f","GpC",seq[site-1:site+2].upper()))

                elif seq[site:site+2].upper() == "CG" and seq[site-1].upper() != "G":
                    print ("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s"%(Chr,pos[i],int(pos[i])+1,pro[i],read_name,"f","CpG",seq[site:site+3].upper()))
                else:
                    #other type
                    print ("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s"%(Chr,pos[i],int(pos[i])+1,pro[i],read_name,"f","CXX",seq[site:site+3].upper()))


        if strand == "-":
            for i in range(len(pos)):
                site = int(pos[i])
                #print "cwt:%s"%(seq[site:site+2].upper() )
                if seq[site+1].upper() == "C" and seq[site-1].upper() != "C":
                    print ("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s"%(Chr,pos[i],int(pos[i])+1,pro[i],read_name,"r","GpC",seq[site-1:site+2].upper()))

                elif seq[site-1:site+1].upper() == "CG" and seq[site+1].upper() != "C":
                    print ("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s"%(Chr,pos[i],int(pos[i])+1,pro[i],read_name,"r","CpG",seq[site-2:site+1].upper()))

                else:
                    #other type
                    print ("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s"%(Chr,pos[i],int(pos[i])+1,pro[i],read_name,"r","CXX",seq[site-2:site+1].upper()))
                


if __name__ == '__main__':
    if len(sys.argv)<2:
        os.system("python %s -h"%(sys.argv[0]))
        sys.exit(1)
    else:
        main_consider_cpg_gpc_overlap()


#python /zfswh1/BC_RD_P0/P19Z12200N0089/2021/dup_protein/script/all_C2_50bin.py --tsv

