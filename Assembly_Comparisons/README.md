# Gyr Assembly Comparison

---


1. **Assembly statistics**

    assembly_stats.sh

    - Finds telomeres and their counts using **[seqtk telo](https://github.com/lh3/seqtk)** per haplotype.
    
    - Finds assembly gaps with **[gfastats](https://github.com/vgl-hub/gfastats)** per haplotype and full assembly.
    
    - Finds alignments with reference for both haplotypes using --[Minimap2](https://github.com/lh3/minimap2)**
    
    - Combines all assemblies listed into single table. 

    

2. **Compare numbers of T2T chromosomes**

    trans_ctgs_scfs_bargraph.sh
    
    - Creates bar graph to easily compare between assemblies. 