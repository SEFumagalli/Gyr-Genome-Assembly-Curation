#!/bin/bash -l

#SBATCH --job-name=moddotplot
#SBATCH --cpus-per-task=96
#SBATCH --ntasks=1
#SBATCH --partition=ceres
#SBATCH --account=cattle_genome_assemblies
#SBATCH --qos=agil
#SBATCH --mem=1000G
#SBATCH --time=2-00:00:00
#SBATCH --chdir=/90daydata/ruminant_t2t/Gyr/assembly/verkko2.2.1_hifi-duplex_tporec-og/9-post_assembly_analysis/moddotplot/ARS-UCD2.0/chr6
#SBATCH --output=moddotplot__%j.std
#SBATCH --error=moddotplot__%j.err

date


source /project/cattle_genome_assemblies/packages/ModDotPlot/mod_env/bin/activate


#mkdir -p logs


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Run ModDotPlot in static mode using the config.json
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#CONFIG files
#CONFIGS=("config-all_refs.json")

#	"../config-uncurated2.2.1.json"
#CONFIGS=("config-UOA_Angus_1.json")

#CONFIGS=("config-UOA_Brahman_1.json")
#CONFIGS=("../config-NIAB-ARS_B.indTharparkar_mat_pri_1.0.json")
#CONFIGS=("config-ARS-UCD2.0.json")

# Corresponding output directory names
#OUTDIRS=("uncurated2.2.1_hap1_vs_all_refs")

#	"uncurated2.2.1"
#OUTDIRS=("UOA_Angus_1")
#  	"UOA_Brahman_1"
#OUTDIRS=("NIAB-ARS_B.indTharparkar_mat_pri_1.0")
#  	"ARS-UCD2.0"
#)


# Select file and directory based on job array index
#CONFIG=${CONFIGS[$SLURM_ARRAY_TASK_ID - 1]}
#OUTDIR=${OUTDIRS[$SLURM_ARRAY_TASK_ID - 1]}


#echo "Processing $CONFIG"
#echo "Output directory: $OUTDIR"


# Create and enter directory
#mkdir -p "$OUTDIR"
#cd "$OUTDIR"


/project/cattle_genome_assemblies/packages/ModDotPlot/venv/bin/moddotplot static -f *.fasta \
	-o "results" \
	--compare \
	--grid \
        --dpi 300 \
	--identity 90




#cd ..

#echo "Finished processing files for $OUTDIR"


date
