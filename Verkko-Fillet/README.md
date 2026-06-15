# Verkko-Fillet - using Bash and python instead of Jupyter Lab

---


Find Verkko-Fillet here **[Verkko-Fillet](https://github.com/jjuhyunkim/verkko-fillet/tree/main)**

All scripts are formatted for use on the Ceres cluster at the USDA.


1. Add conda symlink to home directory 
	
	ln -s /project/cattle_genome_assemblies/packages/.conda .


2. Download **[Verkko-Fillet](https://github.com/jjuhyunkim/verkko-fillet/tree/main)**


3. Update Verkko-Fillet scripts with in-house modifications

    **run_verkko_fillet_notes.txt**

    This document gives step-by-step instructions on some code modifications and implimentation of in-house scripts.
    
    This includes placing new code in **getChrNames.sh** and adding the file **chromo_assessment.py**: 
    
        ~/.conda/envs/verkko-fillet/lib/python3.9/site-packages/verkkofillet/bin/getChrNames.sh
    
        ~/.conda/envs/verkko-fillet/lib/python3.9/site-packages/verkkofillet/tools/chromo_assessment.py
        
    Make sure **translation_merge_table_plot.py** is in the same folder as **run_verkko_fillet.py**.
    

4. Locate main directory (directory of verkko assemblies)
	
	cd main_directory


5. Create chromosome map file and update reference.fna

    **create_chrmap_update_ref.sh**

        There are 3 ways this script can be initiated:
            1. If you need to download the NCBI assembly.fna.gz and assembly_report.txt
            
                - reference_path=https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/024/291/935/GCA_024291935.2_TBG_Okapi_asm_v1/GCA_024291935.2_TBG_Okapi_asm_v1_genomic.fna.gz
            		- report_path=https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/024/291/935/GCA_024291935.2_TBG_Okapi_asm_v1/GCA_024291935.2_TBG_Okapi_asm_v1_assembly_report.txt

            2. If the NCBI files from #1 are downloaded and the chromosome.map needs to be created
            3. If the chromosome.map file was manually created (see details below on formatting)        		

        Output files: 
            - reference_assembly.fna.fai
            - reference_assembly.chr.fna - includes chromosome names
            - reference_assembly.chr.fna.fai
            - chromosome.map - if not provided



        	To create a file called manual_chromosome.map located in your main_directory
            	
            	- This file will have no header, no index, just two columns: 1) RefSeq identifier and 2) chromosome number
            	- Make note of the formatting in the second column - do not forget to use '_'
                	
                	Example:
                	
                	NC_037328.1     chr_1
                	NC_037329.1     chr_2
                	NC_037330.1     chr_3
                	NC_037331.1     chr_4
                	NC_037332.1     chr_5
                	NC_037333.1     chr_6
                	NC_037334.1     chr_7
                	NC_037335.1     chr_8
                	NC_037336.1     chr_9
                	NC_037337.1     chr_10
                	NC_037338.1     chr_11
                	NC_037339.1     chr_12
                	NC_037340.1     chr_13
                	NC_037341.1     chr_14
                	NC_037342.1     chr_15
                	NC_037343.1     chr_16
                	NC_037344.1     chr_17
                	NC_037345.1     chr_18
                	NC_037346.1     chr_19
                	NC_037347.1     chr_20
                	NC_037348.1     chr_21
                	NC_037349.1     chr_22
                	NC_037350.1     chr_23
                	NC_037351.1     chr_24
                	NC_037352.1     chr_25
                	NC_037353.1     chr_26
                	NC_037354.1     chr_27
                	NC_037355.1     chr_28
                	NC_037356.1     chr_29
                	NC_037357.1     chr_X
                	NC_082638.1     chr_Y 
                	


            	-Alternate method: 
                	- This script can also be used if your reference.fasta was produced from running hifiasm or for whatever reason have an extra column of information to map
                	- !! name this file something OTHER THAN chromosome.map - it will be rewritten otherwise
                    - this file will have no header, no index, just three columns: 1) ID, 2) RefSeq identifier, & 3) chromosome number
                    - make note of the formatting in the second column - do not forget to use '_'
                    
                    Example:
                    
                    	h1tg000033l     NC_000001.1     chr_1
                		h2tg000020l_h2tg000029l NC_000002.1     chr_2
                		h1tg000005l     NC_000003.1     chr_3
                		h1tg000017l     NC_000004.1     chr_4
                		h1tg000020l     NC_000005.1     chr_5
                		h1tg000014l     NC_000006.1     chr_6
                		h1tg000003l     NC_000007.1     chr_7
                		h1tg000019l     NC_000008.1     chr_8
                		h1tg000004l     NC_000009.1     chr_9
                		h1tg000032l     NC_000010.1     chr_10
                		h1tg000030l     NC_000011.1     chr_11
                		h1tg000001l     NC_000012.1     chr_12
                		h1tg000016l     NC_000013.1     chr_13
                		h1tg000008l     NC_000014.1     chr_14
                		h1tg000002l     NC_000015.1     chr_15
                		h1tg000018l     NC_000016.1     chr_16
                		h2tg000021l     NC_000017.1     chr_17
                		h1tg000036l     NC_000018.1     chr_18
                		h1tg000026l     NC_000019.1     chr_19
                		h2tg000012l_h2tg000034l NC_000020.1     chr_20
                		h1tg000021l     NC_000021.1     chr_21
                		h1tg000013l     NC_000022.1     chr_22
                		h1tg000012l     NC_000023.1     chr_23
                		h1tg000009l     NC_000024.1     chr_24
                		h2tg000007l_h2tg000031l NC_000025.1     chr_25
                		h1tg000025l     NC_000026.1     chr_26
                		h1tg000022l_h1tg000035l NC_000027.1     chr_27
                		h2tg000025l     NC_000028.1     chr_28
                		h1tg000011l     NC_000029.1     chr_X
                		h1tg000024l     NC_000030.1     chr_Y


	
6. Run Verkko-Fillet
	
	**run_verkko_fillet.sh**
	
        	Make the verkko-fillet environment is NOT activated before running this shell (you will see a pandas error)

        Flags:
        
        		--verkko_directory	       path to verkko directory -- example: /90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec/
        		--main_directory 	       path to general assembly directory -- example: /90daydata/ruminant_t2t/Gyr/assembly/
        		--rDNA_fasta 		       path to rDNA reference -- example: /90daydata/ruminant_t2t/Gyr/assembly/Cattle_rDNA.fasta
        		--ref_fasta 		           path to reference fasta -- example: /90daydata/ruminant_t2t/Gyr/assembly/ARS-UCD2.0_chr.fasta
        		--phase_datatype 	       type of phase data: trio_hic (Illumina Trio & Hi-C), hic (Hi-C only), or trio (Illumina Trio only) -- default: hic
            --exp_chr_num 		       expected number of chromosomes, including sex chromosomes (better to overshoot) -- default: 31
            --gaps 			           identify gaps -- need to run GraphAligner scripts before running (more details below) -- usually activated on a second run -- True or False
        		--mashmap_id_threshold 	   mashmap id threshold -- default: 95
        		--new_row		           add row/s to translation_hap* files via dictionary named 'dict' -- only needed when rerunning verkko-fillet and altering run_verkko_fillet.py
            					               Example (formatting is important): 
            					               '{"0": ["sire_compressed.k31.hapmer-0000251"], "1": ["NC_057420.1_chr_Y"], "2": ["39262963"], "3": ["7618728"]}'
        					
                                			   For multiple rows make lists: 
                                        		
                                        	   '{"0": "[sire_compressed.k31.hapmer-0000251", "dam_compressed.k31.hapmer-0000061"], "1": ["NC_057420.1_chr_Y", "NC_086750.1_chr_28"], "2": ["39262963", "3489556"], "3": ["7618728", "45672686"]}'				
        	


        In-house output files:
            
            - translation_hap1/2_original                                   the original translations created by Verkko-Fillet
            - rDNA_utigs_ids_Bandage.txt                                    list of rDNA associated utig4s that can be copied and used in Bandage
            - contigPlot.df.tsv                                             dataframe used for contigPlot.png
            - chromosome_assignment/translation_hap1/2                      final translation lists
            - chromosome_assignment/translation_merged.tsv                  compiled table of contigs associated with a chromosome, contig, scaffold, telomere, or gap
            - chromosome_assignment/utig_contig_chr_path_translation.tsv    compiled table of all contigs
            - chromosome_assignment/contigPlot.png                          heatmap version of the translation_merged.tsv
            - chromosome_assignment/translation_merged_summary.tsv          summary of the number of contigs, scaffolds, telomeres, and gaps for each haplotype
            


7. Check .std file for T2T contigs/scaffolds not associated with a chromosome

    Look for something like this in the .std file:

        	check T2T ctgs and scfs
        	WARNING: not all T2T ctgs/scfs are associated with a chromosome
        	Update translation files, then remerge
        	                                 index  chr  length  ref length  ctgs  scfs  telomeres  gaps      utig4
        	68   dam_compressed.k31.hapmer-0000018  NaN     NaN         NaN   NaN   1.0   2.0   NaN   utig4-70
        	70  sire_compressed.k31.hapmer-0000246  NaN     NaN         NaN   1.0   1.0   2.0   NaN  utig4-174


	Check mashmap.out file for associated chromosome (found in verkko_fillet_directory/chromosome_assignment/)

	Rerun Verkko-Fillet with --new_row flag in **run_verkko_fillet.sh**

        - Formatting is important
        - Columns represent mashmap column 0, 1, 5, and 6

            Example for a single row:

                '{"0": "dam_compressed.k31.hapmer-0000018", "1": "NC_057420.1_chr_12", "2": "39262963", "3": "7618728"}'

            Example for multiple rows:

                '{"0": ["dam_compressed.k31.hapmer-0000018", "sire_compressed.k31.hapmer-0000246"], "1": ["NC_057420.1_chr_12", "NC_057445.1_chr_Y"], "2": ["39262963", "4565754"], "3": ["7618728", "5891353"]}'


    So Verkko-Fillet does not overwrite these changes, modify **run_verkko_fillet.py**

        - Hash out:
                vf.tl.getT2T(obj)
                vf.tl.rmrDNA(obj, rDNA_sequence=args.rDNA_fasta)
                vf.tl.convertRefName(args.ref_fasta, map_file, out_fasta="converted_reference")
                vf.tl.chrAssign(obj = obj, ref = "converted_reference", datatype=args.phase_datatype, chr_num=args.exp_chr_num, id_thr=args.mashmap_id_threshold)
                

    After rerunning, check .std and verkko_fillet_directory/chromosome_assignment/translation_merged.tsv for corrections.



8. Check .std file for duplicate contigs

	Look for something like this (this error will not stop Verkko-Fillet):

        	haplotype 1
        	found duplicate contigs
        			     0                   1         2         3
        	29  haplotype1-0000035  NC_000025.1_chr_25  77565123  64965115
        	32  haplotype1-0000004  NC_000027.1_chr_27  30506437  65108066
        	33  haplotype1-0000035  NC_000027.1_chr_27  77565123  65108066
        	multiple duplicates
        	ERROR: more than 2 contigs share same name
        	check verkko-fillet/chromosome_assignment/translation files for duplicates
        	remove unnecessary rows and rerun verkko-fillet after chrAssign

	
	Check out verkko_fillet_directory/chromosome_assignment/translation_hap files and mashmap.out.
	
	Maually remove row if necessary from translation_hap files.

    So Verkko-Fillet does not overwrite your changes, modify **run_verkko_fillet.py**
	
        	- Hash out:
            vf.tl.getT2T(obj)
            vf.tl.rmrDNA(obj, rDNA_sequence=args.rDNA_fasta)
            vf.tl.convertRefName(args.ref_fasta, map_file, out_fasta="converted_reference")
            vf.tl.chrAssign(obj = obj, ref = "converted_reference", datatype=args.phase_datatype, chr_num=args.exp_chr_num, id_thr=args.mashmap_id_threshold)
            
	After rerunning, check .std and verkko_fillet_directory/chromosome_assignment/translation_merged.tsv for corrections.



9. Check .std file for duplicate chromosomes

	Look for something like this (this warning will not stop Verkko-Fillet):

        	translation_hap2
        	WARNING: NC_030825.1_chr_18 may have contig issues
        	check verkko-fillet/chromosome_assignment/translation files for duplicates
        	remove unnecessary rows and rerun verkko-fillet after chrAssign

	
	Check out verkko_fillet_directory/chromosome_assignment/translation_hap files and mashmap.out
    
    Maually remove row if necessary from translation_hap files.

    So Verkko-Fillet does not overwrite your changes, modify **run_verkko_fillet.py**
	
        	- Hash out:
            vf.tl.getT2T(obj)
            vf.tl.rmrDNA(obj, rDNA_sequence=args.rDNA_fasta)
            vf.tl.convertRefName(args.ref_fasta, map_file, out_fasta="converted_reference")
            vf.tl.chrAssign(obj = obj, ref = "converted_reference", datatype=args.phase_datatype, chr_num=args.exp_chr_num, id_thr=args.mashmap_id_threshold)



10. For select assemblies, find gaps

    cd verkko_directory

        mkdir 8-manualResolution (name formatting is important)
        
        	cd 8-manualResolution/
	
            	ln -s ../3-align/split .

            	**graphalign_index.sh**
	
                	- change 'SBATCH --chdir=/verkko2.2.1_hifi-duplex_tporec/8-manualResolution/' to your verkko directory
                	
            	**graphalign_align.sh**
            	
                	- change 'SBATCH --chdir=/verkko2.2.1_hifi-duplex_tporec/8-manualResolution/' to your verkko directory
                	- change '#SBATCH --array=1-198' to match the number of aligned files in the split folder
    
        
            	-after running both Bash files, concatenate all GAF files (file name is important)
                	
                	cat ont*.gaf > verkko.graphAlign_allONT.gaf



11. Rerun Verkko-Fillet for gap data

    So Verkko-Fillet does not overwrite your changes, modify **run_verkko_fillet.py**
    
        - hash out everything above "if args.gaps == 'True':" except Chromosome assignment section where it looks for the chromosome.map file

        	- remove --new_row flag if used in step 7

        	- mark --gaps flag as True

        	- In-house outputs (verkko_fillet_directory/graphAlignment/):	
            	
            	- verkko_initial_gaps.csv 		    table with detailed gap information
			- verkko_edited_initial_gaps.csv 	table with gapId and gaps - easy copy for node_list_input



12. Rerunning Verkko-Fillet and the symlinks are missing from the original run

    Near the top of **run_verkko_fillet.py**, there is a function called *check_symlinks(verkkoDir)* that will look and grab the missing symlinks.
    
    
    
13. Join assembly heatmaps into single file

    **join_VF_pngs_tables.py**

    If you have multiple assemblies and want to easily view all the heatmaps at once. 

