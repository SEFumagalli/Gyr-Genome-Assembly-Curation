#!/bin/bash -l

#created by Sarah E. Fumagalli

#SBATCH --job-name=moddotplot
#SBATCH --cpus-per-task=96
#SBATCH --ntasks=1
#SBATCH --partition=ceres
#SBATCH --account=cattle_genome_assemblies
#SBATCH --qos=agil
#SBATCH --mem=1000G
#SBATCH --time=2-00:00:00
#SBATCH --chdir=/90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec/9-post_assembly_analysis/moddotplot
#SBATCH --output=moddotplot__%j.std
#SBATCH --error=moddotplot__%j.err

date


source /project/cattle_genome_assemblies/packages/ModDotPlot/mod_env/bin/activate

/project/cattle_genome_assemblies/packages/ModDotPlot/venv/bin/moddotplot static -f *.fasta \
	-o "results" \
	--compare \
	--grid \
    --dpi 300 \
	--identity 90


date
