#*coding=utf-8
import sys,re
for line in open(sys.argv[1],'r'):
    if line.startswith("chromosome"):continue
    line =line.strip().split("\t")
    strand = ""
    Type = line[10]
    start = int(line[2])
    log_lik_ratio = line[5]
    read_name = line[4]
    
    if line[1] == "+":
        strand = "f"
    else:
        strand = "r"
    motif = line[11]
    if not re.search("GMG",motif):
        print ("%s\t%s\t%s\t%s\tb'%s'\t%s\t%s\t%s"%(line[0], start,start+1,log_lik_ratio, read_name,strand, Type, motif))
