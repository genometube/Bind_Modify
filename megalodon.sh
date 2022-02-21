
## nanopore fast5 path
fast5="/research/chenweitian/project/2021/cut_modify/data/2021_ctcf_h3k27me/h3k27me/fast5_pass/"

source /mnt/chenweitian/conda/bin/activate py38
megalodon  ${fast5}      --guppy-params "-d /research/chenweitian/project/ecDNA/call_methy/rerio/basecall_models/"     --guppy-config  res_dna_r941_min_modbases-all-context_v001.cfg    --outputs basecalls mappings mod_mappings mods     --reference /research/chenweitian/project/2021/ecDNA/database/hg19.fasta      --devices all:100%  --processes 6 --overwrite  --guppy-server-path /research/chenweitian/project/ecDNA/call_methy/megalodon/ont-guppy/bin/guppy_basecall_server
megalodon_extras  per_read_text modified_bases megalodon_results