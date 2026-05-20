#created by Sarah E. Fumagalli


## ----------------------------------------------------------------------------------------------
## This script grabs the translation, T2T contigs, and T2T scaffold files for each assembly. 
##
## Inputs for each assembly: translation_hap1
## 	   		     translation_hap2
## 	   		     assembly.t2t_ctgs
## 	   		     assembly.t2t_scfs 
##
## Easily add or subtract the number of assemblies by adding or removing the number of lists
## and filenames (sh file), and arguments and file list (py file).
##
## Output: bargraph png
## ----------------------------------------------------------------------------------------------


import pandas as pd
import numpy as np
import sys
import openpyxl
import matplotlib.pyplot as plt
import argparse 
import seaborn as sns
from matplotlib.colors import ListedColormap

#pd.set_option('display.max_columns', None)
#pd.set_option('display.max_rows', None)


parser=argparse.ArgumentParser()

parser.add_argument("--lista", nargs="*", default=[])
parser.add_argument("--listb", nargs="*", default=[])
parser.add_argument("--listc", nargs="*", default=[])
parser.add_argument("--listd", nargs="*", default=[])
parser.add_argument("--liste", nargs="*", default=[])
parser.add_argument("--listf", nargs="*", default=[])
parser.add_argument("--listg", nargs="*", default=[])
parser.add_argument("--listh", nargs="*", default=[])
parser.add_argument("--listi", nargs="*", default=[])
parser.add_argument("--listj", nargs="*", default=[])
parser.add_argument("--listk", nargs="*", default=[])
parser.add_argument("--listl", nargs="*", default=[])
parser.add_argument("--listm", nargs="*", default=[])
parser.add_argument("--listn", nargs="*", default=[])
parser.add_argument("--listo", nargs="*", default=[])
parser.add_argument("--listp", nargs="*", default=[])
parser.add_argument("--listq", nargs="*", default=[])
parser.add_argument("--listr", nargs="*", default=[])
parser.add_argument("--lists", nargs="*", default=[])
parser.add_argument("--filenames", nargs="*", default=[])
parser.add_argument("--bargraph", help='bargraph file name')

args = parser.parse_args()

#create a list of lists
files = [args.lista, args.listb, args.listc, args.listd, args.liste, args.listf, args.listg, args.listh, args.listi, 
        args.listj, args.listk, args.listl, args.listm, args.listn, args.listo, args.listp, args.listq, args.listr, args.lists]
file_names = args.filenames
graph_name = args.bargraph



def haplo_check(string, hap_list):
    """
    
    If string not found in hap_list, it is added. 
    
    """

    if string not in hap_list:
            hap_list.append(string)
            

def stackedbar(bargraph_df1, bargraph_df2, bargraph_df3, graph_name):
    """

    Creates stacked bar graph for each haplotype and assembly.
    Output: bargraph.png

    """
    
    #set subplot arrangment
    fig, axes = plt.subplots(nrows=3, ncols=1, figsize=(14,10), gridspec_kw={'height_ratios':[2,2,2], 'wspace':0.1, 'hspace':0.1, 'left':0.17})
    
    #associate dfs with location
    bargraph_df1.plot(ax=axes[0], kind='barh', stacked=True, title = 'Haplotype 1', sharex=True, sharey=False, legend=False, width=0.7)
    bargraph_df2.plot(ax=axes[1], kind='barh', stacked=True, title = 'Haplotype 2', sharex=True, sharey=False, legend=False, width=0.7)
    bargraph_df3.plot(ax=axes[2], kind='barh', stacked=True, title = 'Assembly', sharex=True, sharey=False, legend=False, width=0.7)
    axes[0].set_yticklabels(bargraph_df1['Assembly'])    
    axes[1].set_yticklabels(bargraph_df2['Assembly'])
    axes[2].set_yticklabels(bargraph_df3['Assembly'])
    axes[0].set_xticklabels([])
    axes[1].set_xticklabels([])
    axes[2].set_xticklabels([])
    fig.suptitle('            Gyr T2T Contig and Scaffold Counts', size=14)
    fig.supylabel('Assembly')
    axes[1].set_xlabel('Count')
    for i in [0,1,2]:
        for bar in axes[i].patches:
            height = bar.get_height()
            width = bar.get_width()
            if height > 0 and width > 0:
                x = bar.get_x()
                y = bar.get_y()
                label_text = int(width)
                label_x = x + width / 2
                label_y = y + height / 2
                axes[i].text(label_x, label_y, label_text, ha='center', va='center', fontsize='small')
    plt.legend(loc=(1.02, 1.5))
    plt.savefig(graph_name + '.png', bbox_inches='tight', dpi=300)
    plt.show()
    plt.close()


print('preparing dfs')
hap1_df_list = []
hap2_df_list = []
chromo_contigs_scaffs1 = []
chromo_contigs_scaffs2 = []
contigs_scaffs_tot = []
#find and store data of interest from each file
for index, f in enumerate(files):
    print(file_names[index])
    haplotype1_list = []
    haplotype2_list = []
    ctgs_list1 = []
    ctgs_list2 = []
    scfs_list1 = []
    scfs_list2 = []
    trans1_dict = {'Haplotype': [], 'Chromosome': []}
    trans2_dict = {'Haplotype': [], 'Chromosome': []}
    for g in f:
        with open(g, 'r') as file:
            for line in file:
                line = line.strip()            
                if 't2t_ctgs' in g:
                    if 'haplotype' in line:
                        if 'haplotype1' in line:
                            haplo_check(line, haplotype1_list)
                            ctgs_list1.append(line)
                        else:
                            haplo_check(line, haplotype2_list)
                            ctgs_list2.append(line)
                    if 'compressed' in line:
                        if 'dam' in line:
                            haplo_check(line, haplotype1_list)
                            ctgs_list1.append(line)
                        else:
                            haplo_check(line, haplotype2_list)
                            ctgs_list2.append(line)
                        
                if 't2t_scfs' in g:
                    if 'haplotype' in line:
                        if 'haplotype1' in line:
                            haplo_check(line, haplotype1_list)
                            scfs_list1.append(line)
                        else:
                            haplo_check(line, haplotype2_list)
                            scfs_list2.append(line)
                    if 'compressed' in line:
                        if 'dam' in line:
                            haplo_check(line, haplotype1_list)
                            scfs_list1.append(line)
                        else:
                            haplo_check(line, haplotype2_list)
                            scfs_list2.append(line)

                if 'translation_hap1' in g:
                    haplo, chromo, start, stop = line.split('\t')
                    haplo_check(haplo, haplotype1_list)
                    trans1_dict['Haplotype'].append(haplo)
                    trans1_dict['Chromosome'].append(chromo[12:])
                    
                if 'translation_hap2' in g:
                    haplo, chromo, start, stop = line.split('\t')
                    haplo_check(haplo, haplotype2_list)
                    trans2_dict['Haplotype'].append(haplo)
                    trans2_dict['Chromosome'].append(chromo[12:])
    
    #add assembly name, chromosome, ctgs, and scfs counts
    chromo_contigs_scaffs1.append([file_names[index], sum(x is not np.nan for x in ctgs_list1), sum(x is not np.nan for x in scfs_list1)]) 
    chromo_contigs_scaffs2.append([file_names[index], sum(x is not np.nan for x in ctgs_list2), sum(x is not np.nan for x in scfs_list2)]) 
    contigs_scaffs_tot.append([file_names[index], sum(x is not np.nan for x in ctgs_list1) + sum(x is not np.nan for x in ctgs_list2), sum(x is not np.nan for x in scfs_list1) + sum(x is not np.nan for x in scfs_list2)])
    

print('creating bar graph')
#create stacked bar graph
bargraph_df1 = pd.DataFrame(chromo_contigs_scaffs1, columns=['Assembly', 'Contig', 'Scaffold'])
bargraph_df2 = pd.DataFrame(chromo_contigs_scaffs2, columns=['Assembly', 'Contig', 'Scaffold'])
bargraph_df3 = pd.DataFrame(contigs_scaffs_tot, columns=['Assembly', 'Contig', 'Scaffold'])

stackedbar(bargraph_df1, bargraph_df2, bargraph_df3, graph_name)

