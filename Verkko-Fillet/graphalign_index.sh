#created by Ben Rosen

## GraphAligner is used to align the ONT data to the assembly graph. 

#!/bin/bash -l

#SBATCH --job-name=GraphAligner_index
#SBATCH --cpus-per-task=16
#SBATCH --ntasks=1
#SBATCH --partition=ceres
#SBATCH --mem-per-cpu=18027
#SBATCH --time=1-00:00:00
#SBATCH --chdir=/90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec/8-manualResolution/
#SBATCH --output=GA_index__%j.std
#SBATCH --error=GA_index__%j.err

date

micromamba activate verkko-v2.2.1

touch empty.fasta

GraphAligner -t 16 -g ../5-untip/unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.gfa -f empty.fasta -a empty.gaf \
       --diploid-heuristic 21 31 --diploid-heuristic-cache diploid.index \
       --seeds-mxm-cache-prefix manual \
       --bandwidth 15 \
       --seeds-mxm-length 30 \
       --mem-index-no-wavelet-tree \
       --seeds-mem-count 10000 && touch graph.index

date
