#!/bin/bash -l

#SBATCH --job-name=grab_stats
#SBATCH --cpus-per-task=2
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=short
#SBATCH --qos=agil
#SBATCH --chdir=/90daydata/ruminant_t2t/Gyr/assembly/
#SBATCH --output=grab_stats__%j.std
#SBATCH --error=grab_stats__%j.err



## -----------------------------------------------------------------------
## This script collects each assembly's haplotype stats and combines
## them in a single csv.
##
## Requirement: seqkit stat files created for each assembly
##
## Input for each assembly: haplotype1_stats.txt
##                          haplotype2_stats.txt
##
## Easily add or subtract the number of assemblies by adding or 
## removing the number of lists and filenames (sh file), and 
## arguments and file list (py file).
##
## Output: seqkit_stats.csv
##         seqkit_stats_barplot.png
## -----------------------------------------------------------------------


date

#run seqkit stats on all assemblies
#module load seqkit
#seqkit stats *.f{a,q}.gz -a -T -o file.txt

micromamba activate pyfigures

python3 grab_stats.py \
	--lista verkko2.2_hifi_hic/assembly_haplotype1_stats.txt verkko2.2_hifi_hic/assembly_haplotype2_stats.txt \
	--listb verkko2.2_hifi_porec/assembly_haplotype1_stats.txt verkko2.2_hifi_porec/assembly_haplotype2_stats.txt \
	--listc verkko2.2.1_hifi_trio/assembly_haplotype1_stats.txt verkko2.2.1_hifi_trio/assembly_haplotype2_stats.txt \
	--listd verkko2.2_hifi-duplex_hic/assembly_haplotype1_stats.txt verkko2.2_hifi-duplex_hic/assembly_haplotype2_stats.txt \
	--liste verkko2.2_hifi-duplex_porec/assembly_haplotype1_stats.txt verkko2.2_hifi-duplex_porec/assembly_haplotype2_stats.txt \
	--listf verkko2.2.1_hifi-duplex_trio/assembly_haplotype1_stats.txt verkko2.2.1_hifi-duplex_trio/assembly_haplotype2_stats.txt \
	--listg verkko2.2.1_hifi-duplex_tporec/assembly_haplotype1_stats.txt verkko2.2.1_hifi-duplex_tporec/assembly_haplotype2_stats.txt \
	--listh verkko2.2_duplex_hic/assembly_haplotype1_stats.txt verkko2.2_duplex_hic/assembly_haplotype2_stats.txt \
	--listi verkko2.2.1_duplex_porec/assembly_haplotype1_stats.txt verkko2.2.1_duplex_porec/assembly_haplotype2_stats.txt \
	--listj verkko2.2.1_duplex_trio/assembly_haplotype1_stats.txt verkko2.2.1_duplex_trio/assembly_haplotype2_stats.txt \
	--listk verkko2.2.1_hifi-herro_hic/assembly_haplotype1_stats.txt verkko2.2.1_hifi-herro_hic/assembly_haplotype2_stats.txt \
	--listl verkko2.2.1_hifi-herro_porec/assembly_haplotype1_stats.txt verkko2.2.1_hifi-herro_porec/assembly_haplotype2_stats.txt \
	--listm verkko2.2.1_hifi-herro_trio/assembly_haplotype1_stats.txt verkko2.2.1_hifi-herro_trio/assembly_haplotype2_stats.txt \
	--listn verkko2.2.1_herro_hic/assembly_haplotype1_stats.txt verkko2.2.1_herro_hic/assembly_haplotype2_stats.txt \
	--listo verkko2.2.1_herro_porec/assembly_haplotype1_stats.txt verkko2.2.1_herro_porec/assembly_haplotype2_stats.txt \
	--listp verkko2.2.1_herro_trio/assembly_haplotype1_stats.txt verkko2.2.1_herro_trio/assembly_haplotype2_stats.txt \
	--listq	 verkko2.2.1_hifi-q36_hic/assembly_haplotype1_stats.txt verkko2.2.1_hifi-q36_hic/assembly_haplotype2_stats.txt \
	--listr verkko2.2.1_hifi-q36_porec/assembly_haplotype1_stats.txt verkko2.2.1_hifi-q36_porec/assembly_haplotype2_stats.txt \
	--lists verkko2.2.1_hifi-q36_trio/assembly_haplotype1_stats.txt verkko2.2.1_hifi-q36_trio/assembly_haplotype2_stats.txt \
	--filenames 'HiFi Omni-C Hap1' 'HiFi Omni-C Hap2' 'HiFi Pore-C Hap1' 'HiFi Pore-C Hap2' 'HiFi Trio Hap1' 'HiFi Trio Hap2' 'HiFi-Duplex Omni-C Hap1' 'HiFi-Duplex Omni-C Hap2' 'HiFi-Duplex Pore-C Hap1' 'HiFi-Duplex Pore-C Hap2' 'HiFi-Duplex Trio Hap1' 'HiFi-Duplex Trio Hap2' 'HiFi-Duplex TPore-C Hap1' 'HiFi-Duplex TPore-C Hap2' 'Duplex Omni-C Hap1' 'Duplex Omni-C Hap2' 'Duplex Pore-C Hap1' 'Duplex Pore-C Hap2' 'Duplex Trio Hap1' 'Duplex Trio Hap2' 'HiFi-Herro Omni-C Hap1' 'HiFi-Herro Omni-C Hap2' 'HiFi-Herro Pore-C Hap1' 'HiFi-Herro Pore-C Hap2' 'HiFi-Herro Trio Hap1' 'HiFi-Herro Trio Hap2' 'Herro Omni-C Hap1' 'Herro Omni-C Hap2' 'Herro Pore-C Hap1' 'Herro Pore-C Hap2' 'Herro Trio Hap1' 'Herro Trio Hap2' 'HiFi-q36 Omni-C Hap1' 'HiFi-q36 Omni-C Hap2' 'HiFi-q36 Pore-C Hap1' 'HiFi-q36 Pore-C Hap2' 'HiFi-q36 Trio Hap1' 'HiFi-q36 Trio Hap2' \
        --csvname Gyr_haplotype_seqkit_stats \
	--graphname Gyr_haplotype_seqkit_stats_barplot


date
