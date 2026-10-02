#!/bin/bash -l

#SBATCH --job-name=nucfreq
#SBATCH --cpus-per-task=96
#SBATCH --ntasks=1
#SBATCH --mem=1500G
#SBATCH --partition=ceres
#SBATCH --qos=agil
#SBATCH --account=cattle_genome_assemblies
#SBATCH --time=1-00:00:00
#SBATCH --chdir=/90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec/9-post_assembly_analysis/nucfreq
#SBATCH --output=logs/nucfreq__%A_%a.std
#SBATCH --error=logs/nucfreq__%A_%a.err
#SBATCH --array=1-12


#symlink all files + bam.bai to sample specific folders - nucfreq will send results to where the files are, not chdir

date

micromamba activate pyfigures


mkdir -p logs


# Array of sample names
samples=(
        "UOA_Brahman_1"
	"UOA_Brahman_1"
	"UOA_Brahman_1"
        "NIAB-ARS_B.indTharparkar_mat_pri_1.0"
	"NIAB-ARS_B.indTharparkar_mat_pri_1.0"
	"NIAB-ARS_B.indTharparkar_mat_pri_1.0"
        "ARS-UCD2.0"
	"ARS-UCD2.0"
	"ARS-UCD2.0"
        "UOA_Angus_1"
	"UOA_Angus_1"
	"UOA_Angus_1"
)

# Corresponding BAM file paths
bam_files=(
	"UOA_Brahman_1_chr4_only.bam"
        "UOA_Brahman_1_chr6_only.bam"
        "UOA_Brahman_1_chr14_only.bam"
	"NIAB-ARS_B.indTharparkar_mat_pri_1.0_chr4_only.bam"
        "NIAB-ARS_B.indTharparkar_mat_pri_1.0_chr6_only.bam"
        "NIAB-ARS_B.indTharparkar_mat_pri_1.0_chr14_only.bam"
        "ARS-UCD2.0_chr4_only.bam"
        "ARS-UCD2.0_chr6_only.bam"
        "ARS-UCD2.0_chr14_only.bam"
	"UOA_Angus_1_chr4_only.bam"
        "UOA_Angus_1_chr6_only.bam"
        "UOA_Angus_1_chr14_only.bam"
)


# Corresponding BED file paths
bed_files=(
        "GCF_003369695.1_UOA_Brahman_1_genomic.chr4_only.bed"
	"GCF_003369695.1_UOA_Brahman_1_genomic.chr6_only.bed"
	"GCF_003369695.1_UOA_Brahman_1_genomic.chr14_only.bed"
        "GCF_029378745.1_NIAB-ARS_B.indTharparkar_mat_pri_1.0_genomic.chr4_only.bed"
	"GCF_029378745.1_NIAB-ARS_B.indTharparkar_mat_pri_1.0_genomic.chr6_only.bed"
	"GCF_029378745.1_NIAB-ARS_B.indTharparkar_mat_pri_1.0_genomic.chr14_only.bed"
        "ARS-UCD2.0_chr4_only.bed"
	"ARS-UCD2.0_chr6_only.bed"
	"ARS-UCD2.0_chr14_only.bed"
        "GCA_003369685.2_UOA_Angus_1_genomic.chr4_only.bed"
	"GCA_003369685.2_UOA_Angus_1_genomic.chr6_only.bed"
	"GCA_003369685.2_UOA_Angus_1_genomic.chr14_only.bed"
)


# PNG Outfile
out_png=(
	"nucfreq_chr4.png"
	"nucfreq_chr6.png"
	"nucfreq_chr14.png"
	"nucfreq_chr4.png"
        "nucfreq_chr6.png"
        "nucfreq_chr14.png"
	"nucfreq_chr4.png"
        "nucfreq_chr6.png"
        "nucfreq_chr14.png"
	"nucfreq_chr4.png"
        "nucfreq_chr6.png"
        "nucfreq_chr14.png"
)

# BED Outfile
out_bed=(
	"nucfreq_chr4.obed"
	"nucfreq_chr6.obed"
	"nucfreq_chr14.obed"
	"nucfreq_chr4.obed"
        "nucfreq_chr6.obed"
        "nucfreq_chr14.obed"
	"nucfreq_chr4.obed"
        "nucfreq_chr6.obed"
        "nucfreq_chr14.obed"
	"nucfreq_chr4.obed"
        "nucfreq_chr6.obed"
        "nucfreq_chr14.obed"
)




# Pick correct sample for this SLURM_ARRAY_TASK_ID
sample="${samples[$SLURM_ARRAY_TASK_ID - 1]}"
bam="${bam_files[$SLURM_ARRAY_TASK_ID - 1]}"
bed="${bed_files[$SLURM_ARRAY_TASK_ID - 1]}"
opng="${out_png[$SLURM_ARRAY_TASK_ID - 1]}"
obed="${out_bed[$SLURM_ARRAY_TASK_ID - 1]}"

echo "Running sample: $sample"
echo "Using BAM: $bam"
echo "Using BED: $bed"
echo "Using PNG: $opng"
echo "Using OBED: $obed"


# Output directory
cd ${sample}


python3 /project/cattle_genome_assemblies/packages/NucFreq/NucPlot.py --bed ${bed} ${bam} ${opng} --threads 96 --height 8 --width 10 --dpi 300 --obed ${obed}

cd ..

date
