#created by Sarah E. Fumagalli

## This script creates the chromosome.map file needed to run verkko-fillet
## This script calls create_chromosome_map.py

#!/bin/bash -l

#SBATCH --job-name=chromosome_map
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=short
#SBATCH --account=cattle_genome_assemblies
#SBATCH --chdir=/project/ruminant_t2t/existing_NCBI_references/Okapi
#SBATCH --output=chromosome_map__%j.std
#SBATCH --error=chromosome_map__%j.err


## Script Output: 
##		  unzipped reference_assembly.fna
##		  reference_assembly.fna.fai
##		  reference_assembly.chr.fna - includes chromosome names
##		  reference_assembly.chr.fna.fai  
##	   	  chromosome.map - if not provided


date


##INPUTS TO CONSIDER:

### 1) If you are downloading NCBI assembly.fna.gz and assembly_report.txt, add paths here ---------------------------------------------------------------------
###    If you already have these files downloaded, hash out out the lines below and run 2) or 3)

echo "downloading reference fasta"
reference_path=https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/024/291/935/GCA_024291935.2_TBG_Okapi_asm_v1/GCA_024291935.2_TBG_Okapi_asm_v1_genomic.fna.gz
report_path=https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/024/291/935/GCA_024291935.2_TBG_Okapi_asm_v1/GCA_024291935.2_TBG_Okapi_asm_v1_assembly_report.txt

wget $reference_path
wget $report_path

sequence_report=$(basename ${report_path})
reference=$(basename ${reference_path})


## OR ##


#   ***reference assembly.fna can be zipped or unzipped***


### 2) If the NCBI sequence_report.tsv or assembly_report.txt is downloaded and the chromosome.map needs to be created, unhash this section ---------------

#echo "create chromosome.map and update reference"
#reference='GCA_024291935.2_TBG_Okapi_asm_v1_genomic.fna'
#sequence_report='GCA_024291935.2_TBG_Okapi_asm_v1_assembly_report.txt'
#map_file=""


## OR ##


### 3) If the chromosome.map file was manually created (see details below on formatting), there is no need for the assembly or sequence report file -----------

#echo "chromosome.map given, update assembly.fasta"
#reference='GCA_024291935.2_TBG_Okapi_asm_v1_genomic.fna.gz'
#sequence_report=""
#map_file='manual_chromosome.map'


#--------------------------------------------------------------------------------------------------------------------------------------------------------------


### chromosome.map formating ###

# ****if no sequence_report.tsv file exists on NCBI -OR- more curation steps are needed beyond what the sequence_report.tsv can provide****

## 1) Create chromosome map file
##	- this file will have no header, no index, just two columns: 1) RefSeq identifier and 2) chromosome number
##	- make note of the formatting in the second column - do not forget to use '_'
##	- example:
##		NC_037328.1     chr_1
##		NC_037329.1     chr_2
##		NC_037330.1     chr_3
##		NC_037331.1     chr_4
##		NC_037332.1     chr_5
##		NC_037333.1     chr_6
##		NC_037334.1     chr_7
##		NC_037335.1     chr_8
##		NC_037336.1     chr_9
##		NC_037337.1     chr_10
##		NC_037338.1     chr_11
##		NC_037339.1     chr_12
##		NC_037340.1     chr_13
##		NC_037341.1     chr_14
##		NC_037342.1     chr_15
##		NC_037343.1     chr_16
##		NC_037344.1     chr_17
##		NC_037345.1     chr_18
##		NC_037346.1     chr_19
##		NC_037347.1     chr_20
##		NC_037348.1     chr_21
##		NC_037349.1     chr_22
##		NC_037350.1     chr_23
##		NC_037351.1     chr_24
##		NC_037352.1     chr_25
##		NC_037353.1     chr_26
##		NC_037354.1     chr_27
##		NC_037355.1     chr_28
##		NC_037356.1     chr_29
##		NC_037357.1     chr_X
##		NC_082638.1     chr_Y 
##

## **Alternate method: This script can also be used if your reference.fasta was produced from running hifiasm or 
## for whatever reason have an extra column of information to map**
##
## 1) Create extended chromosome map file
##	- !! name this file something OTHER THAN chromosome.map - it will be rewritten otherwise
##      - this file will have no header, no index, just three columns: 1) ID, 2) RefSeq identifier, & 3) chromosome number
##      - make note of the formatting in the second column - do not forget to use '_'
##      - example:
##        	h1tg000033l     NC_000001.1     chr_1
##		h2tg000020l_h2tg000029l NC_000002.1     chr_2
##		h1tg000005l     NC_000003.1     chr_3
##		h1tg000017l     NC_000004.1     chr_4
##		h1tg000020l     NC_000005.1     chr_5
##		h1tg000014l     NC_000006.1     chr_6
##		h1tg000003l     NC_000007.1     chr_7
##		h1tg000019l     NC_000008.1     chr_8
##		h1tg000004l     NC_000009.1     chr_9
##		h1tg000032l     NC_000010.1     chr_10
##		h1tg000030l     NC_000011.1     chr_11
##		h1tg000001l     NC_000012.1     chr_12
##		h1tg000016l     NC_000013.1     chr_13
##		h1tg000008l     NC_000014.1     chr_14
##		h1tg000002l     NC_000015.1     chr_15
##		h1tg000018l     NC_000016.1     chr_16
##		h2tg000021l     NC_000017.1     chr_17
##		h1tg000036l     NC_000018.1     chr_18
##		h1tg000026l     NC_000019.1     chr_19
##		h2tg000012l_h2tg000034l NC_000020.1     chr_20
##		h1tg000021l     NC_000021.1     chr_21
##		h1tg000013l     NC_000022.1     chr_22
##		h1tg000012l     NC_000023.1     chr_23
##		h1tg000009l     NC_000024.1     chr_24
##		h2tg000007l_h2tg000031l NC_000025.1     chr_25
##		h1tg000025l     NC_000026.1     chr_26
##		h1tg000022l_h1tg000035l NC_000027.1     chr_27
##		h2tg000025l     NC_000028.1     chr_28
##		h1tg000011l     NC_000029.1     chr_X
##		h1tg000024l     NC_000030.1     chr_Y
##
##
## ----------------------------------------------------------------------------------------------------------------------------------




#grab file names
sequence_report=$(basename ${report_path})
reference=$(basename ${reference_path})


#check reference file 
if [[ $reference =~ \.gz$ ]]; then
	echo "unzipping reference"
	pigz -d $reference
	reference="$(basename $reference .gz)"
	echo "$reference"
else
	echo "reference does not need unzipping"
fi


#create list of ids from genomic assembly
echo "creating assembly fai"
module load seqkit
seqkit faidx $reference
reference_ids="${reference}.fai"


micromamba activate jcvi

#check if sequence_report.tsv is provided
echo "checking/creating chromosome.map file"
if [ -z "$sequence_report" ]; then
	echo "no sequence_report.tsv provided - chromosome.map or a version of must be provided above for map_file"
else	
	#create chromosome.map using sequence_report.tsv and reference.fna.fai
	echo "using sequence_report.tsv to create chromosome.map"
	python3 /project/cattle_genome_assemblies/config_files_scripts/verkko-fillet/create_chromosome_map.py --reference_ids $reference_ids --sequence_report $sequence_report
	map_file='chromosome.map'
fi

#check if map_file is identified
echo "update reference files with chromosomes"
if [ -z "$map_file" ]; then
	echo "map_file is an empty string - map_file should be provided at the top of this script or created by providing sequence_report.tsv"
else
	#update reference.fna with chromosome names
	echo "using map_file to updated reference.fna with chromosome names"
	python3 /project/cattle_genome_assemblies/config_files_scripts/verkko-fillet/add_chr_reference.py --chromosome_map $map_file --reference $reference
fi

#update reference.fna.fai with chromosome names
echo "creating assembly fai with chromosome names"
base="${reference%.*}"
ext="${reference##*.}"
updated_reference="${base}.chr.${ext}"
echo "$updated_reference"

seqkit faidx $updated_reference	

date

