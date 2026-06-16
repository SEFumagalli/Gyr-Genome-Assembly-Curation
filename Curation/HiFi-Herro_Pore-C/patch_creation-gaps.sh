#created by Sarah E. Fumagalli


## This script describes the steps taken to fix a single tangle near a telomere in an alternate assembly to use as a patch for my curated assembly


patch_dir="project/ruminant_t2t/Gyr/new_assemblies/verkko2.2.1_hifi-herro_porec/8-manualResolution/assembly_patch"
verkko_dir="project/ruminant_t2t/Gyr/new_assemblies/verkko2.2.1_hifi-herro_porec"
verkko_fillet_dir="project/ruminant_t2t/Gyr/new_assemblies/verkko2.2.1_hifi-herro_porec_verkko_fillet"

## --------------------------------------------------------------------------------------------------------------------------------------------

## Gap fixed for hap2 chr 7
 

	Find each gap in Bandage - multiple gaps may be located near one another -> use ; between names

	Place gap_fixes.txt in your patch_dir - see /90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-herro_porec/8-manualResolution/verkko2.2.1_hifi-herro_porec_patch/gaps/gap_fixes.txt


	Determine best path by using these files and tool: 
	     - $verkko_dir/8-manualResolution/verkko.graphAlign_allONT.gaf
	     - $verkko_dir/assembly.homopolymer-compressed.noseq.telo_rdna.gfa
	     - $verkko_dir/assembly.colors.csv
	     - $verkko_dir/assembly.colors.telo_rdna.csv
	     - $verkko_dir/assembly.homopolymer-compressed.chr.csv
	     - $verkko_dir/2-processGraph/unitig-unrolled-hifi-resolved.noseq.gfa
	     - $verkko_dir/3-align/alns-ont.gaf
	     - $verkko_fillet_dir/graphAlignment/verkko_initial_gaps.csv
	     - tangle_traverser.sh
		- tool that helps navigate tangles/gaps using the utig4 or/and utig1 graphs
		- https://github.com/marbl/TTT
		- /project/cattle_genome_assemblies/packages/TTT



## Identify gap nodes in Bandage
	
	1) Open Bandage and load $verkko_dir/assembly.homopolymer-compressed.noseq.telo_rdna.gfa

	
	2) Find path associated with gap 

		grep utig4-3432 assembly.path.tsv

			haplotype2_from_utig4-279       utig4-2295+,utig4-5074+,utig4-1200-,utig4-1199-,utig4-282-,utig4-278-,utig4-279+,utig4-2346+,utig4-1931-,utig4-1930+,
			utig4-1510-,utig4-1509+,utig4-463-,utig4-461+,utig4-464+,utig4-1125-,utig4-1127+,utig4-5912-,utig4-5548-,utig4-5546-,utig4-605-,utig4-602-,utig4-603+,
			utig4-3708+,utig4-2353-,utig4-2352+,utig4-2033-,utig4-2031-,utig4-1123-,utig4-1122-,utig4-949-,utig4-945-,utig4-946+,utig4-5828+,utig4-5829+,utig4-5833-,
			utig4-3124-,utig4-3119-,[N5000N:ambig_path],utig4-3121+,utig4-2555-,[N77021N:tangle],utig4-1385-,[N429484N:tangle],utig4-2858-,[N5000N:ambig_path],
			utig4-2118+,utig4-2121+,utig4-4357+,utig4-3162-,utig4-3160+,[N15034N:scaffold],utig4-3432+	
			

			This path contains 5 gaps
			
			We are only fixing the one closest to utig4-3432

			gapid_51 ['utig4-3160', 'utig4-3432']


	3) Using the verkko.graphAlign_allONT.gaf alignments, choose a path through the tangle

		One path connects utig4-3432 to utig4-3162 all the way through

		<utig4-3432<utig4-3168<utig4-3160<utig4-3151>utig4-3142>utig4-3154<utig4-3160<utig4-3151>utig4-3142>utig4-3154<utig4-3160<utig4-3151>utig4-3142>utig4-3154
		<utig4-3160<utig4-3151>utig4-3142>utig4-3154<utig4-3160<utig4-3151>utig4-3142>utig4-3154<utig4-3160<utig4-3151>utig4-3142>utig4-3154<utig4-3160<utig4-3151>utig4-3142>utig4-3154<utig4-3160>utig4-3162



	4) Clean up path for Bandage
		
		py file can be found /project/cattle_genome_assemblies/config_files_scripts/Sarah_scripts/asm-path-translate-printout-Bandage.py in verkko-fillet folder

			- this script can handle path formatting containing </>

		python3 asm-path-translate-printout-Bandage.py '<utig4-3432<utig4-3168<utig4-3160<utig4-3151>utig4-3142>utig4-3154<utig4-3160<utig4-3151>utig4-3142>utig4-3154<utig4-3160<utig4-3151>utig4-3142>utig4-3154                                                                     <utig4-3160<utig4-3151>utig4-3142>utig4-3154<utig4-3160<utig4-3151>utig4-3142>utig4-3154<utig4-3160<utig4-3151>utig4-3142>utig4-3154<utig4-3160<utig4-3151>utig4-3142>utig4-3154<utig4-3160>utig4-3162'
	
		Converted path:
		utig4-3432,utig4-3168,utig4-3160,utig4-3151,utig4-3142,utig4-3154,utig4-3160,utig4-3151,utig4-3142,utig4-3154,utig4-3160,utig4-3151,utig4-3142,utig4-3154,utig4-3160,
		utig4-3151,utig4-3142,utig4-3154,utig4-3160,utig4-3151,utig4-3142,utig4-3154,utig4-3160,utig4-3151,utig4-3142,utig4-3154,utig4-3160,utig4-3151,utig4-3142,utig4-3154,utig4-3160,utig4-3162
	


	5) Highlight nodes in Bandage
		
	
	5) Identify utig1 graph nodes (many not be necessary)
	
		utig1 graph was much more complicated and tangled

	

		

## Check the direction of your path in Bandage

	if your manual or TTT path uses >/<, these will need to be changed to the +/- format

	python3 /project/cattle_genome_assemblies/config_files_scripts/verkko-fillet/asm-path-translate-printout-reverse.py '<utig4-3432<utig4-3168<utig4-3160<utig4-3151>utig4-3142>utig4-3154<utig4-3160
	<utig4-3151>utig4-3142>utig4-3154<utig4-3160<utig4-3151>utig4-3142>utig4-3154<utig4-3160<utig4-3151>utig4-3142>utig4-3154<utig4-3160<utig4-3151>utig4-3142>utig4-3154<utig4-3160<utig4-3151
	>utig4-3142>utig4-3154<utig4-3160<utig4-3151>utig4-3142>utig4-3154<utig4-3160>utig4-3162'

	Translated >/< path:
 	utig4-3432-,utig4-3168-,utig4-3160-,utig4-3151-,utig4-3142+,utig4-3154+,utig4-3160-,utig4-3151-,utig4-3142+,utig4-3154+,utig4-3160-,utig4-3151-,utig4-3142+,utig4-3154+,utig4-3160-,utig4-3151-,utig4-3142+,
	utig4-3154+,utig4-3160-,utig4-3151-,utig4-3142+,utig4-3154+,utig4-3160-,utig4-3151-,utig4-3142+,utig4-3154+,utig4-3160-,utig4-3151-,utig4-3142+,utig4-3154+,utig4-3160-,utig4-3162+



# Convert final paths in gap_fixes.txt to correct patch format (from -/+ to </>) for verkko

	cp 
	
	cd verkko2.2.1_hifi-herro_porec_patch

	vi gap_fixes.txt

		add gap name to row and path on next row

		gapid_51
		<utig4-3432<utig4-3168<utig4-3160<utig4-3151>utig4-3142>utig4-3154<utig4-3160<utig4-3151>utig4-3142>utig4-3154<utig4-3160<utig4-3151>utig4-3142>utig4-3154<utig4-3160<utig4-3151>utig4-3142
		>utig4-3154<utig4-3160<utig4-3151>utig4-3142>utig4-3154<utig4-3160<utig4-3151>utig4-3142>utig4-3154<utig4-3160<utig4-3151>utig4-3142>utig4-3154<utig4-3160>utig4-3162


        run reformat_gapfixes_to_patches.sh

        python3 /project/cattle_genome_assemblies/config_files_scripts/verkko-fillet/reformat_gapfixes_to_patches.py --gap_fixes gap_fixes.txt --initial_gaps verkko_initial_gaps.csv

        output file name: converted_gap_fixes.tsv



# Manually (semi-automatic with below script) edit gap patch files

	unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.paths.gaf is not found in non-trio assemblies (6-rukki - if trio).

	8-hicPipeline/rukki.paths.gaf can be used instead.

        Script can be found in Lee Ackerson github (https://github.com/LeeAckersonIV/genome-asm/tree/main/helper-scripts) or /project/cattle_genome_assemblies/config_files_scripts/verkko-fillet/addPatch.pl

        module load perl

        perl /project/cattle_genome_assemblies/config_files_scripts/verkko-fillet/addPatch.pl --gaf rukki.paths.gaf --patch converted_gap_fixes.tsv > gap.paths.gaf	

		
