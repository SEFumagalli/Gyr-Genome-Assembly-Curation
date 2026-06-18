#!/bin/bash -l

# created by Sarah E. Fumagalli

#SBATCH --job-name=grab_read_stats
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=10000
#SBATCH --partition=ceres
#SBATCH --time=1-00:00:00
#SBATCH --chdir=/assembly
#SBATCH --output=grab_read_stats__%j.std
#SBATCH --error=grab_read_stats__%j.err



## This script calculates the general and >100kb assembly stats



#file paths and names for general stats (list all data types)
all_read_paths=("hifi/*.fastq.gz" "illumina_data/dam/*.fastq.gz" "illumina_data/sire/*.fastq.gz" "hifi-duplex/*.fastq.gz" "herro/*.fastq.gz" "hifi-herro/*.fastq.gz" "porec/*.fastq.gz" "omnic/*.fastq.gz" "hifi-36x/*.fastq.gz" "duplex/*.fastq.gz" "ont/*.fastq.gz")
all_reads=("hifi/hifi.stats" "illumina_data/dam/dam.stats" "illumina_data/sire/sire.stats" "hifi-duplex/hifi-duplex.stats" "herro/herro.stats" "hifi-herro/hifi-herro.stats" "porec/porec.stats" "omnic/omnic.stats" "hifi-36x/hifi-36x.stats" "duplex/duplex.stats" "ont/ont.stats")
all_read_names=('HiFi' 'Trio Dam' 'Trio Sire' 'HiFi-Duplex' 'Herro' 'HiFi-Herro' 'Pore-C' 'Omni-C' 'HiFi-36x' 'Duplex' 'ONT')

#file paths and names for >100kb stats (list only appropriate data types)
select_read_paths=("hifi-duplex/*.fastq.gz" "herro/*.fastq.gz" "hifi-herro/*.fastq.gz" "porec/*.fastq.gz" "duplex/*.fastq.gz" "ont/*.fastq.gz")
select_reads=("hifi-duplex/hifi-duplex.100kb.stats" "herro/herro.100kb.stats" "hifi-herro/hifi-herro.100kb.stats" "porec/porec.100kb.stats" "duplex/duplex.100kb.stats" "ont/ont.100kb.stats")
select_read_names=('HiFi-Duplex' 'Herro' 'HiFi-Herro' 'Pore-C' 'Duplex' 'ONT')

#name of the final file
read_stats_tsv="Gyr_read_stats.tsv"

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
        python3 calcReadsOver100kb.py <(zcat ${select_read_paths[$i]}) > ${select_reads[$i]}

done



echo 'grab stats'
micromamba activate pyfigures

python3 merged_read_stats.py \
	--all_reads "${all_reads[@]}" \
	--select_reads "${select_reads[@]}" \
	--all_reads_filenames "${all_read_names[@]}" \
	--select_reads_filenames "${select_read_names[@]}" \
	--read_stats_tsv $read_stats_tsv

#--bargraph read_stats

date
