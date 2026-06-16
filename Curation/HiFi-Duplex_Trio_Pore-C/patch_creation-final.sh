#created by Sarah E. Fumagalli


patch_dir="/assembly/verkko2.2.1_hifi-duplex_tporec/8-manualResolution/final_patch"
verkko_dir="/assembly/verkko2.2.1_hifi-duplex_tporec"
verkko_fillet_dir="/assembly/verkko2.2.1_hifi-duplex_tporec_verkko_fillet"


## ------------------------------------------------------------------------------------------------------------------------------------------------


1. Concatenate all telomere and rDNA patches into a single file 

    cd $patch_dir

	cat ../rDNA/utig4-439_chr11.hap2_RC_line1.patch.gaf ../telomeres/utig4-393_RC_chr11.hap2_RC_line1.patch.gaf ../rDNA/utig4-438_chr11.hap1_line1.patch.gaf ../telomeres/utig4-1331_RC_chr11.hap1_line1.patch.gaf ../telomeres/telo_1854/utig4-1854_utig4-1854_line1.patch.gaf ../telomeres/telo_1854/utig4-2375_utig4-1854_line1.patch.gaf > patchAlign.gaf

    
    Make sure there are pairs of alignments with the same name on the left side of the patchAlign.gaf
    
        - Example

            tangle0_heavy_path      2918278 15      8687    +       >utig4-439      5616868 5608223 5616851 8511    8672    60      tp:A:P  s1:i:8501       dv:f:   id:f:1
            tangle0_heavy_path      2918278 2782124 2912763 +       <utig4-393      155286  9       129297  122644  131376  60      tp:A:P  s1:i:121972     dv:f:   id:f:1
            tangle1_heavy_path      3107320 15      15023   +       >utig4-438      5724960 5709947 5724951 14733   15012   60      tp:A:P  s1:i:14730      dv:f:   id:f:1
            tangle1_heavy_path      3107320 3040503 3107316 +       >utig4-1331     77961   18      66979   64179   67233   60      tp:A:P  s1:i:64002      dv:f:   id:f:1



2. Remove lines that look spurious in the rDNA and telomere patches

    This script can be found on the Verkko github   https://github.com/marbl/verkko

        	micromamba activate verkko-v2.2.1

        	insert_aln_gaps.py ../assembly.homopolymer-compressed.gfa patchAlign.gaf 1 100000 patch.nogap.gaf patch.gaf gapmanual y > patch.gfa

        
        - if Verkko does not accept your patch, it will not produce a result 
        
        - the window_size can be increased (100000) but within reason



3. Add the necessary info for patches to respective files

    Combine patches with previous alignments
    
        cp ../../../6-layoutContigs/combined-alignments.gaf ./

        cat patchAlign.gaf >> combined-alignments.gaf


    Combine patch edges with previous edges 
    
        cp ../../../6-layoutContigs/combined-edges.gfa ./

        cat patch.gfa | grep '^L' |grep gap >> combined-edges.gfa


    Combine node lengths to previous file
    
        ln -s ../../../6-layoutContigs/combined-nodemap.txt
        
        cp ../../../6-layoutContigs/nodelens.txt ./
        
        cat patch.gfa | grep gap | awk 'BEGIN { FS="[ \t]+"; OFS="\t"; } ($1 == "S") && ($3 != "*") { print $2, length($3); }' >> nodelens.txt
        

    Combine subset to previous file
    
        cp ../../../7-consensus/ont_subset.fasta.gz ./
        

    Copy in all rDNA and regular patch fastas
    
        cp /assembly/verkko2.2.1_hifi-duplex_tporec/8-manualResolution/rDNA/chr11.hap2.patch.fa .

        cp /assembly/verkko2.2.1_hifi-duplex_tporec/8-manualResolution/telomeres/telo_1854/utig4-1349.fasta
        

    Concatenate patches
    
        cat chr11.hap2.patch.fa | gzip -c >> ont_subset.fasta.gz

        cat utig4-1349.fasta | gzip -c >> ont_subset.fasta.gz

        seqtk gc ont_subset.fasta.gz |awk '{print $1}'|sort |uniq > ont_subset.id


    Copy gap patches and related files
    
        cp ../gaps/gap.paths.gaf .
        
        cp ../../../6-layoutContigs/unitig-popped.layout .

        cp ../../../6-layoutContigs/unitig-popped.layout.scfmap .


    Confirm gap patches are valid

        This script can be found on the Verkko github   https://github.com/marbl/verkko

            micromamba activate verkko-v2.2.1

            get_layout_from_mbg.py combined-nodemap.txt combined-edges.gfa combined-alignments.gaf gap.paths.gaf nodelens.txt unitig-popped.layout unitig-popped.layout.scfmap

            
            - if there are no errors, gap patches are accepted by Verkko




4. Set up relaunch Verkko folder

    mkdir $verkko_dir/verkko_final_asm && cd $verkko_dir/verkko_final_asm

    ln -s  ../$verkko_dir/1-buildGraph/
    ln -s  ../$verkko_dir/2-processGraph/
    ln -s  ../$verkko_dir/3-align
    ln -s  ../$verkko_dir/3-alignTips/
    ln -s  ../$verkko_dir/4-processONT/
    ln -s  ../$verkko_dir/5-untip/
    
    mkdir 6-layoutContigs && cd 6-layoutContigs
    
    ln -s ../../combined-nodemap.txt
    ln -s ../../combined-edges.gfa
    ln -s ../../combined-alignments.gaf
    ln -s ../../nodelens.txt
    
    cd ..
    
    mkdir 6-rukki && cd 6-rukki (if the assembly was created without trio data - look for similar files in 8-hicPipeline)
    
    ln -s $verkko_dir/6-rukki/unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.noseq.gfa
    ln -s $verkko_dir/6-rukki/unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.colors.csv
    ln -s ../../gap.paths.gaf unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.paths.gaf
    ln -s ../../gap.paths.gaf unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.paths.tsv
    
    cd ../
    
    mkdir 7-consensus && cd 7-consensus
    
    ln -s ../../ont_subset.id
    ln -s ../../ont_subset.fasta.gz
    
    cd ../
    cd ../


5. Relaunch Verkko

    Use --snakeopts "--touch" and "--dry-run" 

    micromamba activate verkko-v2.2.1

    verkko --slurm -d verkko_final_asm --unitig-abundance 4 --red-run 8 40 8 \
        --hifi <*.fastq.gz> \
        --nano <*.fastq.gz> \
        --screen <mito_file_name> <reference_mito.fasta> \
        --screen <rDNA_file_name> <reference_rDNA.fasta> \
        --porec/hic/hapmers <*.fastq.gz>










   
