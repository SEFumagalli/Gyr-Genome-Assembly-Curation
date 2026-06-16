# created by Sarah E. Fumagalli


patch_dir="/90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec/8-manualResolution/assembly_patches"
verkko_dir="/90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec"
verkko_fillet_dir="/90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec_verkko_fillet"

## ------------------------------------------------------------------------------------------------------------------------------------------------
##
##
## Create rDNA tangle patches (and others)
##
##
## ------------------------------------------------------------------------------------------------------------------------------------------------


## Run merge_rDNA_ids_scfmap.sh to produce rDNA_utigs_bandgage.txt - load into Bandage and label with new color

	#!/bin/bash -l

	#SBATCH --job-name=rDNA_id_scfmap_smash
	#SBATCH --cpus-per-task=1
	#SBATCH --ntasks=1
	#SBATCH --mem-per-cpu=3000
	#SBATCH --partition=ceres
	#SBATCH --time=1:00:00
	#SBATCH --qos=agil
	#SBATCH --account=cattle_genome_assemblies
	#SBATCH --chdir=/90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec/
	#SBATCH --output=rDNA_id_scfmap_smash__%j.std
	#SBATCH --error=rDNA_id_scfmap_smash__%j.err

	date


	## ----------------------------------------------------------------------------------------------
	## This script creates a table containing the data from fasta.fai and assembly.scfmap.
	## This script creates a file with an easily copied list of rDNA utig4s for Bandage.
	## This script assumes translation_merged.tsv has been created via chromo_assesment.sh or 
	## through verkko-fillet.
	##
	## Inputs: assembly.cattle_rDNA.fasta.fai
	##         assembly.scfmap
	##
	## Output: rDNA_utigs_ids.tsv
	##         rDNA_utig_bandage.txt
	##	   file lengths printed in .std
	## ----------------------------------------------------------------------------------------------

	rDNA="assembly.goat_rDNA.fasta"

	# If fasta.fai file needs to be created, seqkit will be ran
	rDNA_fai="${rDNA}.fai"
	echo $rDNA_fai
	if [ ! -f "$rDNA_fai" ]; then
		echo "creating index"
		module load seqkit
		seqkit faidx $rDNA
	else
		echo "index exists"
	fi

	python3 /project/cattle_genome_assemblies/config_files_scripts/Sarah_scripts/merge_rDNA_ids_scfmap.py \
		--ids $rDNA_fai \
		--scfmap assembly.scfmap \
		--table_output rDNA_utigs_ids \
		--utig_output rDNA_utig_bandage




## Prepare files for Ribotin - I did not end up using rDNA_kmers.fa, but instead Cattle_rDNA.fasta --------------------------------------------
##
#blast_dir="/90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec/blastDB"

#Align to reference
#micromamba activate minimap2
#minimap2 -ax map-ont --secondary=no -C5 -m 100 /90daydata/ruminant_t2t/Gyr/assembly/Cattle_rDNA.fasta $verkko_dir/assembly.fasta > $blast_dir/rDNA_ASM-hits-fixed.sam

#extract rDNA tangle morphs
#module load samtools
#samtools view -b $blast_dir/rDNA_ASM-hits-fixed.sam | samtools fasta > $blast_dir/rDNA_mapped_sequences-fixed.fasta

#generate k-mers from the extracted rDNA morphs
#module load jellyfish
#jellyfish count -m 31 -s 100M -t 4 -o $blast_dir/rDNA_kmers-jfish $blast_dir/rDNA_mapped_sequences-fixed.fasta
#jellyfish merge $blast_dir/rDNA_kmers-jfish_* -o $blast_dir/rDNA_kmers.jf
#jellyfish dump $blast_dir/rDNA_kmers.jf > $blast_dir/rDNA_kmers.fa
##
##


## Run Ribotin - determines consensus.fa for each rDNA morph ------------------------------------------------------------

	launch_ribotin_verkko2.2.1_hifi-duplex_tporec.sh

	#!/bin/bash -l

	#SBATCH --job-name=ribotin
	#SBATCH --cpus-per-task=8
	#SBATCH --ntasks=1
	#SBATCH --mem=1500G
	#SBATCH --qos=agil
	#SBATCH --partition=ceres
	#SBATCH --time=48:00:00
	#SBATCH --chdir=/90daydata/ruminant_t2t/Gyr/assembly/ribotin
	#SBATCH --output=ribotin__%j.std
	#SBATCH --error=ribotin__%j.err

	micromamba activate ribotin
	/project/cattle_genome_assemblies/packages/ribotin/bin/ribotin-verkko \
	  --approx-morphsize 35000 \
	  --guess-tangles-using-reference  /90daydata/ruminant_t2t/Gyr/assembly/Cattle_rDNA.fasta \
	  -i /90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec \
	  -o /90daydata/ruminant_t2t/Gyr/assembly/ribotin2_verkko2.2.1_hifi-duplex_tporec/ribotin


	#Flag Explanation 
	--approx-morphsize 35000	# 35000 is based on the /90daydata/ruminant_t2t/Gyr/assembly/Cattle_rDNA.fasta reference - length 34,665
	--guess-tangles-using-reference # needs to be a path to a fasta/fastq file which contains most rDNA k-mers
	-i 				# input file path - verkko assembly
	-o 				# output path - folder for result file



	Notes:
	For each resulting folder - double check a node from node.txt against bandage plot to identify tangle
	Rename folders to match tangle number if this matters 
	Rename header in fasta files to assocate with each tangle






## Run RepeatMasker - make sure you are getting the same tangles highlighted in Bandage ----------------------------------
##	- this confirmed the same tangles seen in Bandage

	mkdir $verkko_dir/RepeatMasker/

	repeatmasker_hap1.sh

	#!/bin/bash -l

	#SBATCH --job-name=RMhap1
	#SBATCH --cpus-per-task=96
	#SBATCH --ntasks=1
	#SBATCH --partition=ceres
	#SBATCH --qos=memlimit
	#SBATCH --mem-per-cpu=3968
	#SBATCH --time=8-00:00:00
	#SBATCH --account=ruminant_t2t
	#SBATCH --chdir=/project/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec/RepeatMasker
	#SBATCH --output=RM_hap1__%j.std
	#SBATCH --error=RM_hap1__%j.err

	micromamba deactivate
	module load repeatmasker/4.1.0

	RepeatMasker -species "cow" \
	    -libdir /project/cattle_genome_assemblies/config_files_scripts/RepeatMasker_4.0.6_lib \
	    -no_is \
	    -pa 96 \
	    -gff \
	    -s \
	    -dir $verkko_dir/RepeatMasker/RM_hap1c \
	    assembly.haplotype1.fasta



	repeatmasker_hap2.sh

	#!/bin/bash -l

	#SBATCH --job-name=RMhap2
	#SBATCH --cpus-per-task=96
	#SBATCH --ntasks=1
	#SBATCH --partition=ceres
	#SBATCH --qos=memlimit
	#SBATCH --mem-per-cpu=3968
	#SBATCH --time=8-00:00:00
	#SBATCH --account=ruminant_t2t
	#SBATCH --chdir=/project/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec/RepeatMasker
	#SBATCH --output=RM_hap2__%j.std
	#SBATCH --error=RM_hap2__%j.err

	micromamba deactivate
	module load repeatmasker/4.1.0

	RepeatMasker -species "cow" \
	    -libdir /project/cattle_genome_assemblies/config_files_scripts/RepeatMasker_4.0.6_lib \
	    -no_is \
	    -pa 96 \
	    -gff \
	    -s \
	    -dir $verkko_dir/RepeatMasker/RM_hap2c \
	    assembly.haplotype2.fasta


	#Flag Explanation
	-species	# indicate source species of query DNA
	-libdir		# RepeatMasker library path
	-no_is		# skips bacterial insertion element check
	-pa		# number of processors to use in parallel (only works for batch files or sequences larger than 50 kb)
	-gff		# creates an additional General Feature Finding format output
	-s		# slow search; 0-5% more sensitive, 2.5x slower than default
	-dir		# path to output directory
	last line	# assembly.haplotype.fasta 

	#https://github.com/Dfam-consortium/RepeatMasker/blob/master/repeatmasker.help


	#filtering for rRNA, SSU-rRNA, and LSU-rRNA
	grep rRNA $verkko_dir/RepeatMasker/RM_hap1c/assembly.haplotype1.fasta.out > $verkko_dir/RepeatMasker/RM_hap1c/assembly.haplotype1.fasta.out.rRNA  
	grep rRNA $verkko_dir/RepeatMasker/RM_hap2c/assembly.haplotype2.fasta.out > $verkko_dir/RepeatMasker/RM_hap2c/assembly.haplotype2.fasta.out.rRNA  

	awk ' { if ($10=="LSU-rRNA_Hsa" && $2<9) {print $0} else if ($10=="SSU-rRNA_Hsa" && $2<1) {print $0}} ' $verkko_dir/RepeatMasker/RM_hap1c/assembly.haplotype1.fasta.out.rRNA > $verkko_dir/RepeatMasker/RM_hap1c/assembly.haplotype1.fasta.out.rRNA.filtered
	awk ' { if ($10=="LSU-rRNA_Hsa" && $2<9) {print $0} else if ($10=="SSU-rRNA_Hsa" && $2<1) {print $0}} ' $verkko_dir/RepeatMasker/RM_hap2c/assembly.haplotype2.fasta.out.rRNA > $verkko_dir/RepeatMasker/RM_hap2c/assembly.haplotype2.fasta.out.rRNA.filtered


	#combine the first two columns of translation files
	cat $verkko_fillet_dir/translation_hap1 $verkko_fillet_dir/translation_hap2 | awk '{print $1, $2}' > $verkko_fillet_dir/combined_translations


	#merge combined_translations with RepeatMasker.rRNA.filtered file
	merge then cut columns 


	#Column header example:
	18154 = Smith-Waterman score of the match, usually complexity adjusted
		The SW scores are not always directly comparable. Sometimes
		the complexity adjustment has been turned off, and a variety of
		scoring-matrices are used dependent on repeat age and GC level.

	4.1 = % divergence = mismatches/(matches+mismatches) **
	2.7 = % of bases opposite a gap in the query sequence (deleted bp)
	2.0 = % of bases opposite a gap in the repeat consensus (inserted bp)
	sire_compressed.k31.hapmer-0000688 = name of query sequence
	7736 = starting position of match in query sequence
	10547 = ending position of match in query sequence
	(118984356) = no. of bases in query sequence past the ending position of match
	C = match is with the Complement of the repeat consensus sequence
	LSU-rRNA_Hsa = name of the matching interspersed repeat
	rRNA = the class of the repeat
	(0) = no. of bases in (complement of) the repeat consensus sequence 
		     prior to beginning of the match (0 means that the match extended 
		     all the way to the end of the repeat consensus sequence)
	5035 = starting position of match in repeat consensus sequence
	2203 = ending position of match in repeat consensus sequence



	#compare rDNA found in Verkko vs RepeatMasker
	How to interpret results in assembly.haplotype1.fasta.out.rRNA.filtered.merged:
		- Ignore hapmers with partial SSU’s – sire 670 SSU is really small
		- LSU and SSU should not be really far apart
		- Sire 671 looks like a chromosome due to its size (~52Mb) and ends with the rDNA
		- Check for telomere – Hic may have connected the graph
		- Sire 1022 is a well-defined array
		- Chr 4 was expected to have an rDNA array, but is not seen in the sire or dam
		- If there is an instance of a contig that just has an SSU annotation and no LSU annotation
		- Leave it as long as the divergence of the SSU isnt high. It would just represent a fragment.  
		- The reason I remove the LSU only annotations is that those appear to be commonly distributed around the genome but with high divergence from the expected sequence.

	Sire hapmers: 671 (chr25), 677 (chr2), 688 (chr11), 693 (chr3), and 1022
	Dam hapmers: 08 (chr25), 30 (chr3), 33 (chr11), 35 (chr2), 236, and 250 

	Hapmers 1022 (node in tangle 4 – chr2), 236 (node in tangle 2 – chr3), and 250 (node in tangle 2 – chr3) were found as unassigned in assembly.scfmap.tsv
		- meaning that Verkko already removed these rDNA arrays from the graph.
			
	RepeatMasker resulted in tangle 6 associated with dam chr2 

	All rDNA tangles were found by Verkko. 
	Chromosomes 2, 3, 11, and 25 have rDNA tangles and none are T2T.
	Sire hapmer 1022 and Dam hapmers 236 and 250 were unused in Verkko.



	#leverage Verkko output files to extract the hapmers containing/flanking the rDNA region
	output files needed: assembly.paths.tsv
			     assembly.scfmap.tsv
			     assembly.haplotype{1,2}.fasta.gaps


		Look at the rDNA morph flanking utigs in the gyr assembly: 
		
		For example (in detail): Chr 3 – tangle 3: sire
		Using RepeatMasker file (assembly.haplotype2.fasta.out.rRNA.filtered.merged), find confirmed hapmer name:

			sire_compressed.k31.hapmer-0000693 

			grep sire_compressed.k31.hapmer-0000693 assembly.scfmap.tsv

				path    sire_compressed.k31.hapmer-0000693      sire_compressed.k31.hapmer_from_utig4-639

			grep sire_compressed.k31.hapmer-0000693 assembly.haplotype2.fasta.gaps

				gap found: 4070324-4071824

		However, we want the entire range of the rDNA region for CONKORD. 
		We can get this by manually inspecting the RepeatMasker output and taking the first and last coordinates having rDNA annotation for the query hapmer.



	#Find contig comprising rDNA tangle; this will print entire table (manually investigate)

		grep sire_compressed.k31.hapmer-0000693 assembly.haplotype2.fasta.out.rRNA.filtered

		Get the first and last coordinate for the forward strand (+):

			grep sire_compressed.k31.hapmer-0000693 assembly.haplotype2.fasta.out.rRNA.filtered | awk '$9 == "+" {print $6}' | head -n 1
				138141781

			grep sire_compressed.k31.hapmer-0000693 assembly.haplotype2.fasta.out.rRNA.filtered | awk '$9 == "+" {print $7}' | tail -n 1
				138151591

		We now know that for the rDNA tangle on sire_compressed.k31.hapmer-0000693 (Chr3), rDNA can be found between coordinates 138141781 and 138151591. 

		In the interest or robustness, and to ensure that the entire region is encapsulated - I extended these coordinates by ~250 bp:

			Start coordinate rounded down: 138141781 -> 138141500
			End coordinate rounded up: 138151591 -> 138151800
			Length: 138151800 – 138141500 = 10300

		This was done such that some sequence NOT containing rDNA was included in the start and stop coordinate region.



	#Find coordinates for all tangles by repeating the steps above
	Chr 11 – tangle 0: sire
		Start coordinate rounded down: 7736 -> 7500
		End coordinate rounded up: 17583 -> 17800
		Length: 17800 – 7500 = 10300

	Chr 11 - tangle 1: dam
		Start coordinate rounded down: 131978332 -> 131978000
		End coordinate rounded up: 132022591 -> 132022850
		Length: 132022850 – 131978000 = 44850

	Chr 3 – tangle 2: dam
		Start coordinate rounded down: 1 -> 1
		End coordinate rounded up: 8697 -> 8950
		Length: 8950 – 1 = 8949

	Chr 3 – tangle 3: sire
		Start coordinate rounded down: 138141781 -> 138141500
		End coordinate rounded up: 138151591 -> 138151800
		Length: 138151800 – 138141500 = 10300

	Chr 2 – tangle 4: sire
		Start coordinate rounded down: 156795292 -> 156794950
		End coordinate rounded up: 156828031 -> 156828281
		Length: 156828281 – 156794950 = 33331

	Chr 25 – tangle 5: shared
		Start coordinate rounded down: 746 -> 500
		End coordinate rounded up: 51762 -> 51900
		Length: 51900 – 500 = 51400

	Chr 2 - Tangle 6: dam
		Start coordinate rounded down: 155465355 -> 155465100 
		End coordinate rounded up: 155508761 -> 155509000
		Length: 155509000 – 155465100 = 43900




## Prepare files for Conkord --------------------------------------------------------------------------------------------------

	mkdir conkord
	cd conkord

	#symlink in all Ribotin consensus fastas

	ln -s $verkko_dir/ribotin/ribotin_flag_35k_verkko2.2.1_hifi-duplex_tporec0/chr11.hap2.consensus.fa .
	ln -s $verkko_dir/ribotin/ribotin_flag_35k_verkko2.2.1_hifi-duplex_tporec1/chr11.hap1.consensus.fa .
	ln -s $verkko_dir/ribotin/ribotin_flag_35k_verkko2.2.1_hifi-duplex_tporec2/chr3.hap1.consensus.fa .
	ln -s $verkko_dir/ribotin/ribotin_flag_35k_verkko2.2.1_hifi-duplex_tporec3/chr3.hap2.consensus.fa .
	ln -s $verkko_dir/ribotin/ribotin_flag_35k_verkko2.2.1_hifi-duplex_tporec4/chr2.hap2.consensus.fa .
	ln -s $verkko_dir/ribotin/ribotin_flag_35k_verkko2.2.1_hifi-duplex_tporec5/chr25.hap1_2.consensus.fa .
	ln -s $verkko_dir/ribotin/ribotin_flag_35k_verkko2.2.1_hifi-duplex_tporec6/chr2.hap1.consensus.fa .



	#Manually generate BED files for each haplotype assembly

	This was done such that some sequence NOT containing rDNA was included in the start and stop coordinate region, and all information was placed into a bed file.

	echo -e 'sire_compressed.k31.hapmer-0000688\t60935600\t60936200' > $patch_dir/assembly.haplotype2.chr11rDNA.bed
	echo -e 'dam_compressed.k31.hapmer-0000033\t58263750\t58264350' > $patch_dir/assembly.haplotype1.chr11rDNA.bed
	echo -e 'dam_compressed.k31.hapmer-0000030\t37340200\t37340750' > $patch_dir/assembly.haplotype1.chr3rDNA.bed	
	echo -e 'sire_compressed.k31.hapmer-0000693\t138141500\t138151800' > $patch_dir/assembly.haplotype2.chr3rDNA.bed
	echo -e 'sire_compressed.k31.hapmer-0000677\t156795000\t156796300' > $patch_dir/assembly.haplotype2.chr2rDNA.bed
	echo -e 'dam_compressed.k31.hapmer-0000008\t11697400\t11697950' > $patch_dir/assembly.haplotype1.chr25rDNA.bed
	echo -e 'dam_compressed.k31.hapmer-0000035\t155465100\t155467400' > $patch_dir/assembly.haplotype1.chr2rDNA.bed


	#symlink verkko assembly and illumina data

	ln -s /90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec .

	mkdir illumina/F1
	cd illumina/F1

	ln -s /project/ruminant_t2t/Gyr/illumina/F1/read1.fq.gz read_1.fastq.gz
	ln -s /project/ruminant_t2t/Gyr/illumina/F1/read2.fq.gz read_2.fastq.gz


	***Note: the illumina reads need to be in a directory by themselves (no parental data)
	  AND, files need to be named as such: {id}_1.fastq.gz
	  the R1 vs R2 format confuses the string splicing function, use *_1* vs *_2* instead!



## Run Conkord - determines CNV of rDNA morphs

	git clone https://github.com/borcherm/CONKORD.git
	cd CONKORD/

	echo "use conkord.sh to run - run one tangle at a time"


	**Error warning**

	RuleException:
	CalledProcessError in file /90daydata/ruminant_t2t/Gyr/assembly/conkord/CONKORD/Snakefile, line 141:
	Command 'set -euo pipefail;  grep -A1 -w '>0' matched_windows_subset_chr2.hap2.consensus_nfcn_31mers.fa > matched_windows_subset_chr2.hap2.consensus_unique_31mers.fa' returned non-zero exit status 1.
	  File "/90daydata/ruminant_t2t/Gyr/assembly/conkord/CONKORD/Snakefile", line 141, in __rule_kmerize_matched_windows_uniq
	  File "/project/cattle_genome_assemblies/packages/micromamba/envs/verkko-v2.2.1/lib/python3.9/concurrent/futures/thread.py", line 58, in run
	Shutting down, this might take some time.

	***If a conkord run results in this error, try reducing the w_size (window size).



	conkord.sh - run one tangle at a time

	#!/bin/bash -l

	#SBATCH --job-name=conkord
	#SBATCH --cpus-per-task=96
	#SBATCH --ntasks=1
	#SBATCH --mem-per-cpu=3968
	#SBATCH --partition=ceres
	#SBATCH --qos=agil
	#SBATCH --account=cattle_genome_assemblies
	#SBATCH --time=4-00:00:00
	#SBATCH --chdir=/90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec/conkord/CONKORD
	#SBATCH --output=conkord-chr2_hap1__%j.std
	#SBATCH --error=conkord-chr2_hap1__%j.err


	date

	micromamba activate verkko-v2.2.1
	module load bedtools
	#module load jellyfish2 # I used jellyfish 2.2.9, old version will throw errors!
	module load samtools
	#pip install numpy matplotlib seaborn # needed for Call_Copy_Number_GC_Normalization_Version8.py

	## -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
	## Parameters:
	## --no_uniq Used the default ("on"), as this run was for rDNA features
	## -k 31 Used default k-mer size, in accordance with the literature as a reasonable length
	## -f chr{8,10}.hap{1,2}.consensus.fa Ribotin consensus.fa output file; fasta of consensus morph for each tangle
	## -bed assembly.haplotype{1,2}.chr{8,10}rDNA.bed BED file formatted as: Chr/Hapmer# | Start Coordinate rDNA region | End Coordinate rDNA region
	## -r /project/ruminant_t2t/Pig/illumina_data/F1/ Directory containing illumina reads for the F1 individual
	## -g assembly.haplotype{1,2}.fasta Verkko assembly for each individual haplotype (there will be multiple runs of CONKORD, one for each rDNA tangle on each haplotype)
	## -gzip Illumina reads gzipped, not needed if not compressed
	## -t 15 Number of threads used on USDA ceres
	## -w_size 30500 Approximate length of pig rDNA morph (get from consensus.fa or reference.fa)
	## --cluster # Indicate that script is being executed on USDA ceres
	##
	## ------------------------------------------------------------------------------------------------------------------------------------------------------------------------


	bed_file="assembly.haplotype1.chr2rDNA.bed"
	fasta_file="chr2.hap1.consensus.fa"
	w_size=15000

	echo "$bed_file"
	echo "$fasta_file"
	echo "$w_size"

	rename_move_file() {
		#move png files to folder named figures
		if [ ! -d "figures" ]; then
		    mkdir figures
		fi

		#move txt files to folder named counts
		if [ ! -d "counts" ]; then
		    mkdir counts
		fi

		mv "adjusted_feature_counts.png" "figures/$1adjusted_feature_counts.png"
		mv "raw_feature_counts.png" "figures/$1raw_feature_counts.png"
		mv "adjusted_matched_window_counts.png" "figures/$1adjusted_matched_window_counts.png"
		mv "adjusted_feature_counts.txt" "counts/$1adjusted_feature_counts.txt"
		mv "raw_feature_counts.txt" "counts/$1raw_feature_counts.txt"
	}

	hap_check() {
		#determine if hap1 or hap2
		if [[ $1 == *"haplotype1"* ]]; then
			assembly_file="../assembly.haplotype1.fasta"
		else
			assembly_file="../assembly.haplotype2.fasta"
		fi

		echo "$assembly_file"
	}

	get_prefix() {
		#find prefix to result file names
		prefix1=$(echo "$fasta_file" | cut -d'.' -f1)
		prefix2=$(echo "$fasta_file" | cut -d'.' -f2)
		prefix="${prefix1}.${prefix2}."

		echo "$prefix"
	}

	#identify haplotype
	echo "find haplotype"
	assembly_file=$(hap_check $bed_file)
	echo "$assembly_file"

	echo "running conkord"
	python3 conkord.py --no_uniq -k 31 -bed ../$bed_file -f ../$fasta_file -r ../illumina/F1/ -g $assembly_file -w_size $w_size -t 15 --cluster --gzip

	#get prefix
	echo "get prefix"
	prefix=$(get_prefix $fasta_file)
	echo "$prefix"

	#rename and move png and txt result files to designated folders
	rename_move_file $prefix

	date



	#Haplotype2-Chr11
	#python3 conkord.py --no_uniq -k 31 -bed ../assembly.haplotype2.chr11rDNA.bed -f ../chr11.hap2.consensus.fa -r ../illumina/F1/ -g ../assembly.haplotype2.fasta -w_size 35000 -t 15 --cluster --gzip
	#Haplotype1-Chr11
	#python3 conkord.py --no_uniq -k 31 -bed ../assembly.haplotype1.chr11rDNA.bed -f ../chr11.hap1.consensus.fa -r ../illumina/F1/ -g ../assembly.haplotype1.fasta -w_size 35000 -t 15 --cluster --gzip
	#Haplotype1-Chr3
	#python3 conkord.py --no_uniq -k 31 -bed ../assembly.haplotype1.chr3rDNA.bed -f ../chr3.hap1.consensus.fa -r ../illumina/F1/ -g ../assembly.haplotype1.fasta -w_size 35000 -t 15 --cluster --gzip
	#Haplotype2-Chr3
	#python3 conkord.py --no_uniq -k 31 -bed ../assembly.haplotype2.chr3rDNA.bed -f ../chr3.hap2.consensus.fa -r ../illumina/F1/ -g ../assembly.haplotype2.fasta -w_size 35000 -t 15 --cluster --gzip
	#Haplotype2-Chr2
	#python3 conkord.py --no_uniq -k 31 -bed ../assembly.haplotype2.chr2rDNA.bed -f ../chr2.hap2.consensus.fa -r ../illumina/F1/ -g ../assembly.haplotype2.fasta -w_size 15000 -t 15 --cluster --gzip
	#Haplotype1-Chr25
	#python3 conkord.py --no_uniq -k 31 -bed ../assembly.haplotype1.chr25rDNA.bed -f ../chr25.hap1.consensus.fa -r ../illumina/F1/ -g ../assembly.haplotype1.fasta -w_size 15000 -t 15 --cluster --gzip
	#Haplotype1-Chr2
	#python3 conkord.py --no_uniq -k 31 -bed ../assembly.haplotype1.chr2rDNA.bed -f ../chr2.hap1.consensus.fa -r ../illumina/F1/ -g ../assembly.haplotype1.fasta -w_size 15000 -t 15 --cluster --gzip



	#Concord output

	**Conkord outputs a variety of intermediate files and graphs for the input data at hand, but we are primarily interested in the contents of the results/ folder. 
	This folder should comprise one file for each succesful run of the pipeline, with the following nomenclature: Copy_Numbers_nu_(feature-ID}_k{}.tsv. 
	These files contain the median and mean copy number estimates of the rDNA morphs.

	cd CONKORD/results/

	head -n 1 Copy_Numbers_nu_chr11.hap1.consensus_read_k31.tsv > results_combined.tsv

	tail -n +2 -q Copy_Numbers_nu_chr11.hap1.consensus_read_k31.tsv Copy_Numbers_nu_chr11.hap2.consensus_read_k31.tsv Copy_Numbers_nu_chr2.hap2.consensus_read_k31.tsv Copy_Numbers_nu_chr25.hap1_2.consensus_read_k31.tsv Copy_Numbers_nu_chr3.hap1.consensus_read_k31.tsv Copy_Numbers_nu_chr3.hap2.consensus_read_k31.tsv Copy_Numbers_nu_chr2.hap1.consensus_read_k31.tsv >> results_combined.tsv

	In the assembly, we elected to use the Median Haploid Copy Number for our estimate. 
	At this point, we feed a patch file back to verkko containing the ribotin consensus.fa morphs with the now estimated copy numbers to resolve the tangled region.






## Convert rDNA morphs to patches for Verkko---------------------------------------------------------------------------


	mkdir rDNA-patches

	cd verkko2.2.1_hifi-duplex_tporec/8-manualResolution/verkko2.2.1_hifi-duplex_tporec_patch/rDNA-patches

	ln -s /ribotin/ribotin_flag_35k_verkko2.2.1_hifi-duplex_tporec0/chr11.hap2.consensus.fa .
	ln -s /ribotin/ribotin_flag_35k_verkko2.2.1_hifi-duplex_tporec2/chr3.hap1.consensus.fa .
	ln -s /ribotin/ribotin_flag_35k_verkko2.2.1_hifi-duplex_tporec3/chr3.hap2.consensus.fa .
	ln -s /ribotin/ribotin_flag_35k_verkko2.2.1_hifi-duplex_tporec4/chr2.hap2.consensus.fa .
	ln -s /ribotin/ribotin_flag_35k_verkko2.2.1_hifi-duplex_tporec5/chr25.hap1_2.consensus.fa .
	ln -s /ribotin/ribotin_flag_35k_verkko2.2.1_hifi-duplex_tporec6/chr2.hap1.consensus.fa .


	cp 5-untip/unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.gfa .


	run rDNA-morph2patch.sh


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

	#format: rDNA-morph2patch.py input.fasta output.fasta CNV(median haploid copy number)

	echo "Chr 11 Hap1 Tangle 1"
	python3 /project/cattle_genome_assemblies/config_files_scripts/Sarah_scripts/rDNA-morph2patch.py chr11.hap1.consensus.fa chr11.hap1.patch.fa 131

	echo "Chr 11 Hap2 Tangle 0"
	python3 /project/cattle_genome_assemblies/config_files_scripts/Sarah_scripts/rDNA-morph2patch.py chr11.hap2.consensus.fa chr11.hap2.patch.fa 121

	echo "Chr 3 Hap1 Tangle 2"
	python3 /project/cattle_genome_assemblies/config_files_scripts/Sarah_scripts/rDNA-morph2patch.py chr3.hap1.consensus.fa chr3.hap1.patch.fa 136

	echo "Chr 3 Hap2 Tangle 3"
	python3 /project/cattle_genome_assemblies/config_files_scripts/Sarah_scripts/rDNA-morph2patch.py chr3.hap2.consensus.fa chr3.hap2.patch.fa 140

	echo "Chr 2 Hap2 Tangle 4"
	python3 /project/cattle_genome_assemblies/config_files_scripts/Sarah_scripts/rDNA-morph2patch.py chr2.hap2.consensus.fa chr2.hap2.patch.fa 136

	echo "Chr 25 Hap1_2 Tangle 5"
	python3 /project/cattle_genome_assemblies/config_files_scripts/Sarah_scripts/rDNA-morph2patch.py chr25.hap1_2.consensus.fa chr25.hap1_2.patch.fa 134

	echo "Chr 2 Hap1 Tangle 6"
	python3 /project/cattle_genome_assemblies/config_files_scripts/Sarah_scripts/rDNA-morph2patch.py chr2.hap1.consensus.fa chr2.hap1.patch.fa 139



	#Identify flanking utigs for each rDNA morph and its associated gap

	chromosome alignments: /90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec/8-manualResolution/verkko2.2.1_hifi-duplex_tporec_patch/rDNA_patches
	telomere alignments: /90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec/8-manualResolution/verkko2.2.1_hifi-duplex_tporec_patch/telomere_alignments/rDNA_telo

	- code is in the chromo then telo order for each tangle from here 

	tangle0 chr11 hap2:
	grep utig4-439 unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.gfa | awk '/^S/{print ">"$2;print $3}' > utig4-439.fasta
	grep utig4-393 unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.gfa | awk '/^S/{print ">"$2;print $3}' > utig4-393.fasta

	tangle1 chr11 hap1:
	grep utig4-438 unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.gfa | awk '/^S/{print ">"$2;print $3}' > utig4-438.fasta
	grep utig4-1331 unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.gfa | awk '/^S/{print ">"$2;print $3}' > utig4-1331.fasta

	tangle2 chr3 hap1:
	grep utig4-278 unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.gfa | awk '/^S/{print ">"$2;print $3}' > utig4-278.fasta
	grep utig4-259 unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.gfa | awk '/^S/{print ">"$2;print $3}' > utig4-259.fasta

	tangle3 chr3 hap2:
	grep utig4-918 unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.gfa | awk '/^S/{print ">"$2;print $3}' > utig4-918.fasta
	grep utig4-70 unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.gfa | awk '/^S/{print ">"$2;print $3}' > utig4-70.fasta

	tangle4 chr2 hap2:
	grep utig4-982 unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.gfa | awk '/^S/{print ">"$2;print $3}' > utig4-982.fasta
	grep utig4-456 unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.gfa | awk '/^S/{print ">"$2;print $3}' > utig4-456.fasta

	tangle5 chr25 hap1_2:
	grep utig4-376 unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.gfa | awk '/^S/{print ">"$2;print $3}' > utig4-376.fasta
	grep utig4-2334 unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.gfa | awk '/^S/{print ">"$2;print $3}' > utig4-2334.fasta

	tangle6 chr2 hap1:
	grep utig4-607 unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.gfa | awk '/^S/{print ">"$2;print $3}' > utig4-607.fasta
	grep utig4-356 unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.gfa | awk '/^S/{print ">"$2;print $3}' > utig4-356.fasta


	#Compress files

	micromamba activate seqtk

	seqtk hpc chr11.hap2.patch.fa > chr11.hap2.patch.fa.hpc
	seqtk hpc chr11.hap1.patch.fa > chr11.hap1.patch.fa.hpc
	seqtk hpc chr3.hap1.patch.fa > chr3.hap1.patch.fa.hpc
	seqtk hpc chr3.hap2.patch.fa > chr3.hap2.patch.fa.hpc
	seqtk hpc chr2.hap2.patch.fa > chr2.hap2.patch.fa.hpc
	seqtk hpc chr25.hap1_2.patch.fa > chr25.hap1_2.patch.fa.hpc
	seqtk hpc chr2.hap1.patch.fa > chr2.hap1.patch.fa.hpc



	#Align chromos and tangles

	micromamba activate minimap2

	chromosome:
	minimap2 -x asm5 -t 48 utig4-439.fasta chr11.hap2.patch.fa.hpc > utig4-439_chr11.hap2.patch.paf 2> utig4-439_chr11.hap2.patch.err
	minimap2 -x asm5 -t 48 utig4-438.fasta chr11.hap1.patch.fa.hpc > utig4-438_chr11.hap1.patch.paf 2> utig4-438_chr11.hap1.patch.err
	minimap2 -x asm5 -t 48 utig4-278.fasta chr3.hap1.patch.fa.hpc > utig4-278_chr3.hap1.patch.paf 2> utig4-278_chr3.hap1.patch.err
	minimap2 -x asm5 -t 48 utig4-918.fasta chr3.hap2.patch.fa.hpc > utig4-918_chr3.hap2.patch.paf 2> utig4-918_chr3.hap2.patch.err
	minimap2 -x asm5 -t 48 utig4-982.fasta chr2.hap2.patch.fa.hpc > utig4-982_chr2.hap2.patch.paf 2> utig4-982_chr2.hap2.patch.err
	minimap2 -x asm5 -t 48 utig4-376.fasta chr25.hap1_2.patch.fa.hpc > utig4-376_chr25.hap1_2.patch.paf 2> utig4-376_chr25.hap1_2.patch.err
	minimap2 -x asm5 -t 48 utig4-607.fasta chr2.hap1.patch.fa.hpc > utig4-607_chr2.hap1.patch.paf 2> utig4-607_chr2.hap1.patch.err

	telomere:
	minimap2 -x asm5 -t 48 utig4-393.fasta chr11.hap2.patch.fa.hpc > utig4-393_chr11.hap2.patch.paf 2> utig4-393_chr11.hap2.patch.err
	minimap2 -x asm5 -t 48 utig4-1331.fasta chr11.hap1.patch.fa.hpc > utig4-1331_chr11.hap1.patch.paf 2> utig4-1331_chr11.hap1.patch.err
	minimap2 -x asm5 -t 48 utig4-259.fasta chr3.hap1.patch.fa.hpc > utig4-259_chr3.hap1.patch.paf 2> utig4-259_chr3.hap1.patch.err
	minimap2 -x asm5 -t 48 utig4-70.fasta chr3.hap2.patch.fa.hpc > utig4-70_chr3.hap2.patch.paf 2> utig4-70_chr3.hap2.patch.err
	minimap2 -x asm5 -t 48 utig4-456.fasta chr2.hap2.patch.fa.hpc > tangle4_utig4-456.paf 2> tangle4_utig4-456.err
	minimap2 -x asm5 -t 48 utig4-2334.fasta chr25.hap1_2.patch.fa.hpc > tangle5_utig4-2334.paf 2> tangle5_utig4-2334.err
	minimap2 -x asm5 -t 48 utig4-356.fasta chr2.hap1.patch.fa.hpc > tangle6_utig4-356.paf 2> tangle6_utig4-356.err



	#Sort alignments and choose best

	tangle0 chr11 hap2:
	sort -k4nr utig4-439_chr11.hap2.patch.paf > utig4-439_chr11.hap2.patch_sorted.paf
		line 4 shows an alignment much closer to the end of tangle0 and utig4-439
	sort -k4n utig4-393_chr11.hap2.patch.paf > utig4-393_chr11.hap2.patch_sorted.paf
		line 1 shows an alignment close to the beginning of tangle0 and utig4-393

	tangle1 chr11 hap1:
	sort -k4n utig4-438_chr11.hap1.patch.paf | sort -k12nr > utig4-438_chr11.hap1.patch_sorted.paf
		line 1 shows an alignment close to the end of utig4-438 and the beginning of tangle1
	sort -k4nr utig4-1331_chr11.hap1.patch.paf > utig4-1331_chr11.hap1.patch_sorted.paf
		line 1 shows an alignment close to the end of tangle1 and utig4-1331

	tangle2 chr3 hap1:
	sort -k4nr utig4-278_chr3.hap1.patch.paf > utig4-278_chr3.hap1.patch_sorted.paf 
		line 7 shows an alignment close to the beginning of utig4-278 and the end of tangle2
	sort -k4n utig4-259_chr3.hap1.patch.paf > utig4-259_chr3.hap1.patch_sorted.paf
		line 1 shows an alignment with the beginning of tangle2 and utig4-259

	tangle3 chr3 hap2:
	sort -k4n utig4-918_chr3.hap2.patch.paf > utig4-918_chr3.hap2.patch_sorted.paf 
		line 1 shows an alignment close to the end of utig4-918 and the beginning of tangle3
	sort -k4n utig4-70_chr3.hap2.patch.paf > utig4-70_chr3.hap2.patch_sorted.paf
		line 1 shows an alignment close to the end of tangle3 and beginning of utig4-70

	tangle4 chr2 hap2:
	sort -k4n utig4-982_chr2.hap2.patch.paf  > utig4-982_chr2.hap2.patch_sorted.paf
		line 1 shows an alignment close to the end of utig4-982 and the beginning of tangle4
	sort -k4nr utig4-456_chr2.hap2.patch.paf > utig4-456_chr2.hap2.patch_sorted.paf 
		line 1 shows a close alignment to the end of tangle4 and the beginning of utig4-456

	tangle5 chr25 hap1_2:
	sort -k4nr utig4-376_chr25.hap1_2.patch.paf > utig4-376_chr25.hap1_2.patch_sorted.paf
		line 2 shows an alignment close to the end of utig4-376 and tangle5
	sort -k4n utig4-2334_chr25.hap1_2.patch.paf > utig4-2334_chr25.hap1_2.patch_sorted.paf
		line 1 shows an alignment that starts near the beginning and stretches to the end of utig4-2334

	tangle6 chr2 hap1:
	sort -k4n utig4-607_chr2.hap1.patch.paf > utig4-607_chr2.hap1.patch_sorted.paf
		line 1 shows an alignment close to the beginning of utig4-607 and the end of tangle6
	sort -k4nr utig4-356_chr2.hap1.patch.paf > utig4-356_chr2.hap1.patch_sorted.paf
		line 1 shows an alignment close to the end of tangle6 and the beginning of utig4-356




	#Save alignments as patch

	chromosome:
	sed -n '3p' utig4-439_chr11.hap2.patch_sorted.paf > utig4-439_chr11.hap2_line4_patch.paf
	sed -n '1p' utig4-438_chr11.hap1.patch_sorted.paf > utig4-438_chr11.hap1_line1_patch.paf
	sed -n '7p' utig4-278_chr3.hap1.patch_sorted.paf > utig4-278_chr3.hap1_line7_patch.paf
	sed -n '1p' utig4-918_chr3.hap2.patch_sorted.paf > utig4-918_chr3.hap2_line1_patch.paf
	sed -n '1p' utig4-982_chr2.hap2.patch_sorted.paf > utig4-982_chr2.hap2_line1_patch.paf
	sed -n '2p' utig4-376_chr25.hap1_2.patch_sorted.paf > utig4-376_chr25.hap1_2_line2_patch.paf
	sed -n '1p' utig4-607_chr2.hap1.patch_sorted.paf > utig4-607_chr2.hap1_line1_patch.paf

	telomere:
	sed -n '1p' utig4-393_chr11.hap2.patch_sorted.paf > utig4-393_chr11.hap2_line1_patch.paf
	sed -n '1p' utig4-1331_chr11.hap1.patch_sorted.paf > utig4-1331_chr11.hap1_line1_patch.paf
	sed -n '1p' utig4-259_chr3.hap1.patch_sorted.paf > utig4-259_chr3.hap1_line1_patch.paf
	sed -n '1p' utig4-70_chr3.hap2.patch_sorted.paf > utig4-70_chr3.hap2_line1_patch.paf
	sed -n '1p' utig4-456_chr2.hap2.patch_sorted.paf > utig4-456_chr2.hap2_line1_patch.paf
	sed -n '1p' utig4-2334_chr25.hap1_2.patch_sorted.paf > utig4-2334_chr25.hap1_2_line1_patch.paf
	sed -n '1p' utig4-356_chr2.hap1.patch_sorted.paf > utig4-356_chr2.hap1_line1_patch.paf




	#Convert paf to gaf

	chromosome:
	sed s/de:f://g utig4-439_chr11.hap2_line4_patch.paf | awk -F "\t" '{ if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }' > utig4-439_chr11.hap2_line4_patch.gaf
	sed s/de:f://g utig4-438_chr11.hap1_line1_patch.paf | awk -F "\t" '{ if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }' > utig4-438_chr11.hap1_line1_patch.gaf
	sed s/de:f://g utig4-278_chr3.hap1_line7_patch.paf | awk -F "\t" '{ if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }' > utig4-278_chr3.hap1_line7_patch.gaf
	sed s/de:f://g utig4-918_chr3.hap2_line1_patch.paf | awk -F "\t" '{ if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }' > utig4-918_chr3.hap2_line1_patch.gaf
	sed s/de:f://g utig4-982_chr2.hap2_line1_patch.paf | awk -F "\t" '{ if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }' > utig4-982_chr2.hap2_line1_patch.gaf
	sed s/de:f://g utig4-376_chr25.hap1_2_line2_patch.paf | awk -F "\t" '{ if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }' > utig4-376_chr25.hap1_2_line2_patch.gaf
	sed s/de:f://g utig4-607_chr2.hap1_line1_patch.paf | awk -F "\t" '{ if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }' > utig4-607_chr2.hap1_line1_patch.gaf

	telomere:
	sed s/de:f://g utig4-393_chr11.hap2_line1_patch.paf | awk -F "\t" '{ if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }' > utig4-393_chr11.hap2_line1_patch.gaf
	sed s/de:f://g utig4-1331_chr11.hap1_line1_patch.paf | awk -F "\t" '{ if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }' > utig4-1331_chr11.hap1_line1_patch.gaf
	sed s/de:f://g utig4-259_chr3.hap1_line1_patch.paf | awk -F "\t" '{ if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }' > utig4-259_chr3.hap1_line1_patch.gaf
	sed s/de:f://g utig4-70_chr3.hap2_line1_patch.paf | awk -F "\t" '{ if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }' > utig4-70_chr3.hap2_line1_patch.gaf
	sed s/de:f://g utig4-456_chr2.hap2_line1_patch.paf | awk -F "\t" '{ if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }' > utig4-456_chr2.hap2_line1_patch.gaf
	sed s/de:f://g utig4-2334_chr25.hap1_2_line1_patch.paf | awk -F "\t" '{ if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }' > utig4-2334_chr25.hap1_2_line1_patch.gaf
	sed s/de:f://g utig4-356_chr2.hap1_line1_patch.paf | awk -F "\t" '{ if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }' > utig4-356_chr2.hap1_line1_patch.gaf


  
