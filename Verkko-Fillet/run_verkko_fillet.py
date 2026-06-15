#created by Sarah E. Fumagalli

# 1.Load modules

import sys
import importlib
import pandas as pd
import time
import argparse
import os
import warnings
import session_info
from lxml import html
import shutil
from Bio import SeqIO
import seaborn as sns
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap
sys.path.append( '/project/cattle_genome_assemblies/config_files_scripts/verkko-fillet/' )
import translation_merge_table_plot
import json

# Suppress FutureWarnings
warnings.simplefilter(action='ignore', category=FutureWarning)

import verkkofillet as vf
importlib.reload(vf)


# 1.Load input

parser=argparse.ArgumentParser()

parser.add_argument("--verkko_directory", type=str, help='verkko directory pathway')
parser.add_argument("--main_directory", type=str, help='main directory pathway')
parser.add_argument("--rDNA_fasta", type=str, help='rDNA reference fasta')
parser.add_argument("--ref_fasta", type=str, help='reference fasta')
parser.add_argument("--phase_datatype", type=str, help='type of phasing data used (trio_hic, trio, or hic)')
parser.add_argument("--exp_chr_num", type=int, help='expected number of chromosomes - overshooting is better than undershooting')
parser.add_argument("--gaps", type=str, help='do you want to identify the gaps?')
parser.add_argument("--mashmap_id_threshold", type=int, help='mashmap identity threshold - default: 95')
parser.add_argument("--rDNA_fasta_fai", type=str, help='assembly rDNA fasta fai')
parser.add_argument("--new_row", help='dictionary including new row to be added to translation file')

args = parser.parse_args()


# 2.Set up verkko-fillet directory

verkkoDir=args.verkko_directory
main_dir=args.main_directory

#unhash check_symlinks(verkkoDir) below if rerunning vf and the symlinks were deleted
def check_symlinks(verkkoDir):

    #check for symlink
    targets = [verkkoDir[:-1] + "_verkko_fillet/assembly.fasta", verkkoDir[:-1] + "_verkko_fillet/assembly.scfmap", verkkoDir[:-1] + "_verkko_fillet/assembly.colors.csv", verkkoDir[:-1] + "_verkko_fillet/assembly.homopolymer-compressed.noseq.gfa", verkkoDir[:-1] + "_verkko_fillet/assembly.paths.tsv"]
    paths = [verkkoDir + "assembly.fasta", verkkoDir + "assembly.scfmap", verkkoDir + "assembly.colors.csv", verkkoDir + "assembly.homopolymer-compressed.noseq.gfa", verkkoDir + "assembly.paths.tsv"]

    for i,j in enumerate(targets):
        if os.path.islink(j):
            #verify
            if os.path.islink(paths[i]):
                print(f"{j} points to {os.readlink(paths[i])}")
            else:
                print(f"{j} symlink is broken")
                #unlink
                os.unlink(j)
                print(f"Symlink '{j}' deleted successfully.")
                #add add new symlink to vf folder
                print("adding symlink for " + paths[i])
                os.symlink(paths[i], j)
                #verify
                if os.path.islink(paths[i]):
                    print(f"{j} points to {os.readlink(paths[i])}")
        else:
            #add symlink to vf folder
            print("adding symlink for " + paths[i])
            os.symlink(paths[i], j)
            #verify
            if os.path.islink(paths[i]):
                print(f"{j} points to {os.readlink(paths[i])}")
#check_symlinks(verkkoDir)


obj = vf.pp.read_Verkko(verkkoDir)

os.chdir(obj.verkko_fillet_dir)

print(obj.verkko_fillet_dir)


# 3.Calculate T2T stats

vf.tl.getT2T(obj)


# 4.Collapse rDNA nodes

vf.tl.rmrDNA(obj, rDNA_sequence=args.rDNA_fasta)


#fofn = "/90daydata/ruminant_t2t/Gyr/assembly/illumina/F1"
#kmerPrefix="child_illumina"
#vf.tl.mkMeryl(obj, fofn, prefix=kmerPrefix)
#vf.tl.calQV(obj, prefix=kmerPrefix)



# 5.Chromosome assignment
if os.path.isfile(main_dir + "chromosome.map"):
    print('chromosome.map exists')
    map_file = main_dir + "chromosome.map"
else:
    print('chromosome.map missing: ' + main_dir)
    sys.exit('chromosome.map not found - please refer to README')

                                          
vf.tl.convertRefName(args.ref_fasta, map_file, out_fasta="converted_reference")

#force chrAssign to rerun and recreate the translation files -- add flag: force=True
#to rerun chrAssign -- must unhash convertRefName and #5 Chromosome assignment if loop 
#if you modified the translation_hap files in chromosome_assignment vf folder and you want to recreate everything downstream, hash out chrAssign and convertRefName
vf.tl.chrAssign(obj = obj, ref = "converted_reference", datatype=args.phase_datatype, chr_num=args.exp_chr_num, id_thr=args.mashmap_id_threshold)


#Create translation_merge file and contigPlot
print('uploading plot files')

#if previously ran verkko-fillet and a T2T contig/scaffold was not associated with a chromosome was noted in the .std file
#identify associated chromosome in mashmap
#now you need to add a new row to a translation file with your data
#use this flag in the sh file: --new_row to add a dictionary containing the contig name, chr name, seq length, and ref length
if args.new_row is not None:
    new_row = json.loads(args.new_row)
else:
    new_row = {}

#if you want to remove a duplicate from appearing in the final files, hash out steps 3-5 and manually remove the duplicate from translation files

ctgs, scfs, translation_hap1, translation_hap2, telo, gap, scfmap, paths, rDNA = translation_merge_table_plot.upload_files(verkkoDir, args.rDNA_fasta_fai, new_row)

print('combine scfmap and paths')
scfmap_paths = pd.concat([scfmap, paths], axis=1).reset_index()
scfmap_paths = scfmap_paths.rename(columns={'level_0': 'path name'}).set_index('index')

print('looking for duplicates')
translation_hap1, translation_hap2, scfs, ctgs, telo, gap, scfmap_paths = translation_merge_table_plot.duplicate_contig_check(translation_hap1, translation_hap2, scfs, ctgs, telo, gap, scfmap_paths)

translation_hap1, translation_hap2 = translation_merge_table_plot.duplicate_chr_check(translation_hap1, translation_hap2)

print('reorder chromosomes')
translation_hap1, translation_hap2 = translation_merge_table_plot.reorder(translation_hap1, translation_hap2, args.exp_chr_num)

print('merging files')
translation = pd.concat([translation_hap1, translation_hap2], axis=0)
translation_merged, translation_merged_all, rDNA_string = translation_merge_table_plot.merge(translation, ctgs, scfs, telo, gap, scfmap_paths, rDNA)

print('check T2T ctgs and scfs')
missing_chr_matches = translation_merged.loc[(translation_merged['chr'].isna())]
temp_df = pd.DataFrame()

#drop columns of all nan
df_cleaned = missing_chr_matches.dropna(axis=1, how='all')

#check for columns ctgs and scfs
if 'ctgs' in df_cleaned.columns and 'scfs' in df_cleaned.columns:
    print('temp_df has both ctgs and scfs')
    temp_df_both = df_cleaned.loc[(df_cleaned['ctgs'] > 0) & (df_cleaned['scfs'] > 0)]
    temp_df_ctgs = df_cleaned.loc[(df_cleaned['ctgs'] > 0)]
    temp_df_scfs = df_cleaned.loc[(df_cleaned['scfs'] > 0)]
    df_list = []
    for i in [temp_df_both, temp_df_ctgs, temp_df_scfs]:
        if len(i) > 0:
            df_list.append(i)
    if len(df_list) > 0:
        temp_df = pd.concat(df_list, axis=0).drop_duplicates()

if 'ctgs' in df_cleaned.columns and 'scfs' not in df_cleaned.columns:
    print('temp_df has ctgs only')
    temp_df = df_cleaned.loc[(df_cleaned['ctgs'] > 0)]

if 'ctgs' not in df_cleaned.columns and 'scfs' in df_cleaned.columns:
    print('temp_df has scfs only')
    temp_df = df_cleaned.loc[(df_cleaned['scfs'] > 0)]

if temp_df.shape[0] > 0:
    print('WARNING: not all T2T ctgs/scfs are associated with a chromosome')
    print('Update translation files, then remerge')
    print(temp_df)
    print('find information on these contigs in verkko-fillet/chromosome_assignment/assembly.mashmap.out file')
    print('activate --new_row flag with mashmap data in dict format -- rerun verkko-fillet according to README')
else:
    print('all ctgs and scfs are associated with a chromosome')



print('saving merged file')
translation_merged.to_csv('chromosome_assignment/translation_merged.tsv', sep='\t', index=False)
translation_merged_all.to_csv('chromosome_assignment/utig_contig_chr_path_translation.tsv', sep="\t", index=False)
if len(rDNA_string) > 0:
    with open("rDNA_utigs_ids_Bandage.txt", "a") as f:
        f.write(rDNA_string)
    f.close()


print('creating heatmap')
tracker_dict = translation_merge_table_plot.contigPlot(translation_merged, args.phase_datatype, ctgs, scfs, verkkoDir, args.exp_chr_num)

print('sum columns in merged file')
df_summary = translation_merge_table_plot.summary_table(translation_merged, args.phase_datatype, tracker_dict)
df_summary.to_csv('chromosome_assignment/translation_merged_summary.tsv', sep='\t')


if args.phase_datatype != "hic":
    obj = vf.pp.readChr(obj, map_file, sire = "sire", dam = "dam")

# vf.tl.detect_internal_telomere(obj)
#intra_telo, tel =  vf.pp.find_intra_telo(obj)
#print(intra_telo)
#print(tel)

if args.gaps == 'True':

    print('processing gaps')
    # 6.Manual resolution

    # Finding gaps from path

    obj = vf.pp.findGaps(obj)


    #Create graphAlignment directory and save gaps file
    graph_dir = verkkoDir[:-1] + "_verkko_fillet/graphAlignment/"
    if not os.path.isdir(graph_dir):
        os.makedirs(verkkoDir[:-1] + "_verkko_fillet/graphAlignment/")
        obj.gaps.to_csv(graph_dir + "verkko_initial_gaps.csv", index=False, header=True)


    # Align ONT reads onto the graph

    #Check for files
    if os.path.exists(graph_dir + "verkko.graphAlign_allONT.gaf"):
        print("verkko.graphAlign_allONT.gaf exists.")
    else:
        print("verkko.graphAlign_allONT.gaf will be copied over")
        shutil.copyfile(verkkoDir + "8-manualResolution/verkko.graphAlign_allONT.gaf", graph_dir + "verkko.graphAlign_allONT.gaf")

    if os.path.exists(graph_dir + "diploid.index"):
        print("diploid.index exists.")
    else:
        print("diploid.index does not exist.")
        shutil.copyfile(verkkoDir + "8-manualResolution/diploid.index", graph_dir + "diploid.index")

    if os.path.exists(graph_dir + "manual.index"):
        print("manual.index exists.")
    else:
        print("manual.index does not exist.")
        shutil.copyfile(verkkoDir + "8-manualResolution/manual.index", graph_dir + "manual.index")


    obj=vf.pp.readGaf(obj)


    # Save gaps file and associated node files as csvs

    gap_id = obj.gaps.gapId.values.tolist()
    gaps = obj.gaps.gaps.values.tolist()

    gaps_list = []
    for i,g in enumerate(gaps):
        node_list_input = [g[0][:-1], g[2][:-1]]
        styled_df = vf.pp.searchNodes(obj, node_list_input)
        styled_df.to_html(graph_dir + gap_id[i] + "_styled_df.html")
        result_df = pd.read_html(graph_dir + gap_id[i] + "_styled_df.html", flavor='lxml')[0]
        del result_df[result_df.columns[0]]
        result_df.to_csv(graph_dir + "verkko_" + gap_id[i] + "_nodes.csv", index=False, header=True)
        os.remove(graph_dir + gap_id[i] + "_styled_df.html")
        gaps_list.append(node_list_input)

    edited_gaps = pd.DataFrame(list(zip(gap_id, gaps_list)),columns =['gapId', 'gaps'])
    edited_gaps.to_csv(graph_dir + "verkko_edited_initial_gaps.csv", index=False, header=True)

else:
    print('skipping gaps')




