#cut_modify流程

##### 数据路径
## megalodon output dir
data_path="megalodon_results"

run_path="bindModify/analysis"

script_path="Bind_Modify/mega2tsv/"

##### 1.split chr
mkdir -p ${run_path}/split_mega
cd ${run_path}/split_mega/
python ${script_path}/split_mega.py --per_read_modified_base ${data_path}/per_read_modified_base_calls.txt  > split_mega.log


cd ..
split_mega_path="${run_path}/split_mega/"

##### 2.sort
#Each CHR is treated separately
chr_name="/research/chenweitian/project/202108/megalodon/20220127_hela_bindModify/chr.name"
##head -1 ${chr_name}
##chr7
mkdir -p ${run_path}/sort_tmp
cd ${run_path}/sort_tmp

for i in `cat ${chr_name}`
do
mkdir -p ${run_path}/sort_tmp/sort_tmp_${i} 
echo "sort -k1,1 -k4,4n  ${split_mega_path}/$i.mega.csv -S 20G -T ${run_path}/sort_tmp/sort_tmp_${i} > $i.mega.sort.csv 2>sort.log" > $i.sh
echo "rm -r  sort_tmp_${i}" >>$i.sh
sh $i.sh 2> $i.sort.log
done

 
cd ..
sort_mega_path="${run_path}/sort_tmp"
> split2single.list
## 3.extract
mkdir -p ${run_path}/extract
cd ${run_path}/extract
for i in `ls ${sort_mega_path}/chr*mega.sort.csv`; do 
name=`basename $i`
echo -e "python  ${script_path}/extract.linear.py  --per_read_modified_base $i " > single.$name.sh
echo -e "$name\t${sort_mega_path}/$name.m6A.tsv,${sort_mega_path}/$name.5mC.tsv\t`pwd`/single.$name.sh" >> split2single.list
sh single.$name.sh 2> single.$name.log
done
