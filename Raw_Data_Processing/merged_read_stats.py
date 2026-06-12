import pandas as pd
import numpy as np
import sys
import openpyxl
import matplotlib.pyplot as plt
import argparse 
import seaborn as sns
from matplotlib.colors import ListedColormap

pd.set_option('display.max_columns', None)
pd.set_option('display.max_rows', None)


parser=argparse.ArgumentParser()

parser.add_argument("--all_reads", nargs="+", help='array of read stats')
parser.add_argument("--select_reads", nargs="+", help='array of read stats over 100kb')
parser.add_argument("--all_reads_filenames",nargs="+", help='array of table headers for general stats')
parser.add_argument("--select_reads_filenames",nargs="+", help='array of table headers for >100kb stats')
parser.add_argument("--read_stats_tsv", type=str)
#parser.add_argument("--bargraph",help='bargraph file name')


args = parser.parse_args()


all_reads = args.all_reads
select_reads = args.select_reads
all_reads_file_names = args.all_reads_filenames
select_reads_file_names = args.select_reads_filenames
read_stats_tsv = args.read_stats_tsv
#graph_name = args.bargraph



def haplo_check(string, hap_list):
    if string not in hap_list:
            hap_list.append(string)
            

def bargraph(bargraph_df1, bargraph_df2, bargraph_df3, graph_name):
    fig, axes = plt.subplots(nrows=1, ncols=3, figsize=(8,5), gridspec_kw={'wspace':0.20, 'hspace':0.2, 'left':0.17})

    bargraph_df1.plot(ax=axes[0], kind='barh', sharex=False, sharey=False, legend=False, width=0.7)
    bargraph_df2.plot(ax=axes[1], kind='barh', title ='Gyr Raw Data Statistics', sharex=False, sharey=True, legend=False, width=0.7)
    bargraph_df3.plot(ax=axes[2], kind='barh', sharex=False, sharey=True, legend=False, width=0.7)
    fig.supylabel('Data Type')
    axes[0].set_xlabel('Coverage')
    axes[1].set_xlabel('N50')
    axes[2].set_xlabel('Sum Length')
    axes[0].set_ylabel(' ')
    axes[1].set_ylabel(' ')
    axes[2].set_ylabel(' ')
    plt.savefig(graph_name + '.png', bbox_inches='tight', dpi=300)
    plt.show()
    plt.close()





print('preparing dfs')
def process_reads(reads, filenames):

    '''
    
    Combines general read stats and >100kb stats into single df

    '''
    
    #find and store data of interest from each file
    final_df_list = []
    #iterate through reads list of lists
    for i,read_list in enumerate(reads):
        df_list = []
        #iterate through data type stats
        for index, f in enumerate(read_list):
            #open file as df with no index
            temp_df = pd.read_csv(f, sep="\t", index_col=False)
            #rename index as data type
            temp_df.rename(index={0: filenames[i][index]}, inplace=True)
            #append all dfs in read_list
            df_list.append(temp_df)
            #after the last data type, concatenate dfs
            if index+1 == len(read_list):
                df_join = pd.concat(df_list, axis=0)
        #append concatenated df to list
        final_df_list.append(df_join)

    df = pd.concat(final_df_list, axis=1)
    df = df.drop(['file','format','type'], axis=1)
    df = df.apply(pd.to_numeric)
    return df

result = process_reads([all_reads, select_reads], [all_reads_file_names, select_reads_file_names])

result['Total Read Xcov (cattle)'] = result['sum_len'] / 3000000000
result.columns = ['Total Read Num', 'Total Read Bases', 'Min Read Bases', 'Avg Read Bases', 'Max Read Bases', 'Q1', 'Q2 (Median Read Bases)', 'Q3', 'Sum gap', 'N50', 'Q20(%)', 'Q30(%)', 'GC(%)', 'Reads >100kb Num', 'Reads >100kb Bases', 'Reads >100kb Xcov (cattle)', 'Total Read Xcov (cattle)']
result.to_csv(read_stats_tsv, sep="\t")


#print('creating bar graph')
#df = df.reset_index()
#bargraph_df1 = df[['index','Coverage']].copy().sort_values(by=['Coverage'],ascending=False)
#bargraph_df2 = df[['index','N50', 'Coverage']].copy().sort_values(by=['Coverage'],ascending=False)
#bargraph_df3 = df[['index','sum_len', 'Coverage']].copy().sort_values(by=['Coverage'],ascending=False)

#bargraph_df2 = bargraph_df2.drop(['Coverage'], axis=1)
#bargraph_df3 = bargraph_df3.drop(['Coverage'], axis=1)

#bargraph_df1 = bargraph_df1.set_index('index')
#bargraph_df2 = bargraph_df2.set_index('index')
#bargraph_df3 = bargraph_df3.set_index('index')

#bargraph(bargraph_df1, bargraph_df2, bargraph_df3, graph_name)

