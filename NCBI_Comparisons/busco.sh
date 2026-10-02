#!/bin/bash

#created by Sarah E. Fumagalli

#SBATCH --job-name=busco
#SBATCH --cpus-per-task=72
#SBATCH --ntasks=1
#SBATCH --partition=ceres
#SBATCH --account=cattle_genome_assemblies
#SBATCH --qos=agil
#SBATCH --mem-per-cpu=5277
#SBATCH --time=2-00:00:00
#SBATCH --chdir=/90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec/9-post_assembly_analysis/busco
#SBATCH --output=busco__%j.std
#SBATCH --error=busco__%j.err


date

#activate conda in .bashrc and deactivate micromamba

source ~/.bashrc
conda activate busco

#busco -i /ref_assemblies/ARS-UCD2.0/ARS-UCD2.0_chr.fasta -o ARS-UCD2.0 -l cetartiodactyla_odb10 -m geno -c 72

#busco -i /ref_assemblies/NIAB-ARS_B.indTharparkar_mat_pri_1.0/GCF_029378745.1_NIAB-ARS_B.indTharparkar_mat_pri_1.0_genomic.chr.fna -o NIAB-ARS_B.indTharparkar_mat_pri_1.0 -l cetartiodactyla_odb10 -m geno -c 72

#busco -i /ref_assemblies/UOA_Angus_1/GCA_003369685.2_UOA_Angus_1_genomic.chr.fna -o UOA_Angus_1 -l cetartiodactyla_odb10 -m geno -c 72

#busco -i /ref_assemblies/UOA_Brahman_1/GCF_003369695.1_UOA_Brahman_1_genomic.chr.fna -o UOA_Brahman_1 -l cetartiodactyla_odb10 -m geno -c 72


date
