# Running Verkko Assembler

---


Find Verkko here **[Verkko](https://github.com/marbl/verkko)**

All scripts are formatted for use on the Ceres cluster at the USDA.

To run Verkko generally, use launch_Gyr_verkko.sh.

**launch_Gyr_verkko.sh**

    Input data:
        -d                   assembly_directory_name
        --hifi               long-read fastq.gz
        --nano               ultra-long read fastq.gz
        --screen             mitochondrial reference fasta
        --screen             rDNA reference fasta
        --porec/hic/hapmers  phasing read fastq.gz
        
        
        
        
To run Verkko with multiple phasing data types, use launch_Gyr_verkko_overlay.sh.

**launch_Gyr_verkko_overlay.sh**
        
    1. Create the Verkko assembly HiFi-Duplex/ONT-UL/Trio using the script above
    
    2. mkdir verkko2.2.1_hifi-duplex_tporec
    
    3. Symlink files from HiFi-Duplex/ONT-UL/Trio
        - touch -r verkko2.2.1_hifi-duplex_trio/emptyfile verkko2.2.1_hifi-duplex_tporec/emptyfile
        - ln -s ../verkko2.2.1_hifi-duplex_trio/1-buildGraph .           
        - ln -s ../verkko2.2.1_hifi-duplex_trio/2-processGraph .         
        - ln -s ../verkko2.2.1_hifi-duplex_trio/3-align .                 
        - ln -s ../verkko2.2.1_hifi-duplex_trio/3-alignTips .             
        - ln -s ../verkko2.2.1_hifi-duplex_trio/4-processONT .            
        - ln -s ../verkko2.2.1_hifi-duplex_trio/5-untip .                 
        - ln -s ../verkko2.2.1_hifi-duplex_trio/hifi-corrected.fasta.gz .         
        
    4. mkdir 7-consensus
        - cd 7-consensus
        - ln -s ../../verkko2.2.1_hifi-duplex_trio/7-consensus/ont_subset.fasta.gz .
        - ln -s ../../verkko2.2.1_hifi-duplex_trio/7-consensus/ont_subset.id .
        - cd ..
        
    5. mkdir 8-hicPipeline
        - cd 8-hicPipeline
        - ln -s ../../verkko2.2.1_hifi-duplex_trio/6-rukki/unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.noseq.gfa unitigs.hpc.noseq.gfa
        - ln -s ../../verkko2.2.1_hifi-duplex_trio/6-rukki/unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.fasta unitigs.hpc.fasta
        - cd ..

    6. Hi-C phasing
    
        micromamba activate verkko-v2.2.1

        verkko --slurm -d verkko2.2.1_hifi-duplex_tporec --snakeopts '-U hicPhasing' \
            --ovb-run 8 32 32 \
            --hifi hifi-duplex/*fastq.gz \
            --nano ont/*fastq.gz> \
            --screen cattle_MT Cattle_Mt.fasta \
            --screen cattle_rDNA Cattle_rDNA.fasta \
            --porec porec/*fastq.gz>

    7. Update files for final run
        - mv verkko2.2.1_hifi-duplex_tporec/8-hicPipeline/hicverkko.colors.tsv verkko2.2.1_hifi-duplex_tporec/8-hicPipeline/hicverkko.hiccolors.tsv 
        - cp verkko2.2.1_hifi-duplex_trio/6-rukki/unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.colors.csv verkko2.2.1_hifi-duplex_tporec/8-hicPipeline/hicverkko.colors.tsv
        - rm -f verkko2.2.1_hifi-duplex_tporec/8-hicPipeline/label*
        - cp -p verkko2.2.1_hifi-duplex_trio/6-rukki/label* verkko2.2.1_hifi-duplex_tporec/8-hicPipeline/
        - rm -f verkko2.2.1_hifi-duplex_tporec/8-hicPipeline/rukki.paths.gaf 
        - rm -f verkko2.2.1_hifi-duplex_tporec/8-hicPipeline/rukki.paths.tsv 
        - cat verkko2.2.1_hifi-duplex_trio/6-rukki/unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.paths.gaf | sed s/MAT/HAPLOTYPE1/g | sed s/PAT/HAPLOTYPE2/g > verkko2.2.1_hifi-duplex_tporec/8-hicPipeline/rukki.paths.gaf 
        - cat verkko2.2.1_hifi-duplex_trio/6-rukki/unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.paths.tsv | sed s/MAT/HAPLOTYPE1/g | sed s/PAT/HAPLOTYPE2/g > verkko2.2.1_hifi-duplex_tporec/8-hicPipeline/rukki.paths.tsv 
        - cp -p verkko2.2.1_hifi-duplex_tporec/8-hicPipeline/rukki.paths.gaf verkko2.2.1_hifi-duplex_tporec/8-hicPipeline/prescaf_rukki.paths.gaf 
        - cp -p verkko2.2.1_hifi-duplex_tporec/8-hicPipeline/rukki.paths.tsv verkko2.2.1_hifi-duplex_tporec/8-hicPipeline/prescaf_rukki.paths.tsv 
        - cp -p verkko2.2.1_hifi-duplex_tporec/8-hicPipeline/rukki.paths.tsv verkko2.2.1_hifi-duplex_tporec/assembly.paths.tsv 

    8. Final run
    
        micromamba activate verkko-v2.2.1
    
        verkko --slurm -d verkko2.2.1_hifi-duplex_tporec --ovb-run 8 32 32 \
            --screen cattle_MT Cattle_Mt.fasta \
            --screen cattle_rDNA Cattle_rDNA.fasta \ 
            --hifi hifi-duplex/*fastq.gz \
            --nano ont/*fastq.gz \
            --porec porec/*fastq.gz



After fixing tangles, rDNA, and telomeres, use relaunch_Gyr_verkko.sh.

**relaunch_Gyr_verkko.sh**
    
    Relaunching an assembly that uses Trio and a type of Hi-C is slightly different than relaunching for Trio only.
    
    1. mkdir verkko2.3.2_hifi-duplex_trio_final_asm

    2. Symlink files from HiFi-Duplex/ONT-UL/Trio
        - ln -s ../verkko2.3.2_hifi-duplex_trio/1-buildGraph/
        - ln -s ../verkko2.3.2_hifi-duplex_trio/2-processGraph/
        - ln -s ../verkko2.3.2_hifi-duplex_trio/3-align/
        - ln -s ../verkko2.3.2_hifi-duplex_trio/3-align/
        - ln -s ../verkko2.3.2_hifi-duplex_trio/4-processONT/
        - ln -s ../verkko2.3.2_hifi-duplex_trio/5-untip/

    3. mkdir 6-rukki --> these files can be found in 8-hicPipeline for assemblies with Hi-C data
        - cd 6-rukki
        - cp ../../verkko2.3.2_hifi-duplex_trio/gaps/gap.paths.gaf unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.paths.gaf (Hi-C: rukki.paths.gaf)
        - cp ../../verkko2.3.2_hifi-duplex_trio/gaps/gap.paths.gaf unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.paths.tsv (Hi-C: rukki.paths.tsv)
        - cp ../../verkko2.3.2_hifi-duplex_trio/6-rukki/label1 .
        - cp ../../verkko2.3.2_hifi-duplex_trio/6-rukki/label2 .
        - cp ../../verkko2.3.2_hifi-duplex_trio/6-rukki/unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.colors.csv .
        - cp ../../verkko2.3.2_hifi-duplex_trio/6-rukki/unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.noseq.gfa .
        - cd ..

    4. mkdir 6-layoutContigs --> make sure these are the updated files with the alignments and tangle corrections
        - cd 6-layoutContigs
        - cp ../../verkko2.3.2_hifi-duplex_trio/final/combined-nodemap.txt .
        - cp ../../verkko2.3.2_hifi-duplex_trio/final/combined-edges.gfa .
        - cp ../../verkko2.3.2_hifi-duplex_trio/final/combined-alignments.gaf .
        - cp ../../verkko2.3.2_hifi-duplex_trio/final/nodelens.txt .
        - cp ../../verkko2.3.2_hifi-duplex_trio/final/unitig-popped.layout .
        - cp ../../verkko2.3.2_hifi-duplex_trio/final/unitig-popped.layout.scfmap .
        - cd ..
	
	5. mkdir 7-consensus  --> make sure these are the updated files with the alignments and tangle corrections
        	- cd 7-consensus
        	- ln -s ../../verkko2.3.2_hifi-duplex_trio/final/ont_subset.id
        	- ln -s ../../verkko2.3.2_hifi-duplex_trio/final/ont_subset.fasta.gz
        	- cd ..
        
    6. Launch rerun
    
        micromamba activate verkko-v2.3.2
    
        verkko --slurm -d verkko2.3.2_hifi-duplex_trio_final_asm \
            --ovb-run 8 32 32 \
            --screen cattle_MT Cattle_Mt.fasta \
            --screen cattle_rDNA Cattle_rDNA.fasta \ 
            --hifi hifi-duplex/*fastq.gz \
            --nano ont/*fastq.gz \
            --hap-kmers illumina/hapmer_compressed/dam_compressed.k31.hapmer.meryl illumina/hapmer_compressed/sire_compressed.k31.hapmer.meryl trio
