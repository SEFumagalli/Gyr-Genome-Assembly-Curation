#created by Sarah E. Fumagalli


patch_dir="/90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec/8-manualResolution/assembly_patch"
verkko_dir="/90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec"
verkko_fillet_dir="/90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec_verkko_fillet"


## ------------------------------------------------------------------------------------------------------------------------------------------------
##
##
## Final patch
##
##
## ------------------------------------------------------------------------------------------------------------------------------------------------


cd $patch_dir
cd final_patch

## Concatenate all patches into a single file 

	cat ../rDNA-patches/utig4-439_chr11.hap2_RC_line1.patch.gaf ../telomere_alignments/rDNA_telo/utig4-393_RC_chr11.hap2_RC_line1.patch.gaf ../rDNA-patches/utig4-438_chr11.hap1_line1.patch.gaf ../telomere_alignments/rDNA_telo/utig4-1331_RC_chr11.hap1_line1.patch.gaf ../rDNA-patches/utig4-278_chr3.hap1_RC_line1.patch.gaf ../telomere_alignments/rDNA_telo/utig4-251_chr3.hap1_RC_line2.patch.gaf ../rDNA-patches/utig4-918_chr3.hap2_line1.patch.gaf ../telomere_alignments/rDNA_telo/utig4-70_RC_chr3.hap2_line1.patch.gaf ../rDNA-patches/utig4-982_chr2.hap2_RC_line1.patch.gaf ../telomere_alignments/rDNA_telo/utig4-456_chr2.hap2_RC_line2.patch.gaf ../rDNA-patches/utig4-376_chr25.hap1_2_RC_line2.patch.gaf ../telomere_alignments/rDNA_telo/utig4-2334_chr25.hap1_2_RC_line1.patch.gaf ../rDNA-patches/utig4-607_chr2.hap1_line1.patch.gaf ../telomere_alignments/rDNA_telo/utig4-356_RC_chr2.hap1_line2.patch.gaf ../telomere_alignments/telo_1854/utig4-1854_utig4-1854_line1.patch.gaf ../telomere_alignments/telo_1854/utig4-2375_utig4-1854_line1.patch.gaf ../telomere_alignments/telo_2468/utig4-2468_hap2_346_line1.patch.gaf ../telomere_alignments/telo_2468/hap2_346_hap2_346_line1.patch.gaf > patchAlign.gaf


	**Make sure there are pairs of alignments with the same name on the left side of the patchAlign.gaf



## Remove lines that look spurious in the rDNA patches

	micromamba activate verkko-v2.2.1

	/project/cattle_genome_assemblies/packages/micromamba/envs/verkko-v2.2.1/lib/verkko/scripts/insert_aln_gaps.py ../assembly.homopolymer-compressed.gfa ../rDNA-patches/rDNA_patchAlign.gaf 1 100000 patch.nogap.gaf patch.gaf gapmanual y > patch.gfa





## Add the necessary info for patches to respective files

#combine patches with previous alignments
cp ../../../6-layoutContigs/combined-alignments.gaf ./
cat patchAlign.gaf >> combined-alignments.gaf

#combine patch edges with previous edges 
cp ../../../6-layoutContigs/combined-edges.gfa ./
cat patch.gfa | grep '^L' |grep gap >> combined-edges.gfa

#combine node lengths to previous file
ln -s ../../../6-layoutContigs/combined-nodemap.txt
cp ../../../6-layoutContigs/nodelens.txt ./
cat patch.gfa | grep gap | awk 'BEGIN { FS="[ \t]+"; OFS="\t"; } ($1 == "S") && ($3 != "*") { print $2, length($3); }' >> nodelens.txt

#combine subset to previous file
cp ../../../7-consensus/ont_subset.fasta.gz ./

#copy in all rDNA and regular patch fastas
cp /90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec/8-manualResolution/verkko2.2.1_hifi-duplex_tporec_patch/rDNA-patches/chr11.hap2.patch.fa .
cp /90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec/8-manualResolution/verkko2.2.1_hifi-duplex_tporec_patch/rDNA-patches/chr11.hap1.patch.fa .
cp /90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec/8-manualResolution/verkko2.2.1_hifi-duplex_tporec_patch/rDNA-patches/chr3.hap1.patch.fa .
cp /90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec/8-manualResolution/verkko2.2.1_hifi-duplex_tporec_patch/rDNA-patches/chr3.hap2.patch.fa .
cp /90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec/8-manualResolution/verkko2.2.1_hifi-duplex_tporec_patch/rDNA-patches/chr2.hap2.patch.fa .
cp /90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec/8-manualResolution/verkko2.2.1_hifi-duplex_tporec_patch/rDNA-patches/chr25.hap1_2.patch.fa .
cp /90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec/8-manualResolution/verkko2.2.1_hifi-duplex_tporec_patch/rDNA-patches/chr2.hap1.patch.fa .
cp /90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec/8-manualResolution/verkko2.2.1_hifi-duplex_tporec_patch/telomere_alignments/telo_1854/utig4-1349-nonhpc.fasta
cp /90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec/8-manualResolution/verkko2.2.1_hifi-duplex_tporec_patch/telomere_alignments/telo_2468/need nonhpc patch fasta

#concatenate patches
cat chr11.hap2.patch.fa | gzip -c >> ont_subset.fasta.gz
cat chr11.hap1.patch.fa | gzip -c >> ont_subset.fasta.gz
cat chr3.hap1.patch.fa | gzip -c >> ont_subset.fasta.gz
cat chr3.hap1.patch.fa | gzip -c >> ont_subset.fasta.gz
cat chr2.hap2.patch.fa | gzip -c >> ont_subset.fasta.gz
cat chr25.hap1_2.patch.fa | gzip -c >> ont_subset.fasta.gz
cat chr2.hap1.patch.fa | gzip -c >> ont_subset.fasta.gz
cat utig4-1349-nonhpc.fasta | gzip -c >> ont_subset.fasta.gz
cat utig4-?-nonhpc.fasta | gzip -c >> ont_subset.fasta.gz

micromamba activate seqtk
seqtk gc ont_subset.fasta.gz |awk '{print $1}'|sort |uniq > ont_subset.id


#copy gap fixes and other needed files 
cp ../gaps/gap.paths.gaf .
cp ../../../6-layoutContigs/unitig-popped.layout .
cp ../../../6-layoutContigs/unitig-popped.layout.scfmap .


# Confirm new assembly layout & paths are valid
salloc --account=cattle_genome_assemblies -p priority -q agil -c 96 --mem-per-cpu=3968 --time=1-00:00:00

micromamba activate verkko-v2.2.1

/project/cattle_genome_assemblies/packages/micromamba/envs/verkko-v2.2.1/lib/verkko/scripts/get_layout_from_mbg.py combined-nodemap.txt combined-edges.gfa combined-alignments.gaf gap.paths.gaf nodelens.txt unitig-popped.layout unitig-popped.layout.scfmap





# Set up verkko_final_asm folder
mkdir verkko_final_asm
final_verkko_dir="/90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec_final_asm"
cd $final_verkko_dir

ln -s  ../$verkko_dir/1-buildGraph/
ln -s  ../$verkko_dir/2-processGraph/
ln -s  ../$verkko_dir/3-align
ln -s  ../$verkko_dir/3-alignTips/
ln -s  ../$verkko_dir/4-processONT/
ln -s  ../$verkko_dir/5-untip/

mkdir 6-layoutContigs
cd 6-layoutContigs
ln -s ../../combined-nodemap.txt
ln -s ../../combined-edges.gfa
ln -s ../../combined-alignments.gaf
ln -s ../../nodelens.txt

cd ..

This folder does not exist
mkdir 6-rukki
cd 6-rukki
ln -s $verkko_dir/6-rukki/unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.noseq.gfa
ln -s $verkko_dir/6-rukki/unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.colors.csv
ln -s ../../new.paths.gaf unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.paths.gaf
ln -s ../../new.paths.gaf unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.paths.tsv

cd ../
mkdir 7-consensus
cd 7-consensus
ln -s ../../ont_subset.id
ln -s ../../ont_subset.fasta.gz


# Rerun Verkko w/ patches
cd $new_verkko_dir
ln -s /project/ruminant_t2t/Gyr/assembly/duplex-hifi
ln -s /project/ruminant_t2t/Gyr/assembly/combined
ln -s /project/ruminant_t2t/existing_NCBI_references/Cattle/ARS-UCD2.0_chr.fasta
ln -s /project/ruminant_t2t/Gyr/new_assemblies/Cattle_rDNA.fasta
ln -s /project/ruminant_t2t/Gyr/new_assemblies/Cattle_MT.fasta
ln -s /project/ruminant_t2t/Gyr/PoreC


micromamba activate verkko-v2.2.1
verkko --version

verkko --slurm --snakeopts "--touch" -d verkko2.2.1_hifi-duplex_tporec_relaunch --unitig-abundance 4 --red-run 8 40 8 --hifi duplex_hifi/*.fastq.gz --nano combined/*.fastq.gz --screen Cattle_MT Cattle_MT.fasta --screen Cattle_rDNA Cattle_rDNA.fasta --porec PoreC/AllPoreC.gt10q.fastq.gz > dev/null 2>&1

verkko --slurm --snakeopts "--dry-run" -d verkko2.2.1_hifi-duplex_tporec_relaunch --unitig-abundance 4 --red-run 8 40 8 --hifi duplex_hifi/*.fastq.gz --nano combined/*.fastq.gz --screen Cattle_MT Cattle_MT.fasta --screen Cattle_rDNA Cattle_rDNA.fasta --porec PoreC/AllPoreC.gt10q.fastq.gz

sbatch --parsable --cpus-per-task=2 --mem 50g --output verkko2.2.1_hifi-duplex_tporec_relaunch.out launch_verkko_final_asm.sh


# ./launch_verkko_final_asm.sh
# ----------------------------
#!/bin/bash -l
micromamba activate verkko-v2.2.1
verkko --version

verkko --slurm -d verkko2.2.1_hifi-duplex_tporec_relaunch --unitig-abundance 4 --red-run 8 40 8 --hifi duplex_hifi/*.fastq.gz --nano combined/*.fastq.gz --screen Cattle_MT Cattle_MT.fasta --screen Cattle_rDNA Cattle_rDNA.fasta --porec PoreC/AllPoreC.gt10q.fastq.gz
# -----------------------------









   
