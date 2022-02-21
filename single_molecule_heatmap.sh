##########################################################################
#########                   Set up the environment            ############
##########################################################################


script_path="Bind_Modify/single_molecule"
run_path="./m6A_cpg_heatmap/"

single_cov="merge_strand.cov.bgz"
interest_region="gene_element_region.bed"


##########################################################################
#########                   Batch run                         ############
##########################################################################
>cumulative_sum_merge.list

cat ${interest_region}|while read line
do
Chr=`echo $line|awk '{print $1}'`
Start=`echo $line|awk '{print $2}'`
End=`echo $line|awk '{print $3}'`
Name="${Chr}_${Start}-${End}"

mkdir  -p $Name

cd $Name

echo -e "source /ifswh1/BC_RD/RD_COM/USER/chenweitian/software/python/bin/activate py38" > m6A_cpg_heatmap.sh

echo -e "tabix  ${single_cov} $Chr:$Start-$End > $Name.single.cov" >> m6A_cpg_heatmap.sh

echo -e "awk '{if((\$6+\$7)==0)print \$1\"\\t\"\$2\"\\t\"\$3\"\\t\"\$4\"\\t\"\$6\"\\t\"\$7\"\\t0\" ;else print \$1\"\\t\"\$2\"\\t\"\$3\"\\t\"\$4\"\\t\"\$6\"\\t\"\$7\"\\t\"\$6/(\$6+\$7)}'  $Name.single.cov > $Name.single.m6A.cov " >> m6A_cpg_heatmap.sh

echo -e "awk '{if((\$8+\$9)==0)print \$1\"\\t\"\$2\"\\t\"\$3\"\\t\"\$4\"\\t\"\$8\"\\t\"\$9\"\\t0\" ;else print \$1\"\\t\"\$2\"\\t\"\$3\"\\t\"\$4\"\\t\"\$8\"\\t\"\$9\"\\t\"\$8/(\$8+\$9)}'  $Name.single.cov > $Name.single.cpg.cov " >> m6A_cpg_heatmap.sh

echo -e "Rscript ${script_path}/heatmap_plot_merge_strand_cpg.m6a.r   $Name.single.m6A.cov  $Name.single.cpg.cov $Name.single.pdf " >> m6A_cpg_heatmap.sh
echo -e "$Name\t`pwd`/$Name.single.cov.merge" >> cumulative_sum_merge.list
sh m6A_cpg_heatmap.sh 2> m6A_cpg_heatmap.log

cd -
done
