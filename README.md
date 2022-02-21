# Bind Modify


`The input and script paths are absolute paths, and if you want to use these scripts you must edit shell script and replace the absolute paths with your data paths`



### 1. call methylation and base calling

- The basecall_models from Reiro was used in this project, which can be downloaded by cloning from GitHub git clone `https://github.com/nanoporetech/rerio`. Once Rerio has been downloaded, models can be downloaded via the download_model.py script.

- Other parameters refer to the nanopore Megalodon manuscript `https://nanoporetech.github.io/megalodon/`

methylation calling and base calling example:

```shell
sh megalodon.sh 2>megalodon.log &
```

### 2. extract single molecule 

input file:

![Image text](/img/megalodon_result.png)

The single-molecule files are sorted by chromosome, genome location, and then the chromosomes are splited to run the program with relatively low memory.

The output file is the genome location, strand, location and propobility  of each single molecule read

|  chr name   | single molecule mod start site  |single molecule mod end site| strand| read name|.|location |propobility|
|  ----  | ----  |  ----  | ----  |----  | ----  |  ----  | ----  |
|  chr7   | 128511956  |  128518458  | +  |b'000008ed-1049-4c98-b010-5584eed60b1f' | .  |  location   | propobility  |


run example:

```shell
# megalodon result to single reads tsv file
sh mega2tsv.sh 2> mega2tsv.log 
```

### 3.fill read , very slow (optional)

example:

```
python  methylation-reads-tsv-to_coverage.py chr7.mega.sort.csv.m6A.tsv  0.5 chr7.m6A.csv.w10_a10_b10 -minAbsPValue 0.4 -BayesianIntegration 10 1 10 10 50  -saveNewSingleMoleculeFile chr7.m6A.csv.BI_w10_a10_b10.reads.tsv

```

Refer to  `Shipony Z, Marinov G K, Swaffer M P, et al. Long-range single-molecule mapping of chromatin accessibility in eukaryotes[J]. Nature methods, 2020, 17(3): 319-327.`


### 4.split single molecule read to bin 

Extract chromosome length file

```
samtools  faidx  hg19.fa > hg19.txt
```

split genome to windows bed

```
bedtools makewindows -g hg19.txt -w 50 -s 50
```

generate tables of m6A, CpG GpC for each single molecule in a specific bin length.


example:

```
sh windows2bin.sh chr7.mega.sort.csv.m6A.tsv chr7.mega.sort.csv.5mC.tsv
```

output file:

**merge_strand.cov**


|chr_name|bin_start|bin_end|read_name|strand|m6A_methy|m6A_unmethy|CpG_methy|CpG_unmethy|GpC_methy|GpC_unmethy|
|  ----  | ----  |  ----  | ----  |----  | ----  |  ----  | ----  | ----  |----  | ----  |


![Image text](/img/bin_example_strand.png)

**merge_all.cov**(merge strand and single read)

|chr_name|bin_start|bin_end|m6A_methy|m6A_unmethy|CpG_methy|CpG_unmethy|GpC_methy|GpC_unmethy|
|  ----  | ----  |  ----  | ----  |----  | ----  |  ----  | ----  | ----  |


![Image text](/img/bin_example_all.png)

**wig file**

![Image text](/img/wig_example.png)

### 5. meta/TSS/peak center/motif center ... plot 

**dependence**

download wigToBigWig and install deeptools first

- `wigToBigWig` download from UCSC `http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64.v369/`

- `deeptools` download from ` https://deeptools.readthedocs.io/en/develop/`

**wig to bigWig**

```wigToBigWig m6A_ratio.wig hg19.txt m6A_ratio.bigWig```

input:

- m6A_*.bigWig (count/ratio)
- *.bed (Chip-Seq/Cut & Tag peak/TSS bed/CTCF/...)

![Image text](/img/bw_input_list.png)

example:

```
sh metaplot.sh 2> metaplot.log
```

### 6. single molecule heatmap

**dependence**

- tabix 
- bgzip
- reshape2 (R package) 
- pheatmap (R package)
- dplyr (R package)
- data.table (R package)
- ComplexHeatmap (R package)

**index merge_strand.cov file**

```sh index.sh merge_strand.cov```


input:

`merge_strand.cov.bgz` input cov file extract from merge.cov

The BED file for the area of interest


interest_region.bed :

![Image text](/img/interest_region.png)


```
sh single_molecule_heatmap.sh

```


### 7.coa 

gene element annotation download from 10x genome database

```
 wget -c "http://cf.10xgenomics.com/supp/cell-atac/refdata-cellranger-atac-hg19-1.2.0.tar.gz" .
```

gene annotation file download from UCSC table browser

input file: gene_element_region.bed

![Image text](/img/interest_region_element_anno.png)


run example:

```
sh single_molecule_coa.sh 2>single_molecule_coa.log
```
