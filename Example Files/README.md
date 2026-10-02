# Example Input and Output files

---

### **Outputs of Verkko-Fillet and my additional scripts**

`contigPlot.png`
    Heatmap figure depicting whether a chromosome consists of a contig, scaffold, gaps, and telomeres for both haplotypes
 
`rDNA_utigs_ids_Bandage.txt`

     - List of utigs associated with rDNA that can be copied and paste into Bandage for visualization
         
`translation_merged.tsv`

    - Table of all hapmers associated with a chromosome, contig, scaffold, telomere, or gap - also includes reference chromosome name, length, scaffold name, and utig4 path
    
`utig_contig_chr_path_translation.tsv`

    - Table includes all hapmers - an extented version of translation_merged.tsv - includind rDNA and unused hapmers
    
    

### **Inputs and Outputs of Verkko - tangle resolution**
    
`final_gap_patches.tsv`

    - Input for patch_2_path.sh and update_patch_2_path.py - Table of hapmers and tangle patches formatted by following Curation/patch_2_path.sh
        
`gap_patches.tsv`

    - A precursor table to final_gap_patches.tsv - gives detail about chromosome, hapmer combinations, and replacements
        
`patches_2_final_paths.tsv`

    - Output of patch_2_path.sh and update_patch_2_path.py - table of patched hapmers
        
`gap.paths.gaf`

    - Output of patch_2_path.sh and addPatch.pl - reformated and hapmers reorganized - needed for the relaunch of Verkko
        
`gap.paths.log`

    - Output of patch_2_path.sh and addPatch.pl - list of hapmer modifications