#created by Sarah E. Fumagalli


## This script describes the steps taken to fix a single tangle near a telomere in an alternate assembly to use as a patch for my curated assembly


patch_dir="/90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-herro_porec/8-manualResolution/assembly_patch"
verkko_dir="/90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-herro_porec"
verkko_fillet_dir="/90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-herro_porec_verkko_fillet"


## ------------------------------------------------------------------------------------------------------------------------------------------------
##
##
## Final patch
##
##
## ------------------------------------------------------------------------------------------------------------------------------------------------


## Concatenate all patches into a single file 

	We do not have any patches, only gaps



## Add the necessary info for patches to respective files

mkdir /90daydata/ruminant_t2t/Gyr/assembly/relaunch.patch.verkko2.2.1_hifi-herro_porec
new_verkko_dir="/90daydata/ruminant_t2t/Gyr/assembly/relaunch.patch.verkko2.2.1_hifi-herro_porec"
cd $new_verkko_dir

#copy in align + patch gaf files
cp $verkko_dir/6-layoutContigs/combined-alignments.gaf ./
No new patches to include

#copy in edges and patch gfa files
cp $verkko_dir/6-layoutContigs/combined-edges.gfa ./
No new patches to include

#get nodemap and nodelens, append patch.gfa
ln -s $verkko_dir/6-layoutContigs/combined-nodemap.txt
cp $verkko_dir/6-layoutContigs/nodelens.txt ./
No new patches to include

# copy in consensus ONT reads, as well as full patch sequences (treated as ONT reads)
# add rDNA patches as ONT reads for verkko to use
cp $verkko_dir/7-consensus/ont_subset.fasta.gz ./

salloc --account=cattle_genome_assemblies -p priority -q agil -c 96 --mem-per-cpu=3968 --time=3-00:00:00
module load seqtk
seqtk gc ont_subset.fasta.gz |awk '{print $1}'|sort |uniq > ont_subset.id

#copy in all rDNA and regular patch fastas
No new patches to include

#copy gap fixes and other needed files
Need file to finish this file
cp $patch_dir/gap.paths.gaf .
cp $verkko_dir/6-layoutContigs/unitig-popped.layout .
cp $verkko_dir/6-layoutContigs/unitig-popped.layout.scfmap .

# Confirm new assembly layout & paths are valid
micromamba activate verkko-v2.2.1

/project/cattle_genome_assemblies/packages/micromamba/envs/verkko-v2.2.1/lib/verkko/scripts/get_layout_from_mbg.py combined-nodemap.txt combined-edges.gfa combined-alignments.gaf gap.paths.gaf nodelens.txt unitig-popped.layout unitig-popped.layout.scfmap


# Set up verkko_final_asm folder
mkdir verkko_final_asm
final_verkko_dir="/90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-herro_porec_final_asm"
cd $final_verkko_dir

ln -s  $verkko_dir/1-buildGraph/
ln -s  $verkko_dir/2-processGraph/
ln -s  $verkko_dir/3-align
ln -s  $verkko_dir/3-alignTips/
ln -s  $verkko_dir/4-processONT/
ln -s  $verkko_dir/5-untip/


mkdir 6-layoutContigs
cd 6-layoutContigs
ln -s ../../$verkko_dir/6-layoutContigs/combined-nodemap.txt
ln -s ../../$verkko_dir/6-layoutContigs/combined-edges.gfa
ln -s ../../$verkko_dir/6-layoutContigs/combined-alignments.gaf
ln -s ../../$verkko_dir/6-layoutContigs/nodelens.txt
ln -s ../../$new_verkko_dir/unitig-popped.layout.scfmap
ln -s ../../$new_verkko_dir/unitig-popped.layout


cd ../
mkdir 7-consensus
cd 7-consensus
ln -s ../../$verkko_dir/7-consensus/ont_subset.id
ln -s ../../$verkko_dir/7-consensus/ont_subset.fasta.gz


# Rerun Verkko w/ patches
ln -s /project/ruminant_t2t/Gyr/hifi_herro
ln -s /project/ruminant_t2t/Gyr/oxnan_data/combined
ln -s /project/ruminant_t2t/existing_NCBI_references/Cattle/ARS-UCD2.0_chr.fasta
ln -s /project/ruminant_t2t/Gyr/new_assemblies/Cattle_rDNA.fasta
ln -s /project/ruminant_t2t/Gyr/new_assemblies/Cattle_Mt.fasta
ln -s /project/ruminant_t2t/Gyr/PoreC



launch_Gyr_hifi-herro_porec_verkko2.2.1.sh
#!/bin/bash -l

micromamba activate verkko-v2.2.1

verkko --version

verkko --slurm --snakeopts "--touch" -d verkko2.2.1_hifi-herro_porec_final_asm --red-run 8 40 8 --unitig-abundance 4 --hifi hifi_herro/*.gz --nano combined/*.fastq.gz --screen cattle_MT Cattle_Mt.fasta --screen cattle_rDNA Cattle_rDNA.fasta --porec PoreC/AllPoreC.gt10q.fastq.gz

sbatch --qos=memlimit --partition=ceres --account=cattle_genome_assemblies --time=1-00:00:00 --parsable --cpus-per-task=2 --mem 50g --output Gyr_hifi-herro_porec_final_asm_verkko2.2.1-touch.out relaunch_Gyr_hifi-herro_porec_verkko2.2.1.sh



verkko --slurm --snakeopts "--dry-run" -d verkko2.2.1_hifi-herro_porec_final_asm --red-run 8 40 8 --unitig-abundance 4 --hifi hifi_herro/*.gz --nano combined/*.fastq.gz --screen cattle_MT Cattle_Mt.fasta --screen cattle_rDNA Cattle_rDNA.fasta --porec PoreC/AllPoreC.gt10q.fastq.gz

sbatch --qos=memlimit --partition=ceres --account=cattle_genome_assemblies --time=1-00:00:00 --parsable --cpus-per-task=2 --mem 50g --output Gyr_hifi-herro_porec_final_asm_verkko2.2.1-dr.out relaunch_Gyr_hifi-herro_porec_verkko2.2.1.sh



# ./launch_verkko_final_asm.sh
# ----------------------------
#!/bin/bash -l
micromamba activate verkko-v2.2.1
verkko --version

verkko --slurm -d verkko2.2.1_hifi-herro_porec_final_asm --red-run 8 40 8 --unitig-abundance 4 --hifi hifi_herro/*.gz --nano combined/*.fastq.gz --screen cattle_MT Cattle_Mt.fasta --screen cattle_rDNA Cattle_rDNA.fasta --porec PoreC/AllPoreC.gt10q.fastq.gz


sbatch --qos=memlimit --partition=ceres --account=cattle_genome_assemblies --time=3-00:00:00 --parsable --cpus-per-task=2 --mem 50g --output Gyr_hifi-herro_porec_final_asm_verkko2.2.1.out relaunch_Gyr_hifi-herro_porec_verkko2.2.1.sh
# -----------------------------









   
