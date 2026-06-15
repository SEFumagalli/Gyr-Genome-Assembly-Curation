#created by Sarah E. Fumagalli

## This script is a modified version of Verkko-Fillet (https://github.com/marbl/verkko-fillet/tree/main)
## Verkko-fillet is formatted to run using Jupyter Lab.
## I converted many tools of verkko-fillet to a bash and python scripts. 
## I also created a supportive structure around verkko-fillet to format, save, and create tables, files, and graphics for easier curation efforts. 
## This script calls run_verkko_fillet.sh and translation_merge_table_plot.py.
## Please see README in the verkko-fillet folder for specific steps and modifications to verkko-fillet scripts


#!/bin/bash -l

#SBATCH --job-name=verkko_fillet
#SBATCH --cpus-per-task=8
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=8027
#SBATCH --partition=ceres
#SBATCH --time=2-00:00:00
#SBATCH --qos=agil
#SBATCH --account=cattle_genome_assemblies
#SBATCH --chdir=/90daydata/ruminant_t2t/Gyr/assembly
#SBATCH --output=vf__%j.std
#SBATCH --error=vf__%j.err



#Please see README

date


module load miniconda
source activate verkko-fillet


#create fai file for assembly.rDNA.fasta
rDNA="/90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec/assembly.cattle_rDNA.fasta"
rDNA_fai="${rDNA}.fai"
#echo $rDNA_fai
if [ ! -f "$rDNA_fai" ]; then
        echo "creating index"
        module load seqkit
        seqkit faidx $rDNA
else
        echo "${rDNA} does exist"
fi




#dict='{"0": ["sire_compressed.k31.hapmer-0000251"], "1": ["NC_057420.1_chr_Y"], "2": ["39262963"], "3": ["7618728"]}'

python3 /project/cattle_genome_assemblies/config_files_scripts/verkko-fillet/run_verkko_fillet.py \
	--verkko_directory /90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec/ \
	--main_directory /90daydata/ruminant_t2t/Gyr/assembly/ \
	--rDNA_fasta /90daydata/ruminant_t2t/Gyr/assembly/Cattle_rDNA.fasta \
	--ref_fasta /90daydata/ruminant_t2t/Gyr/assembly/ARS-UCD2.0_chr.fasta \
 	--phase_datatype trio_hic \
        --exp_chr_num 31 \
	--gaps False \
	--mashmap_id_threshold 95 \
	--rDNA_fasta_fai $rDNA_fai
	#--new_row "$dict"	
date



## Flag description (See README for more description)
##--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
## --verkko_directory		directory of verkko assembly run
## --main_directory		directory with all verkko assembly runs
## --rDNA_fasta			reference rDNA fasta file
## --ref_fasta			reference fasta file
## --phase_datatype		type of phasing data used -- hic, trio, or trio_hic
## --exp_chr_num		expected number of chromosomes
## --gaps			signal to verkko-fillet to find gaps (only run this on select assemblies) -- True or False
## --mashmap_id_threshold	alter the mashmap id threshold -- default: 95
## --new_row			see README for more details - add row/s to translation_hap* files via dictionary
##				only needed when rerunning verkko-fillet and altering run_verkko_fillet.py
##---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
