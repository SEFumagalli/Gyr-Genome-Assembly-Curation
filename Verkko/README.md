#Running Verkko Assembler

**[Verkko](https://github.com/marbl/verkko)**

---

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
        