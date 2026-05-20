# created by Sarah E. Fumagalli

## -----------------------------------------------------------------------
## This script collects each assembly's gfa haplotype stats and combines
## them in a single csv.
##
## Requirement: gfastats stat files created for each assembly
##
## Input for each assembly: haplotype1.fasta.stats
##                          haplotype2.fasta.stats
##
## Output: gfastats.csv
## -----------------------------------------------------------------------


import pandas as pd
import sys
import argparse
import matplotlib.pyplot as plt


pd.set_option('display.max_columns', None)
pd.set_option('display.max_rows', None)

parser=argparse.ArgumentParser()

parser.add_argument("--assemblies", nargs="+", help='array of assemblies')
parser.add_argument("--filenames", nargs="+", help='array of assembly names')
parser.add_argument("--tsv_gfa", type=str, help='tsv file name')
#parser.add_argument("--graphname", type=str, help='graph name')

args = parser.parse_args()

files = []
for i in args.assemblies:
    files.append(i + "/assembly_hap1_gfa.stats")
    files.append(i + "/assembly_hap2_gfa.stats") 

file_names = args.filenames
tsv_name = args.tsv_gfa
#graph_name1 = args.graphname


def bargraph(df, graph_name):
    """

    Creates N50 bar graph 

    """

    df = df.T
    ax = df['Contig N50'].plot(kind='barh', figsize=(8, 6), stacked=False, legend=False, title='Scaffold N50', xlabel='N50', ylabel='Assembly')
    plt.legend(loc=(1.02, 0.5))
    plt.savefig(graph_name + '.png', bbox_inches='tight')
    plt.close()



def divide_chunks(l, n):
    # looping till length l
    for i in range(0, len(l), n):
        yield l[i:i + n]


#read in stat files and combine data into dictionary
index_list = []
values_dict = {key: [] for key in file_names}
temp_hap_names = []
temp_assembly_names = []
for h,l in enumerate(files):
    if len(l) == 0:
        continue
    else: 
        temp_assembly_names.append(file_names[h][:-4])
        #print('temp_name=',file_names[h])
        if 'hap1' in l:
            temp_hap_names.append('Hap 1')
        else:
            temp_hap_names.append('Hap 2')
        with open(l, 'r') as file:
            #print(l)
            for j, line in enumerate(file):
                if j > 0:
                    line = line.strip()
                    header, value = line.split(': ')
                    value = value.strip()
                    #print('header=',header)
                    #print('value=',value)
                    if 'Base composition' in header:
                        #print('base')
                        A_count, C_count, G_count, T_count = value.split(':')
                        if h == 0:
                            #print('h == 0')
                            index_list.append('A count')
                            values_dict[file_names[h]].append(A_count)
                            index_list.append('C count')
                            values_dict[file_names[h]].append(C_count)
                            index_list.append('G count')
                            values_dict[file_names[h]].append(G_count)
                            index_list.append('T count')
                            values_dict[file_names[h]].append(T_count)
                        else:
                            #print('h != 0')
                            values_dict[file_names[h]].append(A_count)
                            values_dict[file_names[h]].append(C_count)
                            values_dict[file_names[h]].append(G_count)
                            values_dict[file_names[h]].append(T_count)
                    else:
                        #print('not base')
                        if h == 0:
                            #print('h == 0')
                            index_list.append(header)
                            values_dict[file_names[h]].append(value)
                        else: 
                            #print('h != 0')
                            values_dict[file_names[h]].append(value)
        
                    
#create df
df = pd.DataFrame(dict([ (k,pd.Series(v)) for k,v in values_dict.items() ])).T
df.columns = index_list

#add columns and set index
df['Assembly'] = temp_assembly_names
df['Haplotype'] = temp_hap_names
df = df.set_index(['Assembly', 'Haplotype'])

df = df.T
df.to_csv(tsv_name + '.tsv', sep="\t") 

#create bargraph
#row_list = map(int, df.loc['Scaffold N50'].values.flatten().tolist())
#row_list = list(row_list)
#temp_list = list(divide_chunks(row_list, 2))
#index_list = list(df.columns.get_level_values(0))
#df1 = pd.DataFrame(temp_list, index=index_list, columns=['Haplotype 1', 'Haplotype 2'])
#df1 = df1.astype(float).reset_index()
#bargraph(df, graph_name1)

