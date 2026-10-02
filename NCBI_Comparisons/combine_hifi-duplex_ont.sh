#!/bin/bash -l

#SBATCH --job-name=combine_hifi-duplex_ont
#SBATCH --cpus-per-task=250
#SBATCH --ntasks=1
#SBATCH --partition=ceres
#SBATCH --account=cattle_genome_assemblies
#SBATCH --qos=agil
#SBATCH --mem-per-cpu=3968
#SBATCH --time=5-00:00:00
#SBATCH --chdir=/90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec/9-post_assembly_analysis/Winnowmap
#SBATCH --output=logs/combine_hifi-duplex_ont__%A_%a.std
#SBATCH --error=logs/combine_hifi-duplex_ont__%A_%a.err

date

module load samtools

#mkdir -p logs

echo "Create and enter directory"
mkdir -p uncurated2.2.1_hap1_hifi-duplex_ont
cd uncurated2.2.1_hap1_hifi-duplex_ont

echo "Join HiFi-Duplex and ONT" 
samtools merge -o assembly.bam ../uncurated2.2.1_hap1_ont/assembly_filtered.bam ../uncurated2.2.1_hap1_hifi-duplex/assembly_filtered.bam

echo "Resort and index"
samtools sort -@ 250 -o assembly.sorted.bam assembly.bam
samtools index assembly.sorted.bam

echo "update name"
mv assembly.sorted.bam assembly_filtered.bam
mv assembly.sorted.bam.bai assembly_filtered.bam.bai

date
