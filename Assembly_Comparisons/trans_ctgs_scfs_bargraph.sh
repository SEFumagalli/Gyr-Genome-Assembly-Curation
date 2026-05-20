#created by Sarah E. Fumagalli

## This script produces three bar graphs - haplotype 1, haplotype 2, and total assembly - with the counts of T2T contigs and scaffolds

#!/bin/bash -l

#SBATCH --job-name=trans_ctgs_scfs_bargraph
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=3500
#SBATCH --partition=medium
#SBATCH --qos=agil
#SBATCH --chdir=/90daydata/ruminant_t2t/Gyr/assembly
#SBATCH --output=trans_ctgs_scfs_bargraph__%j.std
#SBATCH --error=trans_ctgs_scfs_bargraph__%j.err



## ----------------------------------------------------------------------------------------------
## This script grabs the translation, T2T contigs, and T2T scaffold files for each assembly. 
##
## Inputs for each assembly: translation_hap1
## 	   		     translation_hap2
## 	   		     assembly.t2t_ctgs
## 	   		     assembly.t2t_scfs 
##
## Easily add or subtract the number of assemblies by adding or removing the number of lists
## and filenames (sh file), and arguments and file list (py file).
##
## Output: bargraph png
## ----------------------------------------------------------------------------------------------



date

micromamba activate pyfigures

python3 trans_ctgs_scfs_bargraph.py \
	--lista verkko2.2_hifi_hic/translation_hap1 verkko2.2_hifi_hic/translation_hap2 verkko2.2_hifi_hic/assembly.t2t_ctgs verkko2.2_hifi_hic/assembly.t2t_scfs \
	--listb verkko2.2_hifi_porec/translation_hap1 verkko2.2_hifi_porec/translation_hap2 verkko2.2_hifi_porec/assembly.t2t_ctgs verkko2.2_hifi_porec/assembly.t2t_scfs \
	--listc verkko2.2.1_hifi_trio/translation_hap1 verkko2.2.1_hifi_trio/translation_hap2 verkko2.2.1_hifi_trio/assembly.t2t_ctgs verkko2.2.1_hifi_trio/assembly.t2t_scfs \
	--listd verkko2.2_hifi-duplex_hic/translation_hap1 verkko2.2_hifi-duplex_hic/translation_hap2 verkko2.2_hifi-duplex_hic/assembly.t2t_ctgs verkko2.2_hifi-duplex_hic/assembly.t2t_scfs \
	--liste verkko2.2_hifi-duplex_porec/translation_hap1 verkko2.2_hifi-duplex_porec/translation_hap2 verkko2.2_hifi-duplex_porec/assembly.t2t_ctgs verkko2.2_hifi-duplex_porec/assembly.t2t_scfs \
	--listf verkko2.2.1_hifi-duplex_trio/translation_hap1 verkko2.2.1_hifi-duplex_trio/translation_hap2 verkko2.2.1_hifi-duplex_trio/assembly.t2t_ctgs verkko2.2.1_hifi-duplex_trio/assembly.t2t_scfs \
	--listg verkko2.2.1_hifi-duplex_tporec/translation_hap1 verkko2.2.1_hifi-duplex_tporec/translation_hap2 verkko2.2.1_hifi-duplex_tporec/assembly.t2t_ctgs verkko2.2.1_hifi-duplex_tporec/assembly.t2t_scfs \
	--listh verkko2.2_duplex_hic/translation_hap1 verkko2.2_duplex_hic/translation_hap2 verkko2.2_duplex_hic/assembly.t2t_ctgs verkko2.2_duplex_hic/assembly.t2t_scfs \
	--listi verkko2.2.1_duplex_porec/translation_hap1 verkko2.2.1_duplex_porec/translation_hap2 verkko2.2.1_duplex_porec/assembly.t2t_ctgs verkko2.2.1_duplex_porec/assembly.t2t_scfs \
	--listj verkko2.2.1_duplex_trio/translation_hap1 verkko2.2.1_duplex_trio/translation_hap2 verkko2.2.1_duplex_trio/assembly.t2t_ctgs verkko2.2.1_duplex_trio/assembly.t2t_scfs \
	--listk verkko2.2.1_hifi-herro_hic/translation_hap1 verkko2.2.1_hifi-herro_hic/translation_hap2 verkko2.2.1_hifi-herro_hic/assembly.t2t_ctgs verkko2.2.1_hifi-herro_hic/assembly.t2t_scfs \
	--listl verkko2.2.1_hifi-herro_porec/translation_hap1 verkko2.2.1_hifi-herro_porec/translation_hap2 verkko2.2.1_hifi-herro_porec/assembly.t2t_ctgs verkko2.2.1_hifi-herro_porec/assembly.t2t_scfs \
	--listm verkko2.2.1_hifi-herro_trio/translation_hap1 verkko2.2.1_hifi-herro_trio/translation_hap2 verkko2.2.1_hifi-herro_trio/assembly.t2t_ctgs verkko2.2.1_hifi-herro_trio/assembly.t2t_scfs \
	--listn verkko2.2.1_herro_hic/translation_hap1 verkko2.2.1_herro_hic/translation_hap2 verkko2.2.1_herro_hic/assembly.t2t_ctgs verkko2.2.1_herro_hic/assembly.t2t_scfs \
	--listo verkko2.2.1_herro_porec/translation_hap1 verkko2.2.1_herro_porec/translation_hap2 verkko2.2.1_herro_porec/assembly.t2t_ctgs verkko2.2.1_herro_porec/assembly.t2t_scfs \
	--listp verkko2.2.1_herro_trio/translation_hap1 verkko2.2.1_herro_trio/translation_hap2 verkko2.2.1_herro_trio/assembly.t2t_ctgs verkko2.2.1_herro_trio/assembly.t2t_scfs \
	--listq verkko2.2.1_hifi-q36_hic/translation_hap1 verkko2.2.1_hifi-q36_hic/translation_hap2 verkko2.2.1_hifi-q36_hic/assembly.t2t_ctgs verkko2.2.1_hifi-q36_hic/assembly.t2t_scfs \
	--listr verkko2.2.1_hifi-q36_porec/translation_hap1 verkko2.2.1_hifi-q36_porec/translation_hap2 verkko2.2.1_hifi-q36_porec/assembly.t2t_ctgs verkko2.2.1_hifi-q36_porec/assembly.t2t_scfs \
 	--lists	verkko2.2.1_hifi-q36_trio/translation_hap1 verkko2.2.1_hifi-q36_trio/translation_hap2 verkko2.2.1_hifi-q36_trio/assembly.t2t_ctgs verkko2.2.1_hifi-q36_trio/assembly.t2t_scfs \
        --filenames 'HiFi Omni-C' 'HiFi Pore-C' 'HiFi Trio' 'HiFi-Duplex Omni-C' 'HiFi-Duplex Pore-C' 'HiFi-Duplex Trio' 'HiFi-Duplex TPore-C' 'Duplex Omni-C' 'Duplex Pore-C' 'Duplex Trio' 'HiFi-Herro Omni-C' 'HiFi-Herro Pore-C' 'HiFi-Herro Trio' 'Herro Omni-C' 'Herro Pore-C' 'Herro Trio' 'HiFi-q36 Omni-C' 'HiFi-q36 Pore-C' 'HiFi-q36 Trio'\
	--bargraph Gyr_assembly_chromo_scfs_ctgs_bargraph

date
