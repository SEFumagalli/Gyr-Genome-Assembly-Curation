# created by Sarah E. Fumagalli

#!/bin/bash -l

#SBATCH --job-name=assembly_stats
#SBATCH --cpus-per-task=96
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=3968
#SBATCH --partition=ceres
#SBATCH --qos=agil
#SBATCH --time=3-00:00:00
#SBATCH --account=cattle_genome_assemblies
#SBATCH --chdir=/90daydata/ruminant_t2t/Gyr/assembly/
#SBATCH --output=assembly_stats__%j.std
#SBATCH --error=assembly_stats__%j.err


## ------------------------------------------------------------------------------------
## For a given assembly, this script finds the telomere counts, gaps, aligns 
## each haplotype to the reference, and calculates gfa stats.
## 
## Requirement: gfastats files created for each assembly
##
## Final input for each assembly: haplotype1.fasta.stats
##                                haplotype2.fasta.stats
##
## Output per haplotype: assembly.fasta.telo.counts 
##			 assembly.fasta.gaps
##			 assembly.paf
##			 assembly_gfa.stats
##
## Output per assembly: assembly.homopolymer-compressed_gfa.stats
##			gfastats.tsv
## ------------------------------------------------------------------------------------


date

reference="ARS-UCD2.0_chr.fasta"
assemblies=("verkko2.2.1_hifi_hic" "verkko2.2.1_hifi_trio" "verkko2.2.1_hifi-q36_hic" "verkko2.2.1_hifi-q36_porec" "verkko2.2.1_hifi-q36_trio" "verkko2.2_hifi-duplex_hic" "verkko2.2_hifi-duplex_porec" "verkko2.2.1_hifi-duplex_trio" "verkko2.2.1_hifi-duplex_tporec" "verkko2.2.1_hifi-herro_hic" "verkko2.2.1_hifi-herro_porec" "verkko2.2.1_hifi-herro_trio" "verkko2.2_duplex_hic" "verkko2.2.1_duplex_porec" "verkko2.2.1_duplex_trio" "verkko2.2.1_herro_hic" "verkko2.2.1_herro_porec" "verkko2.2.1_herro_trio")

#column names for tables
filenames=("HiFi Hi-C Hap1" "HiFi Hi-C Hap2" "HiFi Trio Hap1" "HiFi Trio Hap2" "HiFi-q36 Hi-C Hap1" "HiFi-q36 Hi-C Hap2" "HiFi-q36 Pore-C Hap1" "HiFi-q36 Pore-C Hap2" "HiFi-q36 Trio Hap1" "HiFi-q36 Trio Hap2" "HiFi-Duplex Hi-C Hap1" "HiFi-Duplex Hi-C Hap2" "HiFi-Duplex Pore-C Hap1" "HiFi-Duplex Pore-C Hap2" "HiFi-Duplex Trio Hap1" "HiFi-Duplex Trio Hap2" "HiFi-Duplex TPore-C Hap1" "HiFi-Duplex TPore-C Hap2" "HiFi-Herro Hi-C Hap1" "HiFi-Herro Hi-C Hap2" "HiFi-Herro Pore-C Hap1" "HiFi-Herro Pore-C Hap2" "HiFi-Herro Trio Hap1" "HiFi-Herro Trio Hap2" "Duplex Hi-C Hap1" "Duplex Hi-C Hap2" "Duplex Pore-C Hap1" "Duplex Pore-C Hap2" "Duplex Trio Hap1" "Duplex Trio Hap2" "Herro Hi-C Hap1" "Herro Hi-C Hap2" "Herro Pore-C Hap1" "Herro Pore-C Hap2" "Herro Trio Hap1" "Herro Trio Hap2")


#table file names
tsv_gfa="Gyr_hap_gfastats"



for assembly in "${assemblies[@]}"
do
        echo "$assembly"

	echo "telomere counts"
	micromamba activate seqtk
	seqtk telo $assembly/assembly.haplotype1.fasta > $assembly/assembly.haplotype1.fasta.telo 2> $assembly/assembly.haplotype1.fasta.telo.counts
	seqtk telo $assembly/assembly.haplotype2.fasta > $assembly/assembly.haplotype2.fasta.telo 2> $assembly/assembly.haplotype2.fasta.telo.counts
	micromamba deactivate

	echo "gfastats to find gaps"
	/gfastats/gfastats --out-coord g -f $assembly/assembly.haplotype1.fasta > $assembly/assembly.haplotype1.fasta.gaps
	/gfastats/gfastats --out-coord g -f $assembly/assembly.haplotype2.fasta > $assembly/assembly.haplotype2.fasta.gaps

	echo "minimap2 to align verkko assembly to reference"
	micromamba activate minimap2
	minimap2 -x asm5 -t 48 $reference $assembly/assembly.haplotype1.fasta > $assembly/assembly.haplotype1.paf 2> $assembly/assembly.haplotype1.paf.err
	minimap2 -x asm5 -t 48 $reference $assembly/assembly.haplotype2.fasta > $assembly/assembly.haplotype2.paf 2> $assembly/assembly.haplotype2.paf.err
	micromamba deactivate

	echo "gfastats for assembly stats"
	/gfastats/gfastats $assembly/assembly.haplotype1.fasta > $assembly/assembly_hap1_gfa.stats
	/gfastats/gfastats $assembly/assembly.haplotype2.fasta > $assembly/assembly_hap2_gfa.stats

	echo "gfastats for assembly graph"
	/gfastats/gfastats --discover-paths -f $assembly/assembly.homopolymer-compressed.gfa > $assembly/assembly.homopolymer-compressed_gfa.stats

done


micromamba activate pyfigures

echo "join gfastats"
python3 assembly_stats.py \
        --assemblies "${assemblies[@]}" \
        --filenames "${filenames[@]}" \
        --tsv_gfa $tsv_gfa



date
