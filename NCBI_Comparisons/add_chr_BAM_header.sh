#!/bin/bash

#created by Sarah E. Fumagalli

#SBATCH --job-name=add_chr_BAM_header
#SBATCH --error=add_chr_BAM_header__%j.err
#SBATCH --output=add_chr_BAM_header__%j.std
#SBATCH --time=1:00:00
#SBATCH --mem=2G
#SBATCH --cpus-per-task=1
#SBATCH --account=cattle_genome_assemblies
#SBATCH --chdir=/90daydata/ruminant_t2t/Gyr/assembly/ref_assemblies/NIAB-ARS_B.indTharparkar_mat_pri_1.0
#SBATCH --partition=ceres



date

echo "create map"
awk -F"\t" '{split($1,a,"_chr"); print a[1]"\t"$1}' GCF_029378745.1_NIAB-ARS_B.indTharparkar_mat_pri_1.0_genomic.chr.labeled.bed > mapping.txt

echo "extract BAM header"
samtools view -H GCF_029378745.1_NIAB-ARS_B.indTharparkar_mat_pri_1.0_modelrefseq_alns.bam > old_header.sam

echo "replace SN: values with map file"
while read old new; do
sed -i "s/SN:${old}/SN:${new}/" old_header.sam
done < mapping.txt

echo "reheader BAM"
samtools reheader old_header.sam GCF_029378745.1_NIAB-ARS_B.indTharparkar_mat_pri_1.0_modelrefseq_alns.bam > GCF_029378745.1_NIAB-ARS_B.indTharparkar_mat_pri_1.0_modelrefseq_alns.chr.labeled.bam

echo "index updated BAM file"
samtools index GCF_029378745.1_NIAB-ARS_B.indTharparkar_mat_pri_1.0_modelrefseq_alns.chr.labeled.bam

echo "remove all contigs not associated with chromosome"
samtools view -h GCF_029378745.1_NIAB-ARS_B.indTharparkar_mat_pri_1.0_modelrefseq_alns.chr.labeled.bam \                                                                                                                                                                          | awk '{if($0 ~ /^@SQ/ && $2 !~ /chr/) next; else if($0 !~ /^@/ && $3 !~ /chr/) next; else print }' | samtools view -b - > GCF_029378745.1_NIAB-ARS_B.indTharparkar_mat_pri_1.0_modelrefseq_alns.chr_only.bam

echo "index updated BAM file"
samtools index GCF_029378745.1_NIAB-ARS_B.indTharparkar_mat_pri_1.0_modelrefseq_alns.chr_only.bam


date
