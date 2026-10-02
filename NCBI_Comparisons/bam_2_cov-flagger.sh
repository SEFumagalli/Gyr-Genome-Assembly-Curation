#!/bin/bash

#SBATCH --job-name=bam2cov-flagger
#SBATCH --error=logs/bam2cov-flagger__%A_%a.err
#SBATCH --output=logs/bam2cov-flagger__%A_%a.std
#SBATCH --time=4-00:00:00
#SBATCH --mem=300G
#SBATCH --cpus-per-task=32
#SBATCH --account=cattle_genome_assemblies
#SBATCH --chdir=/90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec/9-post_assembly_analysis/Flagger
#SBATCH --partition=ceres
#SBATCH --array=1-5

module load apptainer

SIF="/project/cattle_genome_assemblies/packages/flagger_latest.sif"

date

mkdir -p logs

# Array of sample names
samples=(
         "UOA_Brahman_1"
         "NIAB-ARS_B.indTharparkar_mat_pri_1.0"
         "ARS-UCD2.0"
         "UOA_Angus_1"
	 "uncurated2.2.1_hap1_hifi-duplex_ont"
)

# Corresponding BAM file paths
bam_files=(  
            "/90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec/9-post_assembly_analysis/Winnowmap/UOA_Brahman_1/assembly_filtered.bam"
            "/90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec/9-post_assembly_analysis/Winnowmap/NIAB-ARS_B.indTharparkar_mat_pri_1.0/assembly_filtered.bam"
            "/90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec/9-post_assembly_analysis/Winnowmap/ARS-UCD2.0/assembly_filtered.bam"
            "/90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec/9-post_assembly_analysis/Winnowmap/UOA_Angus_1/assembly_filtered.bam" 
	    "/90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec/9-post_assembly_analysis/Winnowmap/uncurated2.2.1_hap1_hifi-duplex_ont/assembly_filtered.bam"
)

# Annotation file paths
anno_files=(
	    "/90daydata/ruminant_t2t/Gyr/assembly/ref_assemblies/UOA_Brahman_1/annotations_path.json"
	    "/90daydata/ruminant_t2t/Gyr/assembly/ref_assemblies/NIAB-ARS_B.indTharparkar_mat_pri_1.0/annotations_path.json"
	    "/90daydata/ruminant_t2t/Gyr/assembly/ref_assemblies/ARS-UCD2.0/annotations_path.json"
	    "/90daydata/ruminant_t2t/Gyr/assembly/ref_assemblies/UOA_Angus_1/annotations_path.json"
	    "/90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec/9-post_assembly_analysis/uncurated2.2.1/hap1/annotations_path.json"
)

# Pick correct sample for this SLURM_ARRAY_TASK_ID
sample="${samples[$SLURM_ARRAY_TASK_ID - 1]}"
bam="${bam_files[$SLURM_ARRAY_TASK_ID - 1]}"
anno="${anno_files[$SLURM_ARRAY_TASK_ID - 1]}"

echo "Running sample: $sample"
echo "Using BAM: $bam"
echo "Using Annotation: $anno"


# Output directory
mkdir -p ${sample}
cd ${sample}

# Run bam2cov
apptainer exec "$SIF" \
    bam2cov \
    --bam "$bam" \
    --output coverage_file.cov.gz \
    --annotationJson "$anno" \
    --threads $SLURM_CPUS_PER_TASK \
    --baselineAnnotation assembly

mkdir hmm_flagger_outputs

# Run Flagger
apptainer exec "$SIF" \
    hmm_flagger \
    --input coverage_file.cov.gz \
    --outputDir hmm_flagger_outputs  \
    --labelNames Err,Dup,Hap,Col \
    --threads $SLURM_CPUS_PER_TASK

cd ..

date
