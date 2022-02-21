
##########################################################################
#########                   Set up the environment            ############
##########################################################################

#TSS="/zfswh1/BC_RD_P0/P19Z12200N0089/database/refdata-cellranger-atac-mm10-1.2.0/regions/ctcf.bed2"

peak="H3K27me3_rep2_peaks.narrowPeak"
bw_list="bw.list"

##########################################################################
#########                   batch run                         ############
##########################################################################

cat ${bw_list} |while read line; do 
name=`echo $line|awk '{print $1}'`; bw=`echo $line|awk '{print $2}'`; 

echo -e "source /ifswh1/BC_RD/RD_COM/USER/chenweitian/software/python/bin/activate py38" > deep.$name.metaplot.sh

echo -e "computeMatrix reference-point  --referencePoint center  -p 6  -b 500 -a 500   -R  ${TSS} -S $bw --skipZeros  -o ${name}_peak_center.gz  --outFileSortedRegions $name.genes.ratio_cebter.bed "  >> deep.$name.metaplot.sh

echo -e "plotHeatmap -m  ${name}_peak_center.gz -out  ${name}_peak_center.pdf --plotTitle \"$name \" " >> deep.$name.metaplot.sh

sh deep.$name.metaplot.sh 
done
