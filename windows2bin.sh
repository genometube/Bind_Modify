##########################################################################
#########                   Set up the environment            ############
##########################################################################
script_path="Bind_Modify/split_bin"

bed=/research/chenweitian/project/2021/database/chr7.100_no_slide.bed

# m6A_tsv="chr7.mega.sort.csv.m6A.tsv"
# m5C_tsv="chr7.mega.sort.csv.5mC.tsv"
# nano_m5c="methylation_calls.tsv"

m6A_tsv="$1"

m5C_tsv="$2"

fasta="/research/chenweitian/project/2021/database/chr7.fa"

m6A_base_propobility_threshold=0.9
m5C_base_propobility_threshold=0.8

run_path="bindModify/analysis/window_bin"

##########################################################################
#########                           run                       ############
##########################################################################
# assign number

mkdir -p ${run_path}
cd ${run_path}

cat ${m6A_tsv} ${m5C_tsv}|awk '{print $5"\t"$4}' |sort|uniq | sed  "s#b'##;s#'##g" |awk '{print $0"\t"NR}'> all_read.id

mkdir -p m6A m5C merge

############################################
#############    m5C               #########
############################################
#5mc

cd m5C
##-------------------------
python ${script_path}/allc250.py  --tsv  ${m5C_tsv} --fasta  $fasta --chr chr7 >  5mC_single.tsv
#chr7    91423026        91423027        0.56    b'0000e193-379e-434a-a292-f2d9f5078745' r       GpC     AGC
#chr7    91423030        91423031        0.67    b'0000e193-379e-434a-a292-f2d9f5078745' r       CXX     CA
python ${script_path}/m5c2bed.py  --mc_table 5mC_single.tsv --read2id  ../all_read.id  --threshold ${m5C_base_propobility_threshold} > C.txt
grep GpC  C.txt   >   GpC.txt
grep CpG   C.txt  >   CpG.txt
#--------------------------

#-----nanopolish-----------
#python /research/chenweitian/project/202108/megalodon/20211201_hela_SMAC_RNPII_human/nanopolish2merge.py $nano_m5c > 5mC_single.tsv
#python ${script_path}/m5c2bed.py  --mc_table 5mC_single.tsv --read2id  ../all_read.id  --threshold 0.25 > C.txt
#grep GC  C.txt   >   GpC.txt
#grep CG   C.txt  >   CpG.txt
#---------------------------



## 单位点的甲基化率
python ${script_path}/tsv2cov.py --bed CpG.txt > CpG_methylation.txt

python ${script_path}/tsv2cov.py --bed GpC.txt > GpC_methylation.txt

## 
bedtools intersect  -a  GpC.txt -b $bed  -wo  >  GpC_intersect.txt2
bedtools intersect  -a CpG.txt  -b $bed  -wo  > CpG_intersect.txt2

mkdir -p T
sort -k9,9n  -k5,5 CpG_intersect.txt2  -T T/ -S 10G  >  CpG_intersect.sort.txt2
sort -k9,9n  -k5,5 GpC_intersect.txt2  -T T/ -S 10G  >  GpC_intersect.sort.txt2

python ${script_path}/50bin_aggrerate_ab_mc_change.py  --cov  GpC_intersect.sort.txt2  > GpC_intersect.sort_final.txt

python ${script_path}/50bin_aggrerate_ab_mc_change.py  --cov  CpG_intersect.sort.txt2  > CpG_intersect.sort_final.txt
cd ..

############################################
#############    m6A               #########
############################################

cd m6A/

## 6mA
# cd /research/chenweitian/project/2021/database
# bedtools makewindows  -g hg19.txt -w 100 -s 100  >hg19_100_no_sliding.bed
# grep chr20 hg19_100_no_sliding.bed > hg19_chr20_100_no_sliding.bed
# /research/chenweitian/project/2021/database/chr20.no.sliding


python ${script_path}/tsv2_bin_cov.py  --tsv ${m6A_tsv} --threshold ${m6A_base_propobility_threshold}  --id ../all_read.id  >m6A_single.tsv

bedtools intersect -a  m6A_single.tsv  -b $bed  -wo  > m6A_intersect.bed

mkdir -p tmp
sort -k7,7n -k4,4 m6A_intersect.bed -T tmp> m6A_intersect.sort.bed 


sed 's#chrUn_g#chrUn@g#g' m6A_intersect.sort.bed > m6A_intersect.sort.bed2
python ${script_path}/50bin_aggrerate_ab_change2.py   --cov m6A_intersect.sort.bed2|cut -f1-3,5-7 > m6A_intersect.sort.bed3
sed 's#@#_#g' m6A_intersect.sort.bed3 > m6A_intersect.sort.bed4

rm m6A_intersect.sort.bed3 m6A_intersect.sort.bed2 
cd ..

############################################
#############    merge table       #########
############################################
cd merge

cut -f1-5,7-8 ../m5C/GpC_intersect.sort_final.txt |sed 's#@#_#g' > GpC_intersect.bed2

cut -f1-5,7-8 ../m5C/CpG_intersect.sort_final.txt  |sed 's#@#_#g' > CpG_intersect.bed2

mkdir -p tmp;cut -f1-4  ../m6A/m6A_intersect.sort.bed4  CpG_intersect.bed2 GpC_intersect.bed2 |sort -T tmp|uniq|awk 'NR==FNR{a[$3]=$2;next}{if($4 in a )print $0"\t"a[$4]}' ../all_read.id -  >all_name
#-----------------

python  ${script_path}/merge_all_type.py ../m6A/m6A_intersect.sort.bed4 CpG_intersect.bed2 GpC_intersect.bed2 all_name > merge_strand.cov

python  ${script_path}/merge_cov2_wig.py --cov  merge_strand.cov  > merge_all.cov
