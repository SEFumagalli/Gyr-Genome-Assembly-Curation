#!/bin/bash -l

#SBATCH --job-name=verkko2.2.1
#SBATCH --cpus-per-task=2
#SBATCH --ntasks=1
#SBATCH --mem 50G
#SBATCH --partition=ceres
#SBATCH --time=2-00:00:00
#SBATCH --parsable
#SBATCH --chdir=/project/ruminant_t2t/Gyr
#SBATCH --output=Gyr_verkko2.2.1.out
#SBATCH --error=Gyr_verkko2.2.1.err

#This is a general launch of the verkko assembly.
#verkko v2.2 and v2.2.1 were used to create the assemblies.

date

micromamba activate verkko-v2.2.1

#always touch and then dry-run on verkko before doing a full run
#--snakeopts "--touch"
#--snakeopts "--dry-run"

verkko --slurm -d <assembly_directory_name> --red-run 8 40 8 --unitig-abundance 4 \
    --hifi <long_read_fastq.gz> \
    --nano <ultra_long_read_fastq.gz> \
    --screen <file_name> <reference_mito_fasta> \
    --screen <file_name> <reference_rDNA_fasta> \
    --porec/hic/hapmers <phasing_read_fastq.gz>

