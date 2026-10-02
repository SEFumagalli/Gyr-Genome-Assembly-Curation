#!/bin/bash -l

#SBATCH --job-name=nucflag
#SBATCH --cpus-per-task=96
#SBATCH --ntasks=1
#SBATCH --mem=512G
#SBATCH --partition=ceres
#SBATCH --qos=agil
#SBATCH --account=cattle_genome_assemblies
#SBATCH --time=1-00:00:00
#SBATCH --chdir=/90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec/9-post_assembly_analysis/nucflag
#SBATCH --output=logs/nucflag__%A_%a.std
#SBATCH --error=logs/nucflag__%A_%a.err
#SBATCH --array=1-5

date

micromamba activate pyfigures

mkdir -p logs

# Array of sample names
samples=(
        "uncurated2.2.1_hap1_hifi-duplex_ont"
     	"UOA_Brahman_1"
    	"NIAB-ARS_B.indTharparkar_mat_pri_1.0"
     	"ARS-UCD2.0"
     	"UOA_Angus_1"
)

# Corresponding BAM file paths
bam_files=( 
	"../Winnowmap/uncurated2.2.1_hap1_hifi-duplex_ont/assembly_filtered.bam"
	"../Winnowmap/UOA_Brahman_1/assembly_filtered.bam"
	"../Winnowmap/NIAB-ARS_B.indTharparkar_mat_pri_1.0/assembly_filtered.bam"
	"../Winnowmap/ARS-UCD2.0/assembly_filtered.bam"
	"../Winnowmap/UOA_Angus_1/assembly_filtered.bam"
)


# Corresponding BED file paths
bed_files=(
	"../uncurated2.2.1/hap1/assembly-hap1_chr_only.bed"
        "../../../ref_assemblies/UOA_Brahman_1/GCF_003369695.1_UOA_Brahman_1_genomic.chr_only.bed"
        "../../../ref_assemblies/NIAB-ARS_B.indTharparkar_mat_pri_1.0/GCF_029378745.1_NIAB-ARS_B.indTharparkar_mat_pri_1.0_genomic.chr_only.bed"
        "../../../ref_assemblies/ARS-UCD2.0/ARS-UCD2.0_chr_only.bed"
        "../../../ref_assemblies/UOA_Angus_1/GCA_003369685.2_UOA_Angus_1_genomic.chr_only.bed"
)


# Pick correct sample for this SLURM_ARRAY_TASK_ID
sample="${samples[$SLURM_ARRAY_TASK_ID - 1]}"
bam="${bam_files[$SLURM_ARRAY_TASK_ID - 1]}"
bed="${bed_files[$SLURM_ARRAY_TASK_ID - 1]}"

echo "Running sample: $sample"
echo "Using BAM: $bam"
echo "Using BED: $bed"


# Run nucflag
nucflag -i ${bam} -b ${bed} -d ${sample}




date
