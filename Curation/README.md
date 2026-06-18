# Curation of the HiFi-Duplex/ONT-UL/Trio/Pore-C Assembly 

---


1. Process gaps/tangles/bubbles

    Step-by-step process detailed in **patch_creation-gaps.sh**
    
    - Idenify gaps using Verkko and Verkko-Fillet output files.
        
    - Visualize gaps using **[Bandage](https://github.com/asl/BandageNG)** 
            
        asm-path-translate-printout-Bandage.py
            
    - Use **[Trivial Tangle Traverser](https://github.com/marbl/TTT)** for complex tangles.
        
        tangle_traverser.sh
            
    - For manual curation
        
        asm-path-translate-printout-reverse.py
        asm-path-flipper.py        
        asm-path-translate-printout.py
            
        The last two scripts were originally built by **[Lee Ackerson](https://github.com/LeeAckersonIV/genome-asm/tree/main/helper-scripts)**
            
     - Insert patches into paths and prepare files for Verkko relaunch.
        
        patch_2_path.sh
        update_patch_2_path.py
        get_utig1_from_utig4.py
        addPatch.pl
                
        get_utig1_from_utig4.py can be found in the **[Verkko](https://github.com/marbl/verkko/tree/master/src/scripts)** github
    
        addPatch.pl (Wen Huang) can be found on **[Lee Ackerson](https://github.com/LeeAckersonIV/genome-asm/tree/main/helper-scripts)** github
    
    
    
2. Process loose telomeres

    Step-by-step process detailed in **patch_creation-telo.sh**
    
    - Idenify telomere for each chromosome using Verkko and Verkko-Fillet output files.
    
    - Visualize telomere using **[Bandage](https://github.com/asl/BandageNG)** 
    
        asm-path-translate-printout-Bandage.py
        
    - Align with **[Minimap2](https://github.com/lh3/minimap2)** to find overlapping segment.
    
    - Align chromosome and telomere to segment.
    
    - Convert to GAF.
    
    

3. Process rDNA morphs

    Step-by-step process detailed in **patch_creation-rDNA.sh**
    
    - Create consensus rDNA sequence with **[Ribotin](https://github.com/maickrau/ribotin)**
    
    - Identify locations of rDNA in assembly with **[RepeatMasker](https://github.com/Dfam-consortium/RepeatMasker/)**
    
    - Determine median copy number with **[CONKORD](https://github.com/borcherm/CONKORD)**
    
    - Convert rDNA morph to patch
    
        rDNA-morph2patch.sh
        
        Script originally built by **[Lee Ackerson](https://github.com/LeeAckersonIV/genome-asm/tree/main/helper-scripts)**
        
    - Identify flanking utigs (chromosome and telomere)
    
    - Align with **[Minimap2](https://github.com/lh3/minimap2)** to find overlapping segment.
    
    - Align chromosome and telomere to segment.
    
    - Convert to GAF.
    
    
    
4. Combine all patches and rerun Verkko for the final assembly

    Step-by-step process detailed in **patch_creation-final.sh**
    
    - Concatenate telomere and rDNA patches.
    
    - Remove lines that look spurious 
    
        insert_aln_gaps.py
        
        Can be found in the **[Verkko](https://github.com/marbl/verkko/tree/master/src/scripts)** github 
        
    - Combine telomere and rDNA patches with Verkko files.
    
    - Comfirm gap patches.
    
        get_layout_from_mbg.py
        
        Can be found in the **[Verkko](https://github.com/marbl/verkko/tree/master/src/scripts)** github 
        
    - Set up Verkko relaunch directory. 
    