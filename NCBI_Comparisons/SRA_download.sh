#!/bin/bash -l

#created by Sarah E. Fumagalli

#SBATCH --job-name=SRA_download
#SBATCH --cpus-per-task=4
#SBATCH --ntasks=1
#SBATCH --partition=ceres
#SBATCH --account=cattle_genome_assemblies
#SBATCH --qos=agil
#SBATCH --mem=32G
#SBATCH --time=24:00:00
#SBATCH --chdir=/90daydata/ruminant_t2t/Gyr/assembly/ref_assemblies/UOA_Angus_1
#SBATCH --output=SRA_download__%j.std
#SBATCH --error=SRA_download__%j.err


date

# Load required tools

#Activate line in .bashrc 
#export PATH=/project/cattle_genome_assemblies/packages:$PATH

#version 3.2.1
module load sratoolkit

# Set project accession
PROJECT='PRJNA432857'

mkdir -p hifi
cd hifi

echo "Querying ENA for run metadata..."
curl -s \
  "https://www.ebi.ac.uk/ena/portal/api/filereport?accession=PRJNA432857&result=read_run&fields=run_accession,instrument_platform,instrument_model" \
  -o ena_meta.tsv

echo "Extracting PacBio runs..."
PACBIO_RUNS=$(grep -i "PACBI" ena_meta.tsv | cut -f1)

echo "PacBio runs found:"
echo "$PACBIO_RUNS"

for RUN in $PACBIO_RUNS; do

    echo "=== Downloading $RUN ==="
    prefetch $RUN

    echo "=== Converting $RUN to FASTQ ==="
    fasterq-dump --threads 8 --outdir ./ $RUN

    INPUT="${RUN}.fastq"
    OUTPUT="${RUN}.clean.fastq"

    echo "=== Running fastplong on $RUN ==="

    fastplong \
	-i "$INPUT" \
	-o "$OUTPUT" \
	--trim_poly_x \
	--disable_quality_filtering \
	--disable_adapter_trimming \
	--thread 8 \
	--html "${RUN}_fastplong.html" \
	--json "${RUN}_fastplong.json"

done


echo "All PacBio runs downloaded and cleaned."


echo "Concatenating cleaned PACBIO_SMRT FASTQs..."
cat *clean.fastq > "all_cleaned_pacbio.fastq"

pigz -k "all_cleaned_pacbio.fastq"

echo "Done! Merged files"

date
