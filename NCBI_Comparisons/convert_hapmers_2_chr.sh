#!/bin/bash -l

#created by Sarah E. Fumagalli

#SBATCH --job-name=hapmer_2_chr
#SBATCH --cpus-per-task=4
#SBATCH --ntasks=1
#SBATCH --partition=ceres
#SBATCH --account=cattle_genome_assemblies
#SBATCH --qos=agil
#SBATCH --mem-per-cpu=500
#SBATCH --time=1:00:00
#SBATCH --chdir=/90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec/9-post_assembly_analysis
#SBATCH --output=hapmer_2_chr__%j.std
#SBATCH --error=hapmer_2_chr__%j.err



date

#make translation file from verkko-fillet translation_merged.tsv
cut -f1,2 ../../verkko2.2.1_hifi-duplex_tporec_verkko_fillet/chromosome_assignment/translation_merged.tsv > hapmer_chr.tsv


#remove rows that are associated with empty second column and the header row
awk 'NR > 1 && NF >= 2 && $2 != ""' hapmer_chr.tsv > hapmer_chr_cleaned.tsv



#concatenate chromosome name to hapmer names listed in assembly.fasta
awk 'NR==FNR { map[$1]=$2; next }
     /^>/ {
         name = substr($0, 2)          # remove ">"
         if (name in map)
             print ">" name "_" map[name]
         else
             print $0
         next
     }
     { print }' hapmer_chr_cleaned.tsv assembly.fasta > assembly_chr.fasta


#create new index file
module load seqkit
seqkit faidx assembly_chr.fasta




date
