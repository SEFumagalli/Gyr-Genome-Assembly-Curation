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

#This is an overlay launch of the verkko assembly.
#verkko v2.2.1 was used to create the HiFi-Duplex Trio with Pore-C overlay.

date

micromamba activate verkko-v2.2.1

#always touch and then dry-run on verkko before doing a full run
#--snakeopts "--touch"
#--snakeopts "--dry-run"

#Hi-C phasing
verkko --slurm -d verkko2.2.1_hifi-duplex_tporec --snakeopts '-U hicPhasing' \
    --ovb-run 8 32 32 \
    --hifi hifi-duplex/*fastq.gz \
    --nano ont/*fastq.gz> \
    --screen cattle_MT Cattle_Mt.fasta \
    --screen cattle_rDNA Cattle_rDNA.fasta \
    --porec porec/*fastq.gz>

#Final run
verkko --slurm -d verkko2.2.1_hifi-duplex_tporec --ovb-run 8 32 32 \
    --screen cattle_MT Cattle_Mt.fasta \
    --screen cattle_rDNA Cattle_rDNA.fasta \ 
    --hifi hifi-duplex/*fastq.gz \
    --nano ont/*fastq.gz \
    --porec porec/*fastq.gz

