# created by Sarah E. Fumagalli & Lee Ackerson


patch_dir="/assembly/verkko2.2.1_hifi-duplex_tporec/8-manualResolution/rDNA"
verkko_dir="/assembly/verkko2.2.1_hifi-duplex_tporec"
verkko_fillet_dir="/assembly/verkko2.2.1_hifi-duplex_tporec_verkko_fillet"

## ------------------------------------------------------------------------------------------------------------------------------------------------

mkdir $patch_dir && cd $patch_dir


1. Identify rDNA tangles with Bandage

    In Verkko-Fillet, the rDNA nodes are listed in rDNA_utigs_ids_Bandage.txt.

    

2. Run Ribotin

    https://github.com/maickrau/ribotin

    Determines consensus.fa for each rDNA morph it finds.

	ribotin.sh
	
        mkdir $verkko_dir/ribotin && cd $verkko_dir/ribotin

        micromamba activate ribotin
        
        /ribotin/bin/ribotin-verkko \
            --approx-morphsize 35000 \
            --guess-tangles-using-reference Cattle_rDNA.fasta \
            -i /assembly/verkko2.2.1_hifi-duplex_tporec \
            -o /assembly/verkko2.2.1_hifi-duplex_tporec/ribotin/Gyr_ribotin


    	Flag Explanation 

        --approx-morphsize 35000         35000 is based on the /assembly/Cattle_rDNA.fasta reference - length 34,665
        --guess-tangles-using-reference  needs to be a path to a fasta/fastq file which contains most rDNA k-mers
        -i 				                 input file path - verkko assembly
        -o 				                 output path - folder for result files



3. Run RepeatMasker 

    https://github.com/Dfam-consortium/RepeatMasker/

    Make sure you are getting the same tangles highlighted in Bandage.
    
    This script was ran for each haplotype individually.

	repeatmasker.sh
	
        	mkdir $verkko_dir/RepeatMasker && $verkko_dir/RepeatMasker

        RepeatMasker -species "cow" \
            -libdir RepeatMasker_4.0.6_lib \
            -no_is \
            -pa 96 \
            -gff \
            -s \
            -dir $verkko_dir/RepeatMasker/RM_hap \
            assembly.haplotype.fasta


	Flag Explanation
        
        -species    indicate source species of query DNA
        -libdir		RepeatMasker library path
        -no_is		skips bacterial insertion element check
        -pa		    number of processors to use in parallel (only works for batch files or sequences larger than 50 kb)
        -gff		    creates an additional General Feature Finding format output
        -s		    slow search; 0-5% more sensitive, 2.5x slower than default
        -dir		    path to output directory
        last line	assembly.haplotype.fasta from Verkko



	Filtering for rRNA, SSU-rRNA, and LSU-rRNA (tips from Ben Rosen)
	
        grep rRNA $verkko_dir/RepeatMasker/RM_hap1/assembly.haplotype1.fasta.out > $verkko_dir/RepeatMasker/RM_hap1/assembly.haplotype1.fasta.out.rRNA  
        grep rRNA $verkko_dir/RepeatMasker/RM_hap2/assembly.haplotype2.fasta.out > $verkko_dir/RepeatMasker/RM_hap2/assembly.haplotype2.fasta.out.rRNA  

        awk ' { if ($10=="LSU-rRNA_Hsa" && $2<9) {print $0} else if ($10=="SSU-rRNA_Hsa" && $2<1) {print $0}} ' $verkko_dir/RepeatMasker/RM_hap1/assembly.haplotype1.fasta.out.rRNA > $verkko_dir/RepeatMasker/RM_hap1/assembly.haplotype1.fasta.out.rRNA.filtered
        awk ' { if ($10=="LSU-rRNA_Hsa" && $2<9) {print $0} else if ($10=="SSU-rRNA_Hsa" && $2<1) {print $0}} ' $verkko_dir/RepeatMasker/RM_hap2/assembly.haplotype2.fasta.out.rRNA > $verkko_dir/RepeatMasker/RM_hap2/assembly.haplotype2.fasta.out.rRNA.filtered


	Combine the first two columns of translation files
	
        	cat $verkko_fillet_dir/translation_hap1 $verkko_fillet_dir/translation_hap2 | awk '{print $1, $2}' > $verkko_fillet_dir/combined_translations


	Merge combined_translations with RepeatMasker.rRNA.filtered file
	
        	merge then cut columns (need to add details)
        	

	Leverage Verkko output files to extract the hapmers containing/flanking the rDNA region
	
        - output files needed: 
        
                assembly.paths.tsv
                assembly.scfmap.tsv
                assembly.haplotype{1,2}.fasta.gaps


        Look at the rDNA morph flanking utigs in the gyr assembly: 
		
            Example 
            
                - Chr 3 – tangle 3: sire
                
                    - using RepeatMasker file (assembly.haplotype2.fasta.out.rRNA.filtered.merged), find confirmed hapmer name

                        sire_compressed.k31.hapmer-0000693 

                            grep sire_compressed.k31.hapmer-0000693 assembly.scfmap.tsv

                                path    sire_compressed.k31.hapmer-0000693      sire_compressed.k31.hapmer_from_utig4-639
                            

                            grep sire_compressed.k31.hapmer-0000693 assembly.haplotype2.fasta.gaps

                                gap found: 4070324-4071824
                                
                                
		However, we want the entire range of the rDNA region for CONKORD. 
		
		We can get this by manually inspecting the RepeatMasker output and taking the first and last coordinates having rDNA annotation for the query hapmer.



	Find contig comprising rDNA tangle
	
        This will print entire table (manually investigate).

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




4. Prepare files for Conkord 

    Create directory and symlink in Ribotin consensus fastas.

        mkdir $verkko_dir/conkord && cd $verkko_dir/conkord

        ln -s $verkko_dir/ribotin/Gyr_ribotin0/chr11.hap2.consensus.fa .
        ln -s $verkko_dir/ribotin/Gyr_ribotin1/chr11.hap1.consensus.fa .
        	ln -s $verkko_dir/ribotin/Gyr_ribotin2/chr3.hap1.consensus.fa .
        	ln -s $verkko_dir/ribotin/Gyr_ribotin3/chr3.hap2.consensus.fa .
        	ln -s $verkko_dir/ribotin/Gyr_ribotin4/chr2.hap2.consensus.fa .
        	ln -s $verkko_dir/ribotin/Gyr_ribotin5/chr25.hap1_2.consensus.fa .
        	ln -s $verkko_dir/ribotin/Gyr_ribotin6/chr2.hap1.consensus.fa .


	Manually generate BED files for each haplotype assembly.

        - this was done such that some sequence NOT containing rDNA was included in the start and stop coordinate region, and all information was placed into a bed file.

            	echo -e 'sire_compressed.k31.hapmer-0000688\t60935600\t60936200' > $patch_dir/assembly.haplotype2.chr11rDNA.bed
            	echo -e 'dam_compressed.k31.hapmer-0000033\t58263750\t58264350' > $patch_dir/assembly.haplotype1.chr11rDNA.bed
            	echo -e 'dam_compressed.k31.hapmer-0000030\t37340200\t37340750' > $patch_dir/assembly.haplotype1.chr3rDNA.bed	
            	echo -e 'sire_compressed.k31.hapmer-0000693\t138141500\t138151800' > $patch_dir/assembly.haplotype2.chr3rDNA.bed
            	echo -e 'sire_compressed.k31.hapmer-0000677\t156795000\t156796300' > $patch_dir/assembly.haplotype2.chr2rDNA.bed
            	echo -e 'dam_compressed.k31.hapmer-0000008\t11697400\t11697950' > $patch_dir/assembly.haplotype1.chr25rDNA.bed
            	echo -e 'dam_compressed.k31.hapmer-0000035\t155465100\t155467400' > $patch_dir/assembly.haplotype1.chr2rDNA.bed


	Symlink Verkko assembly and Illumina data
	
        	- the illumina reads need to be in a directory by themselves (no parental data) 
        	
        	- files need to be named as such: {id}_1.fastq.gz 
        	
        	- the R1 vs R2 format confuses the string splicing function, use *_1* vs *_2* instead

            ln -s /assembly/verkko2.2.1_hifi-duplex_tporec .

            	mkdir illumina/F1 && cd illumina/F1

            	ln -s /illumina/F1/read1.fq.gz read_1.fastq.gz
            	ln -s /illumina/F1/read2.fq.gz read_2.fastq.gz





5. Run CONKORD 

    https://github.com/borcherm/CONKORD

    Determines CNV of rDNA morphs

        conkord.sh
        
            - Error warning

                	RuleException:
                	CalledProcessError in file /assembly/conkord/CONKORD/Snakefile, line 141:
                	Command 'set -euo pipefail;  grep -A1 -w '>0' matched_windows_subset_chr2.hap2.consensus_nfcn_31mers.fa > matched_windows_subset_chr2.hap2.consensus_unique_31mers.fa' returned non-zero exit status 1.
                	  File "/assembly/conkord/CONKORD/Snakefile", line 141, in __rule_kmerize_matched_windows_uniq
                	  File "/micromamba/envs/verkko-v2.2.1/lib/python3.9/concurrent/futures/thread.py", line 58, in run
                	Shutting down, this might take some time.

            
                - if a conkord run results in this error, try reducing the w_size (window size).

            
            python3 conkord.py --no_uniq -k 31 -bed <bed_file> -f <fasta_file> -r <illumina_data> \
                -g <assembly.haplotype.fasta> -w_size <window_size> -t <thread_count> --cluster --gzip

            
            - Parameters
                
                --no_uniq                                           used the default ("on"), as this run was for rDNA features
                -k 31                                               used default k-mer size, in accordance with the literature as a reasonable length
                -f chr{8,10}.hap{1,2}.consensus.fa                  ribotin consensus.fa output file; fasta of consensus morph for each tangle
                -bed assembly.haplotype{1,2}.chr{8,10}rDNA.bed      BED file formatted as: Chr/Hapmer# | Start Coordinate rDNA region | End Coordinate rDNA region
                -r /illumina_data/F1/                               directory containing illumina reads for the F1 individual
                -g assembly.haplotype{1,2}.fasta                    verkko assembly for each individual haplotype (there will be multiple runs of CONKORD, one for each rDNA tangle on each haplotype)
                -gzip                                               illumina reads gzipped, not needed if not compressed
                -t 15                                               number of threads
                -w_size 35000                                       approximate length of Gyr rDNA morph (get from consensus.fa or reference.fa)
                --cluster                                           indicate that script is being executed on USDA ceres
	

	

        - conkord output

            - conkord outputs a variety of intermediate files and graphs for the input data at hand, but we are primarily interested in the contents of the results/ folder. 
	
            	- this folder should comprise one file for each succesful run of the pipeline, with the following nomenclature: Copy_Numbers_nu_(feature-ID}_k{}.tsv. 
	
            	- these files contain the median and mean copy number estimates of the rDNA morphs.

                	cd conkord/results/

                head -n 1 Copy_Numbers_nu_chr11.hap1.consensus_read_k31.tsv > results_combined.tsv

                	tail -n +2 -q Copy_Numbers_nu_chr11.hap1.consensus_read_k31.tsv Copy_Numbers_nu_chr11.hap2.consensus_read_k31.tsv Copy_Numbers_nu_chr2.hap2.consensus_read_k31.tsv Copy_Numbers_nu_chr25.hap1_2.consensus_read_k31.tsv Copy_Numbers_nu_chr3.hap1.consensus_read_k31.tsv Copy_Numbers_nu_chr3.hap2.consensus_read_k31.tsv Copy_Numbers_nu_chr2.hap1.consensus_read_k31.tsv >> results_combined.tsv

            - in the assembly, we elected to use the Median Haploid Copy Number for our estimate. 
            


6. Convert rDNA morphs to patches for Verkko

    Set up input files 

        cd $patch_dir

        	ln -s $verkko_dir/ribotin/Gyr_ribotin0/chr11.hap2.consensus.fa .
        ln -s $verkko_dir/ribotin/Gyr_ribotin1/chr11.hap1.consensus.fa .
        ln -s $verkko_dir/ribotin/Gyr_ribotin2/chr3.hap1.consensus.fa .
        	ln -s $verkko_dir/ribotin/Gyr_ribotin3/chr3.hap2.consensus.fa .
        	ln -s $verkko_dir/ribotin/Gyr_ribotin4/chr2.hap2.consensus.fa .
        	ln -s $verkko_dir/ribotin/Gyr_ribotin5/chr25.hap1_2.consensus.fa .
        	ln -s $verkko_dir/ribotin/Gyr_ribotin6/chr2.hap1.consensus.fa .
        
        	cp 5-untip/unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.gfa .
        
        	rDNA-morph2patch.sh
        	
        
            	python3 rDNA-morph2patch.py <consensus.fa> <patch_fasta_name> <median_haploid_copy_number>

	

	Identify flanking utigs for each rDNA morph and its associated gap

        	- similar to what we did in patch_creation-telo.sh
        	
        	- grab the fastas for the neighboring utig4s on the chromosome and telomere
        	
        	- if a telomere is not available, use the last utig in the rDNA array

            - tangle0 chr11 hap2
            	
                	- chromosome
                	
                    grep utig4-439 unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.gfa | awk '/^S/{print ">"$2;print $3}' > utig4-439.fasta
                    
                - telomere
                
                    grep utig4-393 unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.gfa | awk '/^S/{print ">"$2;print $3}' > utig4-393.fasta

	
	Align chromos and tangles

        - tangle0 chr11 hap2
        
            - chromosome
            
                minimap2 -x asm5 -t 48 utig4-439.fasta chr11.hap2.patch.fa > utig4-439_chr11.hap2.patch.paf 2> utig4-439_chr11.hap2.patch.err
	
            	- telomere
            	
                minimap2 -x asm5 -t 48 utig4-393.fasta chr11.hap2.patch.fa > utig4-393_chr11.hap2.patch.paf 2> utig4-393_chr11.hap2.patch.err
	


	Save alignments as patch

        - tangle0 chr11 hap2
        
            - chromosome
	
                	sed -n '3p' utig4-439_chr11.hap2.patch_sorted.paf > utig4-439_chr11.hap2_line4_patch.paf

            - telomere
	
                sed -n '1p' utig4-393_chr11.hap2.patch_sorted.paf > utig4-393_chr11.hap2_line1_patch.paf
	

	Convert paf to gaf

        - tangle0 chr11 hap2
        
            	- chromosome
	
                sed s/de:f://g utig4-439_chr11.hap2_line4_patch.paf | awk -F "\t" '{ if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }' > utig4-439_chr11.hap2_line4_patch.gaf
	
            	- telomere
            	
                	sed s/de:f://g utig4-393_chr11.hap2_line1_patch.paf | awk -F "\t" '{ if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }' > utig4-393_chr11.hap2_line1_patch.gaf
   
   
                	
7. Final processing of these types of patches can be found in patch_creation-final.sh
  
