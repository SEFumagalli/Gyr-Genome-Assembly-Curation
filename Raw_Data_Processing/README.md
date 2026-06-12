# Raw Data Processing Scripts

All scripts are formatted for use on the Ceres cluster at the USDA.

To run statistics on the raw reads for all data types used in Gyr project, run merged_read_stats.sh.

**merged_read_stats.sh**

    *Scripts called:*
        - merged_read_stats.py
        - calcReadsOver100kb.py
        
    *Input:*
        - need python environment for >100kb stats and graphs
            - requires:
                - pandas as pd
                - matplotlib.pyplot as plt
                - argparse 
                - import sys
                - numpy as np
        - need access to seqkit module or download
        - paths to raw data fastq.gz files
            - names for general stat output files
            - names for general stat graphs
        - paths to raw data fastq.gz files that may be >100kb
            - names for >100kb stat output files
            - names for >100kb stat graphs
            
    *Output:*
        - csv table with all general and >100kb stats
        - bargraphs for coverage, N50, and sum length