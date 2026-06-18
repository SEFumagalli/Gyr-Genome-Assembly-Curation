# Curation of the HiFi-Duplex/ONT-UL/Trio/Pore-C Assembly 

---


1. Process gaps/tangles/bubbles

    Step-by-step process detailed in **patch_creation-gaps.sh**
        
        - Idenify gaps using Verkko and Verkko-Fillet output files
        
        - Visualize gaps using **[Bandage](https://github.com/asl/BandageNG)**
        
            - asm-path-translate-printout-Bandage.py
            
        - Use **[Trivial Tangle Traverser](https://github.com/marbl/TTT)** for complex tangles
        
            - tangle_traverser.sh
            
        - For manual curation
        
            - asm-path-translate-printout-reverse.py
            - asm-path-flipper.py        
            - asm-path-translate-printout.py
            
            The last two scripts were originally built by **[Lee Ackerson](https://github.com/LeeAckersonIV/genome-asm/tree/main/helper-scripts)**
            
        - Insert patches into paths and prepare files for Verkko relaunch
        
            - patch_2_path.sh
                - update_patch_2_path.py
                - get_utig1_from_utig4.py
                - addPatch.pl
            
                update_patch_2_path.py incorporates scripts from:
                    - get_utig1_from_utig4.py can be found in the **[Verkko](https://github.com/marbl/verkko/tree/master/src/scripts)** github
                    - addPatch.pl (Wen Huang) can be found on **[Lee Ackerson](https://github.com/LeeAckersonIV/genome-asm/tree/main/helper-scripts)** github
    
    
2. Process loose telomeres

    Step-by-step process detailed in **patch_creation-telo.sh**
    

3. Process rDNA morphs

    Step-by-step process detailed in **patch_creation-rDNA.sh**
    
    
4. Combine all patches and rerun Verkko for the final assembly

    Step-by-step process detailed in **patch_creation-final.sh**