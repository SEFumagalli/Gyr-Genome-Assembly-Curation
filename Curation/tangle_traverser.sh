#!/bin/bash -l

#created by Sarah E. Fumagalli

#SBATCH --job-name=TTT
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=8000
#SBATCH --partition=ceres
#SBATCH --time=2:00:00
#SBATCH --chdir=/assembly/verkko2.2.1_hifi-duplex_tporec/8-manualResolution/tangle_traverser/
#SBATCH --output=TTT__%j.std
#SBATCH --error=TTT__%j.err

date

## ----------------------------------------------------------------------------------------------------------------------------------
## 
## For help run ./tangle_traverer.py --help
## Requires pulp, ahocorasick, networkx, statistics, logging python libraries.
##
## Required Arguments:
## 	--graph: Path to the GFA file with the graph structure
##	--alignment: Path to a file with GraphAligner alignment
##
##	Instead of those two options one can use --verkko-output <verkko output directory>. 
##	In this case internal verkko files for HiFi graph, coverage (ONT) and ONT alignments would be used.
##
##	--outdir Output directory
##
##	--boundary-nodes <boundary_nodes_file> to locate tangle. 
##
##	boundary_nodes_file should contain tab separated pairs of incoming and outgoing boundary nodes, one pair by line. 
##	Also they should be non-repetive and heterozygous in case of 'diploid' tangles. 
##	Boundary nodes should completely separate the tangle from the rest of the graph 
##		— after their removal there should be no path in remaining graph between tangle nodes and any other non-tangle nodes. 
##		-Example: separate by a single tab
##			utig4-123	utig4-456
##		
##		-If two haplotypes surround the tangle/gap
##			utig4-123	utig4-456
##			utig4-789	utig4-101
##		
##------------------------------------------------------------------------------------------------------------------------------------

assembly="/assembly/verkko2.2.1_hifi-duplex_tporec"
main_dir="/assembly"


module load glpk


micromamba activate tangle_traverser

## Using utig4 graph ----------------------------------------------------------------------------------------
#	Before running you will need to make sure you have created these files:

#	1) utig4_upt.ont-coverage.csv

#python3 /project/cattle_genome_assemblies/packages/TTT-master/verkko_coverage_fix/utig4_coverage_updater.py $assembly/utig4_2_utig1 $assembly/assembly.homopolymer-compressed.noseq.gfa $assembly/2-processGraph/unitig-unrolled-hifi-resolved.ont-coverage.csv > $assembly/utig4_upt.ont-coverage.csv

#	2) verkko.graphAlign_allONT.gaf
#		-if verkko-fillet has already been run on your assembly, this file should be located in the 8-manualResolution folder of your verkko assembly
#		-if not, follow these steps (also listed in /project/cattle_genome_assemblies/config_files_scripts/verkko-fillet/README_verkko-fillet on Ceres - step 9)
#			cd verkko_directory
#
#        		mkdir 8-manualResolution (name formatting is important)
#        
#			cd 8-manualResolution/
#	
#			ln -s ../3-align/split .
#
#		        cp /project/cattle_genome_assemblies/config_files_scripts/verkko-fillet/graphalign_index.sh .
#        
#			cp /project/cattle_genome_assemblies/config_files_scripts/verkko-fillet/graphalign_align.sh .
#
#			- for both sh files, change 'SBATCH --chdir=/90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec/8-manualResolution/' to your verkko directory
#		        - change '#SBATCH --array=1-198' in graphalign_align.sh, to match the number of aligned files in the split folder
#		        - run graphalign_index.sh
#		        - run graphalign_align.sh
#        
#			cat ont*.gaf > verkko.graphAlign_allONT.gaf


# Manual method
#ONT
python3 TTT.py \
	--graph assembly.homopolymer-compressed.noseq.gfa \
	--alignment /8-manualResolution/verkko.graphAlign_allONT.gaf \
	--boundary-nodes <boundaries_file> \
	--coverage utig4_upt.ont-coverage.csv \
	--outdir <output directory name>


#HiFi	
python3 TTT.py \
    --graph /2-processGraph/unitig-unrolled-hifi-resolved.gfa \
    --alignment /3-align/alns-ont.gaf \
    --boundary-nodes <boundaries_file> \
    --coverage 2-processGraph/unitig-unrolled-hifi-resolved.ont-coverage.csv \
    --outdir <output directory name>



date
