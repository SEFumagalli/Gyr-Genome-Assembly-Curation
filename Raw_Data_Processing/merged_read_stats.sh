#!/bin/bash -l

#SBATCH --job-name=grab_read_stats
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=10000
#SBATCH --partition=ceres
#SBATCH --qos=agil
#SBATCH --account=cattle_genome_assemblies
#SBATCH --time=1-00:00:00
#SBATCH --chdir=/90daydata/ruminant_t2t/Wagyu_x_Charolais/assembly
#SBATCH --output=grab_read_stats__%j.std
#SBATCH --error=grab_read_stats__%j.err



## This script calculates the general and >100kb assembly stats



#file paths and names for general stats (list all data types)
all_read_paths=("20k_hifi/*.fastq.gz" "illumina_data/dam/*.fastq.gz" "illumina_data/sire/*.fastq.gz" "20k_hifi-duplex/*.fastq.gz")
all_reads=("20k_hifi/20k_hifi.stats" "illumina_data/dam/dam.stats" "illumina_data/sire/sire.stats" "20k_hifi-duplex/20k_hifi-duplex.stats")
all_read_names=('20k HiFi' 'Trio Dam' 'Trio Sire' '20k HiFi-Duplex')

#file paths and names for >100kb stats (list only appropriate data types)
select_read_paths=("20k_hifi-duplex/*.fastq.gz")
select_reads=("20k_hifi-duplex/20k_hifi-duplex.100kb.stats")
select_read_names=('20k HiFi-Duplex')

#name of the final file
read_stats_tsv="Wagyu_x_Charolais_read_stats.tsv"






date


#Assessing all reads
module load seqkit 
for i in $(seq 0 $((${#all_read_paths[@]} - 1)));do
	echo "Index: $i, Path: ${all_read_paths[$i]}, File_name: ${all_reads[$i]}"
	seqkit stats <(zcat ${all_read_paths[$i]}) -a -T -o ${all_reads[$i]}

done


#Assessing reads >= 100kb
for i in $(seq 0 $((${#select_read_paths[@]} - 1)));do
        echo "Index: $i, Path: ${select_read_paths[$i]}, File_name: ${select_reads[$i]}"
        python3 /project/cattle_genome_assemblies/config_files_scripts/Sarah_scripts/calcReadsOver100kb.py <(zcat ${select_read_paths[$i]}) > ${select_reads[$i]}

done



echo 'grab stats'
micromamba activate pyfigures

python3 /project/cattle_genome_assemblies/config_files_scripts/Sarah_scripts/merged_read_stats.py \
	--all_reads "${all_reads[@]}" \
	--select_reads "${select_reads[@]}" \
	--all_reads_filenames "${all_read_names[@]}" \
	--select_reads_filenames "${select_read_names[@]}" \
	--read_stats_tsv $read_stats_tsv

#--bargraph Pronghorn_read_stats

date
