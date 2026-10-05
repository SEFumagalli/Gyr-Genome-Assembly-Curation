# Gyr Assembly vs NCBI References

---


1. **Filter assembly.fasta hapmers to include only chromosome-associated**
    
    - Run Verkko-Fillet with my modifications - see Verkko-Fillet directory
    
    - Run `convert_hapmers_2_chr.sh`
    
        This script creates a new assembly.fasta that renames hapmers to include chromosomes.
        
        - Tool: 
            - **[SeqKit](https://bioinf.shenwei.me/seqkit/)**
        
        - Input: 
            - verkko-fillet_assembly/chromosome_assignment/translation_merged.tsv  --> see Example_Files 
            - Verkko's assembly.fasta
            
        - Output:
            - assembly_chr.fasta
            - assembly_chr.fasta.fai
            
    - Run `filter_chr_fasta.py`
    
        This script creates a new assembly.fasta with only chromosome assigned hapmers.
        
        - Python env:
            import argparse
            from Bio import SeqIO
        
        - Input: 
            - assembly_chr.fasta
            - name of output file
            
        - Output:    
            - filtered_assembly_chr.fasta
            
            

2. **Download NCBI references and filter for chromosome-associated contigs**

    - Run `create_chrmap_update_ref.sh`
    
        This script grabs the reference NCBI files, creates a chromosome map, and converts contig names to include chromosome
        
        - Called sub-scripts:
            - `create_chromosome_map.py`
            
                - Python env: 
                    import pandas as pd
                    import argparse
            
            - `add_chr_reference.py`
            
                - Python env: 
                    import pandas as pd
                    import argparse
                    from Bio import SeqIO
        
        - Tool: 
            - **[SeqKit](https://bioinf.shenwei.me/seqkit/)**
        
        - Input: 
            - NCBI path (example: https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/003/369/695/GCF_003369695.1_UOA_Brahman_1/GCF_003369695.1_UOA_Brahman_1_genomic.fna.gz)
            - report path (example: https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/003/369/695/GCF_003369695.1_UOA_Brahman_1/GCF_003369695.1_UOA_Brahman_1_assembly_report.txt)
            
            There are numerous ways to set up your input based on what you already have locally - see script for details
            
        - Output: 
            - NCBI_ref_assembly.fasta.fai
            - NCBI_ref_assembly_chr.fasta
            - NCBI_ref_assembly_chr.fasta.fai
            - chromosome.map
            
            

3. **Download NCBI references BAM files**     

    UOA_Brahman_1
        wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/003/369/695/GCF_003369695.1_UOA_Brahman_1/RefSeq_transcripts_alignments/GCF_003369695.1_Bos_hybrid_MaternalHap_v2.0_modelrefseq_alns.bam
        wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/003/369/695/GCF_003369695.1_UOA_Brahman_1/RefSeq_transcripts_alignments/GCF_003369695.1_Bos_hybrid_MaternalHap_v2.0_modelrefseq_alns.bam.bai

    NIAB-ARS_B.indTharparkar_mat_pri_1.0
        wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/029/378/745/GCF_029378745.1_NIAB-ARS_B.indTharparkar_mat_pri_1.0/RefSeq_transcripts_alignments/GCF_029378745.1_NIAB-ARS_B.indTharparkar_mat_pri_1.0_modelrefseq_alns.bam
        wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/029/378/745/GCF_029378745.1_NIAB-ARS_B.indTharparkar_mat_pri_1.0/RefSeq_transcripts_alignments/GCF_029378745.1_NIAB-ARS_B.indTharparkar_mat_pri_1.0_modelrefseq_alns.bam.bai

    ARS-UCD2.0
        wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/002/263/795/GCF_002263795.3_ARS-UCD2.0/RefSeq_transcripts_alignments/GCF_002263795.3_ARS-UCD2.0_knownrefseq_alns.bam
        wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/002/263/795/GCF_002263795.3_ARS-UCD2.0/RefSeq_transcripts_alignments/GCF_002263795.3_ARS-UCD2.0_knownrefseq_alns.bam.bai

    UOA_Angus_1
        No BAM files to download
        
        
4. **Download UOA_Angus_1 HiFi data for the creation of a BAM file**

    - Run `SRA_download.sh`
    
        This script downloads all the PacBio runs, converts to fastq, trims and filters, then combines all data into single fastq.
    
        - Tool:
            - **[SRA Toolkit](https://github.com/ncbi/sra-tools/wiki/01.-Downloading-SRA-Toolkit)**
            
        - Input: 
            - NCBI project accession
            
        - Output: 
            - all_cleaned_pacbio.fastq.gz
            
            
5. **Filter NCBI reference FASTAs for chromosome-associated contigs**
    
    For all NCBI references

    - Tool: 
        - **[SeqKit](https://bioinf.shenwei.me/seqkit/)**
    
    awk '/^>/{keep = ($0 ~ /_chr_/)} keep' assembly.fasta > assembly_chr_only.fasta
    
    seqkit faidx assembly_chr_only.fasta

    
    
6. **Completeness assessment**

    - Run `busco.sh`
    
    - Tool:
        - **[BUSCO](https://busco.ezlab.org/busco_userguide.html#getting-started)**
    
    - Input: 
        - assembly_chr.fasta
        - cetartiodactyla_od10 library
        
    - Output: 
        - summary.txt
        - busco_report.txt
        
        
7. **Creat whole-genome BED file and its associated annotations file**

    For all NCBI references and Gyr assembly
    
    cat assembly.fna.fai | awk '{print $1"\t0\t"$2"}' > assembly.chr_only.bed
    echo "{" > annotations_path.json
    echo \"assembly\" : \"assembly.chr_only.bed\" >> annotations_path.json
    echo "}" >> annotations_path.json

   

8. **Generate or download from NCBI - add chromosome names**

    NIAB-ARS_B.indTharparkar_mat_pri_1.0 BAM file is available on NCBI.

    - Run `add_chr_BAM_header.sh`
    
        This script modifies a BAM file so the chromosome names are included. 
        
        - Tool:
            - **[Samtools](https://www.htslib.org/)**
            
        - Input: 
            - BED file 
            - BAM file
            
        - Output:
            - mapping.txt
            - old_header.sam
            - chr_labeled.bam
            - chr_labeled.bam.bai
            - chr_only.bam
            - chr_only.bam.bai
            
            
    Generated BAM file for UOA_Brahman_1, UOA_Angus_1, ARS-UCD2.0, and Gyr assembly. 
    
    - Run `meryl_winnowmap_filter.sh`
    
        This script uses Meryl to build a k-mer database and counts, then uses Winnowmap to align the assembly to the reads. 
        
        - Tools: 
            - **[Samtools](https://www.htslib.org/)**
            - **[meryl](https://github.com/marbl/meryl)**
            - **[Winnowmap](https://github.com/marbl/Winnowmap)**
            
        - Python env:
            verkko
    
        - Input:
            - assembly_chr.fasta
            - read.fastq
            - assembly.bam (only available for NIAB-ARS_B.indTharparkar_mat_pri_1.0)
            
        - Output:
            - repetitive_k21.txt    --> Meryl count database
            - assembly.sorted.bam
            - assembly.bam          --> includes MD tag
            - assembly.bam.bai
            - assembly_filtered.bam --> keeps primary alignments, mapped reads, and ignores supplementary fragments
            - assembly_filtered.bam
            
    
9. **Combine HiFi, Duplex, and ONT UL Winnowmap results for Gyr assembly**

    - Run `combine_hifi-duplex_ont.sh`
    
        This script merges multiple BAM files, resorts, and indexes
        
        - Tool:
            - **[Samtools](https://www.htslib.org/)**
                   
        - Input: 
            - hifi-duplex/assembly_filtered.bam
            - ont/assembly_filtered.bam
            
        - Output:
            - assembly_filtered.bam     --> concatenated and sorted bam 
            - assembly_filtered.bam.bai 
            
            
10. **Grab specific chromosomes from BAM files**

    For all NCBI references and Gyr assembly
    
    - Tool:
        - **[Samtools](https://www.htslib.org/)**

    samtools view -b assembly_filtered.bam "chr_4" > assembly_chr4_only.bam
    samtools view -b assembly_filtered.bam "chr_6" > assembly_chr6_only.bam
    samtools view -b assembly_filtered.bam "chr_14" > assembly_chr14_only.bam

    samtools index assembly_chr4_only.bam
    samtools index assembly_chr6_only.bam
    samtools index assembly_chr14_only.bam



11. **Grab specific chromosomes from BED and FASTA files**

    For all NCBI references and Gyr assembly
    
    grep -E "chr_4" assembly.chr_only.bed > assembly.chr4_only.bed
    grep -E "chr_6" assembly.chr_only.bed > assembly.chr6_only.bed
    grep -E "chr_14" assembly.chr_only.bed > assembly.chr14_only.bed

    samtools faidx assembly.chr_only.fna.fai "chr_4" > assembly.chr4_only.fna
    samtools faidx assembly.chr_only.fna.fai "chr_6" > assembly.chr6_only.fna
    samtools faidx assembly.chr_only.fna.fai "chr_14" > assembly.chr14_only.fna

    samtools faidx assembly.chr4_only.fna
    samtools faidx assembly.chr6_only.fna
    samtools faidx assembly.chr14_only.fna
    
   
    
12. **Compare different types of mis-assemblies**

    - Run `bam_2_cov-flagger.sh`
    
        This script reports several types of mis-assemblies - erroneous, duplicated, haploid, and collapsed
        
        - Tool:
            - **[HMM-Flagger](https://github.com/mobinasri/flagger/)**
        
        - Input: 
            - assembly_filtered.bam
            - annotations_path.json
            
        - Output:
            - coverage_file.cov.gz
            - results.tsv
        
    
    - Run `nucflag.sh`
    
        This script creates nuclotide frequency plots and includes mis-assembly info
        
        - Tool: 
            - **[NucFlag](https://github.com/logsdon-lab/NucFlag)**
        
        - Input: 
            - assembly_filtered.bam
            - assembly_chr.bed

        - Output: 
            - mis-assembly plots 
            - BED files
            
            
    - Run `nucfreq.sh`
    
        This script creates read depth plots and BED files
        
        - Tool: 
            - **[NucFreq](https://github.com/vollgerlab/NucFreq)**
        
        - Input: 
            - assembly_filtered.bam
            - assembly_chr.bed
        
        - Output: 
            - read depth plots
            - BED files    
            
            

13. **Compare sequence repeats**

    - Run `repeatmasker.sh`
    
        This script identifies the number of elements (LINEs, SINEs, LTRs, DNA, unclassified, interspersed, small RNA, satellites, simple repeats, and low complexity)
        
        - Tool: 
            - **[RepeatMasker](https://github.com/Dfam-consortium/RepeatMasker/)**
        
        - Input:
            - assembly_chr.fasta
            - ~/RepeatMasker_4.0.6_lib/CONS-20160829/bos_taurus
            
        - Output:
            - repeat.tbl
            
            
            
14. **Compare assembly identity**

    - Run `moddotplot.sh`
    
        This script creates dot plot figures comparing each NCBI reference to the Gyr assembly
        
        - Tool: 
            - **[ModDotPlot](https://github.com/marbl/ModDotPlot)**
        
        - Input: 
            - NCBI_assembly.fasta
            - Gyr_assembly.fasta
        
        - Output: 
            - dot_plot.pdf
            - dot_plot.png
            - alignment.bed
    
    