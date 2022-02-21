##########################################################################
#########                   Set up the environment            ############
##########################################################################


script_path="Bind_Modify/single_molecule"
script_path="/zfswh1/BC_RD_P0/P19Z12200N0089/2021/cut_modify/review/enhancer/promoter_up_2k/panel4_github_test/single_molecule"
run_path="./coA_heatmap/"
run_path="/zfswh1/BC_RD_P0/P19Z12200N0089/2021/cut_modify/review/enhancer/promoter_up_2k/panel4_github_test"
single_cov="merge_strand.cov.bgz"
single_cov="/zfswh1/BC_RD_P0/P19Z12200N0089/2021/cut_modify/review/2batch/merge_batch1_batch2/all_merge.cov.bgz"
interest_region="interest_region.bed"
interest_region="list"
anno_file="interest_region.xls"
anno_file="/zfswh1/BC_RD_P0/P19Z12200N0089/2021/cut_modify/review/enhancer/promoter_up_2k/interest_region.xls"


##########################################################################
#########                   Batch run                         ############
##########################################################################

cat ${interest_region}|while read line
do
Chr=`echo $line|awk '{print $1}'`
Start=`echo $line|awk '{print $2}'`
End=`echo $line|awk '{print $3}'`
Name="${Chr}_${Start}-${End}"

mkdir  -p $Name

cd $Name

echo -e "source /ifswh1/BC_RD/RD_COM/USER/chenweitian/software/python/bin/activate py38" > $Name.coa_heatmap.sh

echo -e "tabix  ${single_cov} $Chr:$Start-$End > $Name.single.cov" >> $Name.coa_heatmap.sh

echo -e " cut -f1-3 $Name.single.cov |sort|uniq  > id.list" >> $Name.coa_heatmap.sh

echo -e "cut -f1-3,5-6 ${anno_file} > gene_enhancer_promoter.txt" >> $Name.coa_heatmap.sh

#echo -e "bedtools intersect -a id.list -b gene_enhancer_promoter.txt  -wo |cut -f1-3,7|awk '{print \$1\"_\"\$2\"_\"\$3\"_\"\$4}' > anno.tmp" >> $Name.coa_heatmap.sh
echo -e "bedtools intersect -a id.list -b gene_enhancer_promoter.txt  -wo |cut -f1-3,7|awk '{print \$1\"_\"\$2\"_\"\$3\"\\t\"\$4}' > anno.tmp" >> $Name.coa_heatmap.sh
echo -e "bedtools intersect -a id.list -b gene_enhancer_promoter.txt -v |awk '{print \$1\"_\"\$2\"_\"\$3\"\\tother\"}' >>  anno.tmp" >> $Name.coa_heatmap.sh

echo -e "sort  anno.tmp|uniq > $Name.interest_region.xls" >> $Name.coa_heatmap.sh

echo -e "Rscript ${script_path}/single_molecule_coa.r  $Name.single.cov  $Name.interest_region.xls  $Name.single " >> $Name.coa_heatmap.sh

sh $Name.coa_heatmap.sh 2> $Name.coa_heatmap.log

cd -
done
