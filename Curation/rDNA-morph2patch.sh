#!/bin/bash -l

#SBATCH --job-name=morph2patch
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=3500
#SBATCH --partition=ceres
#SBATCH --qos=agil
#SBATCH --account=cattle_genome_assemblies
#SBATCH --time=1-00:00:00
#SBATCH --chdir=/90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec/8-manualResolution/verkko2.2.1_hifi-duplex_tporec_patch/rDNA-patches
#SBATCH --output=morph2patch__%j.std
#SBATCH --error=morph2patch__%j.err


date

echo "Chr 11 Hap1 Tangle 1"
python3 /project/cattle_genome_assemblies/config_files_scripts/Sarah_scripts/rDNA-morph2patch.py chr11.hap1.consensus.fa chr11.hap1.patch.fa 137

echo "Chr 11 Hap2 Tangle 0"
python3 /project/cattle_genome_assemblies/config_files_scripts/Sarah_scripts/rDNA-morph2patch.py chr11.hap2.consensus.fa chr11.hap2.patch.fa 123

echo "Chr 3 Hap1 Tangle 2"
python3 /project/cattle_genome_assemblies/config_files_scripts/Sarah_scripts/rDNA-morph2patch.py chr3.hap1.consensus.fa chr3.hap1.patch.fa 138

echo "Chr 3 Hap2 Tangle 3"
python3 /project/cattle_genome_assemblies/config_files_scripts/Sarah_scripts/rDNA-morph2patch.py chr3.hap2.consensus.fa chr3.hap2.patch.fa 142

echo "Chr 2 Hap2 Tangle 4"
python3 /project/cattle_genome_assemblies/config_files_scripts/Sarah_scripts/rDNA-morph2patch.py chr2.hap2.consensus.fa chr2.hap2.patch.fa 129

echo "Chr 25 Hap1_2 Tangle 5"
python3 /project/cattle_genome_assemblies/config_files_scripts/Sarah_scripts/rDNA-morph2patch.py chr25.hap1_2.consensus.fa chr25.hap1_2.patch.fa 139

echo "Chr 2 Hap1 Tangle 6"
python3 /project/cattle_genome_assemblies/config_files_scripts/Sarah_scripts/rDNA-morph2patch.py chr2.hap1.consensus.fa chr2.hap1.patch.fa 137



date
