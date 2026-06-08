# Genome Assembly and Curation Project

This repository contains **documentation**, **tutorials**, and **scripts** for performing **genome assembly** and **manual curation** using **[Verkko](https://github.com/marbl/verkko)** and **[Verkko-Fillet](https://github.com/jjuhyunkim/verkko-fillet/tree/main)**.



---



### **GyrT2T Project**
- *Bos (primigenius) indicus* - Gyr cattle
- This project will highlight the differences in Verkko assembly output when a variety of data types are used.

	- Blood was sampled from the male F1 Gyr and its parents

	- 19 data combinations arranged for the Verkko assemblier --hifi, --nano, and phasing data flags.
        
        	1. PacBio long reads -> HiFi, Oxford Nanopore ultra long reads -> ONT, and DoveTail Genomics' Hi-C short reads -> Omni-C
        	2. HiFi, ONT, Oxford Nanopore Hi-C short reads -> Pore-C
        	3. HiFi, ONT, Illumina F1, dam, and sire short reads -> Trio
        	4. HiFi + error-corrected ONT -> HERRO, ONT, Omni-C
        	5. HiFi-HERRO, ONT, Pore-C
        	6. HiFi-HERRO, ONT, Trio
        	7. HiFi + Oxford Nanopore error-corrected ONT -> Duplex, ONT, Omni-C
        	8. HiFi-Duplex, ONT, Pore-C
        	9. HiFi-Duplex, ONT, Trio
        	10. HiFi (downsampled to match error-corrected data (36x)) -> HiFi-36x, ONT, Omni-C
        	11. HiFi-36x, ONT, Pore-C
        	12. HiFi-36x, ONT, Trio
        	13. HERRO, ONT, Omni-C
        	14. HERRO, ONT, Pore-C
        	15. HERRO, ONT, Trio
        	16. Duplex, ONT, Omni-C
        	17. Duplex, ONT, Pore-C
        	18. Duplex, ONT, Trio
        	19. HiFi-Duplex, ONT, Pore-C, Trio (best assembly)


- Using the best quality assembly (19 in the list above), this project also highlights the improvements over several current NCBI references:
  -*Bos indicus*
    - **[NIAB-ARS_B.indTharparkar_mat_pri_1.0](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_029378745.1/)** 
      - Sahiwal x Tharparkar
      - haploid (maternal haplotype)
      - female calf 
      - PacBio Sequel
      - TrioCanu v. 2.0
            	
  -*Bos taurus*
    - **[ARS-UCD2.0](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_002263795.3/)** 
      - Hereford
      - diploid/haploid 
      - male 11 yrs
      - Dominette left lung
      - PacBio; Illumina NextSeq 500; Illumina HiSeq; Illumina GAII
      - Falcon v. FEB-2016 
	
  - *Bos indicus* x *Bos taurus*
    - **[UOA_Angus_1](https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_003369685.2/)**
      - Angus x Brahman F1 hybrid
      - haploid pseudohaplotype (principal haplotype)
      - male fetus
      - PacBio RSII; PacBio Sequel; Illumina NextSeq
      - TrioCanu v. 1.6

    - **[UOA_Brahman_1](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_003369695.1/)**
	  - Angus x Brahman F1 hybrid
	  - haploid pseudohaplotype (alternate haplotype)
	  - male fetus
	  - PacBio Sequel; PacBio RSII; Illumina NextSeq
	  - TrioCanu v. 1.6


---



### **Contents**
- `Raw Data Processing`
    - Data statistics

- `Verkko Assembly Run Details`
    - GraphAligner

- `Assembly Comparisons`
    - Assembly statistics
    - T2T contigs/scaffold bargraph

- `Assembly Curation`
    - Detailed steps on curation of gaps, rDNA, and telomeres
        - Gap fixes conversion for Verkko scripts
        - rDNA conversion from morph to patch for Verkko script
        - Conkord script - counts copy number of genomic features

- `Example Files`
    - Files mentioned in scripts - for context

- `helper-scripts`
    - path translation between Bandage and Verkko scripts

- `Verkko-Fillet`
    - verkko-fillet scripts
        - README - specifically for running Verkko-Fillet from a python script; includes several precursor steps
        - chromosome translation between assembly and reference script
        - notes including modifications to Verkko-Fillet scripts; including additional formatting and creation of tables, files, and graphics for easy curation
    - T2T contig/scaffold heatmaps - all assemblies concatenated into a single file
    - rDNA information saved as table and string for easy Bandage usage (this is now included in run_verkko_fillet.sh)

