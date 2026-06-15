#created by Sarah E. Fumagalli

patch_dir="/assembly/verkko2.2.1_hifi-duplex_tporec/8-manualResolution/gaps"
verkko_dir="/assembly/verkko2.2.1_hifi-duplex_tporec"
verkko_fillet_dir="/assembly/verkko2.2.1_hifi-duplex_tporec_verkko_fillet"

## --------------------------------------------------------------------------------------------------------------------------------------------

1. Find gap list in verkko2.2.1_hifi-duplex_tporec_verkko_fillet/graphAlignment/verkko_edited_initial_gaps.csv

    The Gyr has 42 gaps identified by Verkko and Verkko-Fillet.
 
 	gapId		gaps
	gapid_0		['utig4-1179', 'utig4-2384']
	gapid_1		['utig4-2463', 'utig4-2323']
	gapid_2		['utig4-2363', 'utig4-2496']
	gapid_3		['utig4-2500', 'utig4-273']
	gapid_4		['utig4-1917', 'utig4-1807']
	gapid_5		['utig4-705', 'utig4-2425']
	gapid_6		['utig4-2425', 'utig4-1532']
	gapid_7		['utig4-376', 'utig4-378']
	gapid_8		['utig4-1371', 'utig4-1369']
	gapid_9		['utig4-2374', 'utig4-315']
	gapid_10	['utig4-1363', 'utig4-443']
	gapid_11	['utig4-443', 'utig4-2489']
	gapid_12	['utig4-1928', 'utig4-1473']
	gapid_13	['utig4-613', 'utig4-2485']
	gapid_14	['utig4-748', 'utig4-751']
	gapid_15	['utig4-2206', 'utig4-2266']
	gapid_16	['utig4-816', 'utig4-2468']
	gapid_17	['utig4-2200', 'utig4-1215']
	gapid_18	['utig4-1215', 'utig4-1831']
	gapid_19	['utig4-1831', 'utig4-2168']
	gapid_20	['utig4-808', 'utig4-1535']
	gapid_21	['utig4-376', 'utig4-378']
	gapid_22	['utig4-2010', 'utig4-1772']
	gapid_23	['utig4-2206', 'utig4-2266']
	gapid_24	['utig4-1346', 'utig4-1342']
	gapid_25	['utig4-1342', 'utig4-1523']
	gapid_26	['utig4-1669', 'utig4-1351']
	gapid_27	['utig4-1352', 'utig4-1893']
	gapid_28	['utig4-2396', 'utig4-2170']
	gapid_29	['utig4-2170', 'utig4-2255']
	gapid_30	['utig4-2401', 'utig4-2482']
	gapid_31	['utig4-2480', 'utig4-2427']
	gapid_32	['utig4-2427', 'utig4-1288']
	gapid_33	['utig4-2023', 'utig4-1389']
	gapid_34	['utig4-1543', 'utig4-1552']
	gapid_35	['utig4-1411', 'utig4-929']
	gapid_36	['utig4-1873', 'utig4-2111']
	gapid_37	['utig4-2430', 'utig4-2440']
	gapid_38	['utig4-2375', 'utig4-1854']
	gapid_39	['utig4-2389', 'utig4-2340']
	gapid_40	['utig4-621', 'utig4-2477']
	gapid_41	['utig4-2477', 'utig4-49']



2. Files needed for gap investigation

        mkdir $patch_dir && cd $patch_dir

	Determine best path by using these files: 
    
        - ln -s $verkko_dir/8-manualResolution/verkko.graphAlign_allONT.gaf
        - ln -s $verkko_dir/assembly.homopolymer-compressed.noseq.telo_rdna.gfa
        - ln -s $verkko_dir/assembly.colors.csv
	    - ln -s $verkko_dir/assembly.colors.telo_rdna.csv
	    - ln -s $verkko_dir/assembly.homopolymer-compressed.chr.csv
	    - ls -s $verkko_dir/2-processGraph/unitig-unrolled-hifi-resolved.noseq.gfa
	    - ls -s $verkko_dir/3-align/alns-ont.gaf
	    - ls -s $verkko_fillet_dir/graphAlignment/verkko_initial_gaps.csv
	


	
3. Visualize each gap in Bandage

    Find each gap in Bandage - multiple gaps may be located near one another.
    
    This will give us a general idea of the gap and how complex they are.
    
    	Open Bandage and load $verkko_dir/assembly.homopolymer-compressed.noseq.telo_rdna.gfa
    	
        - Load assembly.colors.csv
        - Under Tools tab, in Settings check ON for Arrowheads in single node style under Graph appearance
        - Click Draw Graph
        - Load assembly.colors.telo_rdna.csv
        - Load assembly.homopolymer-compressed.chr.csv
        - Change the 3rd dropdown under Graph display from Color by CSV column to Custom colours
        - Increase the font size, select Name, select Depth under Node Labels on the lefthand side

    	
    	Find path associated with gap 

        - Example
    
            grep utig4-1179 assembly.path.tsv

    			
    			dam_compressed.k31.hapmer_from_utig4-1179       
            utig4-1179+,[N5000N:ambig_path],utig4-2384+,utig4-2385+,utig4-2474+,utig4-2464-,utig4-2463+,
    			[N24833N:ambig_bubble],utig4-2323+,utig4-2327+,utig4-2387+,utig4-2364-,utig4-2363+,
    			[N306434N:ambig_bubble],utig4-2496-,utig4-2498+,utig4-2500+,[N310403N:ambig_bubble],utig4-273+,utig4-276+   


        - This path contains 4 gaps

            gapid_0         ['utig4-1179', 'utig4-2384']
            gapid_1         ['utig4-2463', 'utig4-2323']
            gapid_2         ['utig4-2363', 'utig4-2496']
            gapid_3         ['utig4-2500', 'utig4-273']


    	Clean up path for Bandage
    		
    		asm-path-translate-printout-Bandage.py
    		
    		- This script can also handle path formatting containing </>.

        - Example
    		
        		python3 asm-path-translate-printout-Bandage.py 'utig4-1179+,[N5000N:ambig_path],utig4-2384+,utig4-2385+,utig4-2474+,utig4-2464-,utig4-2463+,[N24833N:ambig_bubble],utig4-2323+,utig4-2327+,utig4-			2387+,utig4-2364-,utig4-2363+,[N306434N:ambig_bubble],utig4-2496-,utig4-2498+,utig4-2500+,[N310403N:ambig_bubble],utig4-273+,utig4-276+'
    	
    	
            	Converted path:utig4-1179+,utig4-2384+,utig4-2385+,utig4-2474+,utig4-2464-,utig4-2463+,utig4-2323+,utig4-2327+,utig4-2387+,utig4-2364-,utig4-2363+,utig4-2496-,utig4-2498+,utig4-2500+,utig4-273+,utig4-276+
    	

    	Highlight nodes in Bandage
    		
        - highlight 'Converted path' output and copy into Bandage on the upper right under Find nodes 1st row 
        
        - zoom into the area and move around the nodes so that all the gaps can be seen

        -Example    		
        
            - this section of the graph shows many nodes in a loop
        		- some nodes ~35x and some ~60x
    			- the nodes with the higher coverage are expected to be used each time the loop is passed
    			- the nodes with the lower coverage are expected to be used only once 
    		

    	
4. Trivial Tangle Traverser tool (TTT)

    Download [Trivial Tangle Traverser](https://github.com/marbl/TTT)
	
    Identify boundary nodes of the gap
    
        - boundaries should be from a single haplotype
	
        - if both haplotypes exist as boundaries, include both in the boundaries file as two rows and two columns


    Set up directory and input files
		
		mkdir tangle_traverser && cd tangle_traverser
		
		tangle_traverser.sh

            - Before running you will need to make sure you have created these files:

                utig4_2_utig1

                    python3 utig4_to_utig1.py $verkko_dir > utig4_2_utig1

                utig4_upt.ont-coverage.csv
				
        				python3 utig4_coverage_updater.py $assembly/utig4_2_utig1 $assembly/assembly.homopolymer-compressed.noseq.gfa $assembly/2-processGraph/unitig-unrolled-hifi-resolved.ont-coverage.csv > utig4_upt.ont-coverage.csv

                verkko.graphAlign_allONT.gaf
		
                    see Verkko-Fillet README.md for details on how to create this file        				

		
    Identify utig1 graph nodes (many not be necessary)
	
        Using the utig4_2_utig1 files, we can find the associated utig1s with each utig4 in our path

            - Example
		
            		grep utig4-1179 utig4_2_utig1

                
                <utig1-896<utig1-893_2>utig1-895<utig1-7128_2>utig1-7130>utig1-11003_1<utig1-10069<utig1-10066_2>utig1-10068>utig1-12123_1>utig1-12124>utig1-12456_2
                >utig1-12458>utig1-15852_1>utig1-15853<utig1-17230_1<utig1-5338>utig1-5339<utig1-16809<utig1-6027<utig1-6025>utig1-6024_2>utig1-12286_2>utig1-12289
                >utig1-12732_2<utig1-7322<utig1-7318_1>utig1-7319<utig1-16531<utig1-10642>utig1-10641_1<utig1-8181<utig1-8178_1>utig1-8179>utig1-12901_2<utig1-12539
                >utig1-12538_1>utig1-12540>utig1-13683_1>utig1-13684>utig1-15333_1<utig1-9803<utig1-9801_2<utig1-5784>utig1-5783_1<utig1-4587>utig1-4585_2>utig1-4589
                >utig1-13007_2<utig1-12520>utig1-12518_2<utig1-9644>utig1-9643_1<utig1-8027<utig1-8025_2<utig1-6885<utig1-6882_1>utig1-6883<utig1-16613_2>utig1-16615
                <utig1-16613_1>utig1-16614<utig1-17197<utig1-16186 

		
        Translate utig1 path into a Bandage formatted path

            - Example
            
                python3 asm-path-translate-printout-Bandage.py '<utig1-896<utig1-893_2>utig1-895<utig1-7128_2
                >utig1-7130>utig1-11003_1<utig1-10069<utig1-10066_2>utig1-10068>utig1-12123_1>utig1-12124>utig1-12456_2>utig1-12458>utig1-15852_1>utig1-15853<utig1-17230_1
                <utig1-5338>utig1-5339<utig1-16809<utig1-6027<utig1-6025>utig1-6024_2>utig1-12286_2>utig1-12289>utig1-12732_2<utig1-7322<utig1-7318_1>utig1-7319<utig1-16531
                <utig1-10642>utig1-10641_1<utig1-8181<utig1-8178_1>utig1-8179>utig1-12901_2<utig1-12539>utig1-12538_1>utig1-12540>utig1-13683_1>utig1-13684>utig1-15333_1
                <utig1-9803<utig1-9801_2<utig1-5784>utig1-5783_1<utig1-4587>utig1-4585_2>utig1-4589>utig1-13007_2<utig1-12520>utig1-12518_2<utig1-9644>utig1-9643_1
                <utig1-8027<utig1-8025_2<utig1-6885<utig1-6882_1>utig1-6883<utig1-16613_2>utig1-16615<utig1-16613_1>utig1-16614<utig1-17197<utig1-16186'	

                
                Converted path:utig1-896,utig1-893,utig1-895,utig1-7128,utig1-7130,utig1-11003,utig1-10069,utig1-10066,utig1-10068,utig1-12123,utig1-12124,utig1-12456,utig1-12458,
                utig1-15852,utig1-15853,utig1-17230,utig1-5338,utig1-5339,utig1-16809,utig1-6027,utig1-6025,utig1-6024,utig1-12286,utig1-12289,utig1-12732,utig1-7322,
                utig1-7318,utig1-7319,utig1-16531,utig1-10642,utig1-10641,utig1-8181,utig1-8178,utig1-8179,utig1-12901,utig1-12539,utig1-12538,utig1-12540,utig1-13683,
                utig1-13684,utig1-15333,utig1-9803,utig1-9801,utig1-5784,utig1-5783,utig1-4587,utig1-4585,utig1-4589,utig1-13007,utig1-12520,utig1-12518,utig1-9644,
                utig1-9643,utig1-8027,utig1-8025,utig1-6885,utig1-6882,utig1-6883,utig1-16613,utig1-16615,utig1-16613,utig1-16614,utig1-17197,utig1-16186

		
            - since there are many more utig1 nodes, I usually find the last one - utig1-16186

            - open a new Bandage and load $verkko_dir/2-processGraph/unitig-unrolled-hifi-resolved.noseq.gfa
            
                - if this file does not exist, make it:
                
                    cat $verkko_dir/2-processGraph/unitig-unrolled-hifi-resolved.gfa | awk '{if (match($1, "^S")) print $1"\t"$2"\t*\tLN:i:"length($3); else print $0}' > $verkko_dir/2-processGraph/unitig-unrolled-hifi-resolved.noseq.gfa
		
        		- highlight the 'Converted path' and copy into Bandage - color nodes on the bottom right
		



5. Initiate gapid_patches.tsv

    This file will keep track of the gapid, contig/hapmer name, and patch.
    
    Each patch is on its own row with a tab between the contig/hapmer name and the patch.
    
        - Example
        
            gapid_0-3 - dam_compressed.k31.hapmer_from_utig4-1179   utig4-1179+,utig4-2384+,utig4-2385+,utig4-2474+,utig4-2464-,utig4-2463+,utig4-2324-,utig4-2323+,utig4-2326+,utig4-2387+,utig4-2365-,utig4-2363+,utig4-2367+,utig4-2496-,utig4-2498+,utig4-2500+,utig4-275-,utig4-273+,utig4-277+, utig4-2384+,utig4-2386+,utig4-2474+,utig4-2465-,utig4-2463+,utig4-2325-,utig4-2323+,utig4-2327+,utig4-2387+,utig4-2364-,utig4-2363+,utig4-2366+,utig4-2496-,utig4-2497+,utig4-2500+,utig4-274-,utig4-273+

            gapid_4 - dam_compressed.k31.hapmer_from_utig4-1193     utig4-1917+,utig4-1942-,utig4-1942-,utig4-1807-

            gapid_5;gapid_6 - dam_compressed.k31.hapmer_from_utig4-1532     <utig4-705>utig4-694>utig4-694>utig4-694>utig4-694>utig4-706<utig4-2425<utig4-2424<utig4-2291>utig4-2290>utig4-2293>utig4-2335>utig4-2336<utig4-2424<utig4-2292>utig4-2290>utig4-2294>utig4-2335<utig4-1532<utig4-1531

            gapid_7 - dam_compressed.k31.hapmer_from_utig4-1704     utig4-376-,utig4-377+,utig4-378+


    A contig/hamper may include multiple patches consisting of utig4 and utig1 paths.
    
        - use : to split patches
        
        - Example 

            gapid_10;gapid_11;gapid_43 - dam_compressed.k31.hapmer_from_utig4-734   utig4-1363+,utig4-445-,utig4-443+,utig4-447+,utig4-2489-,utig4-2491+,utig4-1667-,utig4-1665-,utig4-1365-,utig4-1363+,utig4-444-,utig4-443+,utig4-446+,utig4-2489-,utig4-2490+,utig4-1667-,utig4-1665-,utig4-1666+,utig4-2489-:<utig1-5736>utig1-5734<utig1-17176<utig1-16401<utig1-16399<utig1-5394>utig1-522<utig1-520>utig1-521<utig1-4960>utig1-4962>utig1-16115>utig1-16114




6. Manual Curation

    For gaps that TTT could not resolve, use verkko.graphAlign_allONT.gaf (utig4 graph) and alns-ont.gaf (utig1 graph) to find read support.
    
    Attempt to walk-through a tangle with the utig4 graph by identifying the number of reads supporting each path.
    
    If the utig4 graph has poor or ambiguous read support, find those nodes in the utig1 graph. 
    
    If there is resolution, check the direction of your path in Bandage.

        - if your path uses >/<, these will need to be changed to the +/- format

            python3 asm-path-translate-printout-reverse.py '>utig4-1179>utig4-2384>utig4-2385
            >utig4-2474<utig4-2464>utig4-2463<utig4-2324>utig4-2323>utig4-2326>utig4-2387<utig4-2365>utig4-2363>utig4-2367<utig4-2496>utig4-2498>utig4-2500<utig4-275
            >utig4-273>utig4-277>utig4-2384>utig4-2386>utig4-2474<utig4-2465>utig4-2463<utig4-2325>utig4-2323>utig4-2327>utig4-2387<utig4-2364>utig4-2363>utig4-2366
            <utig4-2496>utig4-2497>utig4-2500<utig4-274>utig4-273>utig4-276'


            Translated >/< path:utig4-1179+,utig4-2384+,utig4-2385+,utig4-2474+,utig4-2464-,utig4-2463+,utig4-2324-,utig4-2323+,utig4-2326+,utig4-2387+,utig4-2365-,utig4-2363+,utig4-2367+,
            utig4-2496-,utig4-2498+,utig4-2500+,utig4-275-,utig4-273+,utig4-277+,utig4-2384+,utig4-2386+,utig4-2474+,utig4-2465-,utig4-2463+,utig4-2325-,utig4-2323+,
            utig4-2327+,utig4-2387+,utig4-2364-,utig4-2363+,utig4-2366+,utig4-2496-,utig4-2497+,utig4-2500+,utig4-274-,utig4-273+,utig4-276+


        - in Bandage under the Output tab, click Specify exact path for copy/save

            - copy the 'Translated path' and paste 
            - if a valid path, a green check will show 
            - if not a valid path, a red x will show 


    Detached telomeres can be treated as gaps

        - find telomere path and save as gap patch


    For gaps that are more difficult, such as completely disconnected nodes

        - if an alignment is needed between your gap and another assembly for example, you will end up with gaf files
        
        - the gap needs two associated files, one alignment from each side of the gap

        - see patch_creation-rDNA.sh or patch_creation-telo.sh for examples




7. Create final version of gapid_patches.tsv 

    final_gap_patches.tsv
    
        - remove 'gapid_0-3 - '
        - remove empty rows
        
        - Example 
        
            dam_compressed.k31.hapmer_from_utig4-1179       utig4-1179+,utig4-2384+,utig4-2385+,utig4-2474+,utig4-2464-,utig4-2463+,utig4-2324-,utig4-2323+,utig4-2326+,utig4-2387+,utig4-2365-,utig4-2363+,utig4-2367+,utig4-2496-,utig4-2498+,utig4-2500+,utig4-275-,utig4-273+,utig4-277+, utig4-2384+,utig4-2386+,utig4-2474+,utig4-2465-,utig4-2463+,utig4-2325-,utig4-2323+,utig4-2327+,utig4-2387+,utig4-2364-,utig4-2363+,utig4-2366+,utig4-2496-,utig4-2497+,utig4-2500+,utig4-274-,utig4-273+
            dam_compressed.k31.hapmer_from_utig4-1193       utig4-1917+,utig4-1942-,utig4-1942-,utig4-1807-
            dam_compressed.k31.hapmer_from_utig4-1532       <utig4-705>utig4-694>utig4-694>utig4-694>utig4-694>utig4-706<utig4-2425<utig4-2424<utig4-2291>utig4-2290>utig4-2293>utig4-2335>utig4-2336<utig4-2424<utig4-2292>utig4-2290>utig4-2294>utig4-2335<utig4-1532<utig4-1531
            dam_compressed.k31.hapmer_from_utig4-1704       utig4-376-,utig4-377+,utig4-378+



8. Insert patches into paths and update files for final verkko run

    patch_2_path.sh

        python3 update_patch_2_path.py --utig4s /8-hicPipeline/rukki.paths.tsv --patches /8-manualResolution/gaps/final_gap_patches.tsv    

        Output file name: patches_2_final_paths.tsv

        
        module load perl                                                                                                                                                                                                                                                                                                                                                                                                                  perl /project/cattle_genome_assemblies/config_files_scripts/verkko-fillet/addPatch.pl --gaf 8-hicPipeline/rukki.paths.gaf --patch 8-manualResolution/verkko2.2.1_hifi-duplex_tporec_patch/gaps/patches_2_final_paths.tsv --map utig4_2_utig1 --verbose > 8-manualResolution/verkko2.2.1_hifi-duplex_tporec_patch/gaps/gap.paths.gaf 2> 8-manualResolution/verkko2.2.1_hifi-duplex_tporec_patch/gaps/gap.paths.log

        perl addPatch.pl --gaf $verkko_dir/6-rukki/unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.paths.gaf --patch $patch_dir/gaps/patches_2_final_paths.tsv > gap.paths.gaf	
        
             - perl script created by Wen Huang and original can be found on Lee Ackersons github (https://github.com/LeeAckersonIV/genome-asm/tree/main/helper-scripts)

        Output file name: gap.paths.gaf
		
