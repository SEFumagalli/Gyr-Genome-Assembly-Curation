#!/bin/bash -l

#created by Sarah E. Fumagalli and Wen Huang - including several scripts from Lee Ackerson and Sergy Koren

#SBATCH --job-name=gap_patch_2_path
#SBATCH --cpus-per-task=96
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=3900
#SBATCH --partition=ceres
#SBATCH --time=5:00:00
#SBATCH --chdir=/assembly/verkko2.2.1_hifi-duplex_tporec/
#SBATCH --output=gap_patch_2_path__%j.std
#SBATCH --error=gap_patch_2_path__%j.err


## !!! see formatting details below for each script !!! ##

date

#verkko_dir/6-rukki/unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.paths.gaf or verkko_dir/8-hicPipeline/rukki.paths.gaf can be used as the reference to the original utig4 paths

python3 update_patch_2_path.py --utig4s 8-hicPipeline/rukki.paths.tsv --patches final_gap_patches.tsv

module load perl

awk 'NR==FNR {print $1 "\t" $2; next;} { n = split($2, nodes, /[<>[\]]/); for (i=1; i<=n; i++) if (nodes[i] ~ /^utig4-/) print nodes[i] "\t>" nodes[i]; }' 8-hicPipeline/rukki.paths.gaf 8-hicPipeline/rukki.paths.gaf | sort | uniq | python3 get_utig1_from_utig4.py 6-layoutContigs/combined-nodemap.txt 6-layoutContigs/combined-edges.gfa /dev/stdin 6-layoutContigs/nodelens.txt > utig4-utig1.map

perl addPatch.pl --gaf 8-hicPipeline/rukki.paths.gaf --patch patches_2_final_paths.tsv --map utig4-utig1.map --verbose > gap.paths.gaf 2> gap.paths.log

date


## update_patch_2_path.py
## ---------------------------------------------------------------------------------------------------------------------------------------------
## This script converts utig4s into utig1s - flips paths and cleans up formatting as needed
##
## Set working directory as your verkko assembly folder
##
## Input
##
##  --utig4s
##
##      Assemblies phased with trio: yourOriginalAssembly/6-rukki/unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.paths.tsv
##	Assemblies phased without trio: yourOriginalAssembly/8-hicPipeline/rukki.paths.tsv
##
##
##  --patches
##
##      patches file formatting example - include <hapmer_name> !tab! <overlap_patch_overlap>
##
##      sire_compressed.k31.hapmer_from_utig4-1772   utig4-2010-,utig4-2008-,utig4-2009+,utig4-2008-,utig4-1772-
##      dam_compressed.k31.hapmer_from_utig4-820     >utig1-16631<utig1-2376<utig1-2373<utig1-2376<utig1-2373>utig1-2374>utig1-6098>utig1-16116<utig1-5459
##
##      In the sire patch, utig4-2010 and utig4-1772 overlap with utig4s in the full path
##      In the dam patch, we are adding a telomere to the end of utig4-820. utig1-16631 is the overlapping utig1 we want to aim for.
##
##
##      If you have more than one patch per hapmer, show separation with :.
##      Patches can be of different formatting.
##
##      sire_compressed.k31.hapmer_from_utig4-1772   utig4-2010-,utig4-2008-,utig4-2009+,utig4-2008-,utig4-1772-:>utig1-16631<utig1-2376<utig1-2373<utig1-2376
##
##
##      If splitting a path, add hapmer name twice with final patches
##          !!for now, these paths must be the final path - it does not go through the add patch process!!
##
##      sire_compressed.k31.hapmer_from_utig4-1772   utig4-2010-,utig4-2008-
##      sire_compressed.k31.hapmer_from_utig4-1772   utig4-2009+,utig4-2008-,utig4-1772-
##
##
##  --combine
##
##      hapmer paths to combine formatting example - 'hapmer_name;hapmer_name'
##
##      !!must be set as string!!
##
##      If you have more than one set of hapmers to combine, show separtion with :.
##
##      'sire_compressed.k31.hapmer_from_utig4-1772;sire_compressed.k31.hapmer_from_utig4-1532:dam_compressed.k31.hapmer_from_utig4-820;dam_compressed.k31.hapmer_from_utig4-20'
##
##
##  Output
##
##      Bandage plot formatted paths -> either listed in std file or printed on screen
##      patches_2_final_paths.tsv    -> lists hapmer names and updated paths - formatted for Wen Huang's perl script
## ----------------------------------------------------------------------------------------------------------------------------------------------



## addPatch.pl
##-----------------------------------------------------------------------------------------------------------------------------------------------
## See Lee Ackersons github (https://github.com/LeeAckersonIV/genome-asm/blob/main/helper-scripts)
##
## perl addPatch.pl --gaf test.gaf --patch test_patch.tsv --map test_utig4-utig1.map --verbose > test.out 2> test.log
##
## there are four command line arguments:
##
##	--gaf test.gaf: this is the gaf from verkko before detangling, this tab delimited file must have the header: name path assignment
##	--patch test_patch.tsv: also tab delimited file where the columns are (containing header):old_names(semicolon_separated) new_path(patch) new_name new_assignment
##	--map test_utig4_2_utig1: the conversion map between utig4 and utig1, must contain no header
##	--verbose
##
## test files and output are provided in this directory.
##
## The verbose log file contains a lot of useful information.
##
## prepare utig4 to utig1 map
## This uses the get_utig1_from_utig4.py script.
##
## prepare the patch file (this is done for you if update_patch_2_path.py first)
## The patch file must be tab delimited and contain the:
##
##	awk 'NR==FNR {print $1 "\t" $2; next;} { n = split($2, nodes, /[<>[\]]/); for (i=1; i<=n; i++) if (nodes[i] ~ /^utig4-/) print nodes[i] "\t>" nodes[i]; }' test.gaf test.gaf | sort | uniq | python3 get_utig1_from_utig4.py combined-nodemap.txt combined-edges.gfa /dev/stdin nodelens.txt > test_utig4-utig1.map
##
##
## This command takes the test.gaf and outputs test_utig4-utig1.map file. Other files including combined-nodemap.txt, combined-edges.gfa, and nodelens.txt come from Verkko.
##
## prepare the patch file
## The patch file must be tab delimited and contain the header old_names(semicolon_separated) new_path(patch) new_name new_assignment
##
## There are four possible ways patch can happen:
##
## 	1. when the old name (1st column) is the same as the new name (3rd column), the old gaf line corresponding to the old name is replaced with new path and new assignment.
##	2. when the old name contains multiple semicolon separated paths, the multiple lines in the old gaf are deleted and replaced with one single line with the new name, new path, and new alignment. 
##		This happens when you merge multiple paths.
##	3. when multiple lines in the patch file share the same old name, the one line in the old gaf is replaced with the multiple lines corresponding to the new names, new paths, and new assignments. 
##		This happens when you split one path into multiple.
## 	4. when the 2nd and 3rd columns are marked as "DELETE" (upper case), the path is deleted, and the nodes are put in the bucket of unused nodes if they are not used elsewhere. 
## 		These nodes inherit the assignment in the original path unless a new assignment is provided.
##
## After these patches are applied, a few things can happen to the unitigs.
##
##	1. a node is reactivated: an unused node is now part of a new path, the unused node is deleted from the gaf and now part of the new path.
##	2. a node is orphaned: a node that was in a path is now unused.
##	3. a path is deleted: nodes become unused if they don't appear in other paths.
##
## A special case is when the patch is in the utig1 space. All unused nodes and all original utig4 nodes are checked against the new patch (utig1 path). 
## If a utig4 node's utig1 path is part of the patch (when the largest contiguous match is more than 60% of the path when the number of utig1 nodes is less than or equal to 10 or the 
## largest contiguous match is more than 90% of the path when the number is greater than 10), it is considered covered. 
## A convered node is reactivated and a uncovered node is orphaned and dealt with accordingly.
##
##-------------------------------------------------------------------------------------------------------------------------------------------------
