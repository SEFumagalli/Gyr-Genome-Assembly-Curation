#created by Sarah E. Fumagalli


patch_dir="/assembly/verkko2.2.1_hifi-duplex_tporec/8-manualResolution/final_patch"
verkko_dir="/assembly/verkko2.2.1_hifi-duplex_tporec"
verkko_fillet_dir="/assembly/verkko2.2.1_hifi-duplex_tporec_verkko_fillet"


## ------------------------------------------------------------------------------------------------------------------------------------------------

1. mkdir final_patch

    cd final_patch
    

2. Add the necessary info for patches and respective files

    Combine patches with previous alignments
    
        cp ../../6-layoutContigs/combined-alignments.gaf ./

        cat ../rDNA/patchAlign.gaf >> combined-alignments.gaf


    Combine patch edges with previous edges 
    
        cp ../../6-layoutContigs/combined-edges.gfa ./

        cat ../rDNA/patchAlign.gfa | grep '^L' |grep gap >> combined-edges.gfa


    Combine node lengths to previous file
    
        ln -s ../../6-layoutContigs/combined-nodemap.txt
        
        cp ../../6-layoutContigs/nodelens.txt ./
        
        cat ../rDNA/patchAlign.gfa | grep gap | awk 'BEGIN { FS="[ \t]+"; OFS="\t"; } ($1 == "S") && ($3 != "*") { print $2, length($3); }' >> nodelens.txt
        

    Combine subset to previous file
    
        cp ../../../7-consensus/ont_subset.fasta.gz ./
        

    Copy in all rDNA and regular patch fastas
    
        cp ../rDNA/chr11.hap2.patch.fa .
        cp ../rDNA/chr11.hap1.patch.fa .
        cp ../rDNA/chr3.hap1.patch.fa .
        cp ../rDNA/chr3.hap2.patch.fa .
        cp ../rDNA/chr25.hap1_2.patch.fa .
        cp ../rDNA/chr2.hap1.patch.fa .
        

    Concatenate patches
    
        cat chr11.hap2.patch.fa | gzip -c >> ont_subset.fasta.gz
        cat chr11.hap1.patch.fa | gzip -c >> ont_subset.fasta.gz
        cat chr3.hap1.patch.fa | gzip -c >> ont_subset.fasta.gz
        cat chr3.hap2.patch.fa | gzip -c >> ont_subset.fasta.gz
        cat chr25.hap1_2.patch.fa | gzip -c >> ont_subset.fasta.gz
        cat chr2.hap1.patch.fa | gzip -c >> ont_subset.fasta.gz

        seqtk gc ont_subset.fasta.gz |awk '{print $1}'|sort |uniq > ont_subset.id


    Copy gap patches and related files
    
        cp ../gaps/gap.paths.gaf .
        
        cp ../../6-layoutContigs/unitig-popped.layout .

        cp ../../6-layoutContigs/unitig-popped.layout.scfmap .
        
        cp ../../6-layoutContigs/combined-nodemap.txt .


    Confirm gap patches are valid

        This script can be found on the Verkko github   https://github.com/marbl/verkko

            micromamba activate verkko-v2.2.1

            get_layout_from_mbg.py combined-nodemap.txt combined-edges.gfa combined-alignments.gaf gap.paths.gaf nodelens.txt unitig-popped.layout unitig-popped.layout.scfmap

            
            - if there are no errors, gap patches are accepted by Verkko




3. Set up relaunch Verkko folder

    mkdir $verkko_dir/verkko_final_asm && cd $verkko_dir/verkko_final_asm

    ln -s  ../$verkko_dir/1-buildGraph/
    ln -s  ../$verkko_dir/2-processGraph/
    ln -s  ../$verkko_dir/3-align
    ln -s  ../$verkko_dir/3-alignTips/
    ln -s  ../$verkko_dir/4-processONT/
    ln -s  ../$verkko_dir/5-untip/
    
    mkdir 6-layoutContigs && cd 6-layoutContigs
    
    ln -s ../../$patch_dir/final/combined-nodemap.txt
	ln -s ../../$patch_dir/final/combined-edges.gfa
	ln -s ../../$patch_dir/final/combined-alignments.gaf
	ln -s ../../$patch_dir/final/nodelens.txt
	ln -s ../../$patch_dir/final/unitig-popped.layout
    ln -s ../../$patch_dir/final/unitig-popped.layout.scfmap
    
    cd ..
    
    mkdir 6-rukki && cd 6-rukki (if the assembly was created without trio data - look for similar files in 8-hicPipeline)
    
    cp $patch_dir/gaps/gap.paths.gaf rukki.paths.gaf
    cp $patch_dir/gaps/gap.paths.gaf rukki.paths.tsv
    cp $verkko_dir/6-rukki/label1 .
    cp $verkko_dir/6-rukki/label2 .
    cp $verkko_dir/6-rukki/unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.colors.csv .
    cp $verkko_dir/6-rukki/unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.noseq.gfa .

    
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










   
