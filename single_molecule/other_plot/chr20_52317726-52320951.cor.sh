echo -e "chr_name	bin_start	bin_end	read_name	m6A_methy_count	m6A_unmethy_count	methy_ratio	type" > chr20_52317726-52320951.region_all.cov
awk '{print $0"	CpG"}'  /zfswh1/BC_RD_P0/P19Z12200N0089/2021/cut_modify/review/panel3_cpg/chr20_52317726-52320951/chr20_52317726-52320951.single.cpg.cov  >> chr20_52317726-52320951.region_all.cov
awk '{print $0"	m6A"}'  /zfswh1/BC_RD_P0/P19Z12200N0089/2021/cut_modify/review/panel3_cpg/chr20_52317726-52320951/chr20_52317726-52320951.single.m6A.cov >> chr20_52317726-52320951.region_all.cov 
/ifswh1/BC_PUB/biosoft/pipeline/RNA/10x/Seurat_V3.0/software/Rscript /zfswh1/BC_RD_P0/P19Z12200N0089/2021/cut_modify/review/panel3_cpg/single_molecule_m6a_cpg_cor.r  chr20_52317726-52320951.region_all.cov chr20_52317726-52320951
