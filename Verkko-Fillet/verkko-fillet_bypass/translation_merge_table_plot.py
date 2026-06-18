# created by Sarah E. Fumagalli

import os
import seaborn as sns
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap
import pandas as pd
import argparse
from collections import OrderedDict
import numpy as np
import json
import sys

## -----------------------------------------------------------------------------
## 
## This file is executed via chromo_assesemnt.sh
## Script combines translation, ctgs, scfs, telomeres, gaps, scfmap names, and paths
## into one table. 
## Script also creates a graphic similar to Verkko-fillet contigPlot.
##
## -----------------------------------------------------------------------------


pd.set_option('display.max_rows', None)
pd.set_option('display.max_columns', None)

parser=argparse.ArgumentParser()

parser.add_argument("--verkkoDir", type=str, help='verkko directory pathway')
parser.add_argument("--phase_datatype", type=str, help='phase datatype')
parser.add_argument("--rDNA_fasta", type=str, help='rDNA reference fasta')
parser.add_argument("--num_chromosomes", type=int, help='number of expected chromosomes - including X and Y')
parser.add_argument("--rDNA_fasta_fai", type=str, help='assmbly rDNA fasta fai')
parser.add_argument("--new_row", help='dictionary including new row to be added to translation file')

args = parser.parse_args()



def contigPlot(translation_merged, datatype, ctgs, scfs, verkkoDir, num_chromos):
    """

    Creates heatmap capturing gaps, telomeres, contigs, and scaffolds for each chromosome
    Output: contigPlot.png

    """

    def chromo_double_check(chr_name, plt_dict, contig_name, translation_merged, index):
        """

        If chromosome name is already found in dictionary, expand naming.

        """

        if 'haplotype1' in translation_merged.at[index, 'index']:
            if 'Haplotype 1' in plt_dict.keys():
                if chr_name in plt_dict['Haplotype 1'].keys():
                    #print('chr_name in hap1')  
                    split = contig_name.split('-')
                    contig_name = 'hap1-' + split[1]
                    chr_name = contig_name + "_" + chr_name

        if 'haplotype2' in translation_merged.at[index, 'index']:
            if 'Haplotype 2' in plt_dict.keys():
                if chr_name in plt_dict['Haplotype 2'].keys():
                    #print('chr_name in hap2')
                    split = contig_name.split('-')
                    contig_name = 'hap2-' + split[1]
                    chr_name = contig_name + '_' + chr_name

        if 'sire' in translation_merged.at[index, 'index']:
            if 'Sire' in plt_dict.keys():
                if chr_name in plt_dict['Sire'].keys():
                    #print('chr_name in sire')
                    split = contig_name.split('-')
                    contig_name = 'sire-' + split[1]
                    chr_name = contig_name + '_' + chr_name

        if 'dam' in translation_merged.at[index, 'index']:
            if 'Dam' in plt_dict.keys():
                if chr_name in plt_dict['Dam'].keys():
                    #print('chr_name in dam')
                    split = contig_name.split('-')
                    contig_name = 'dam-' + split[1]
                    chr_name = contig_name + '_' + chr_name

        return chr_name


    def reorder(df, num_chromos):
        """

        Reorder df by chromosome names

        """
        #reindex using chromo_names
        num_list = list(range(1, num_chromos-1))
        num_list = list(map(str, num_list))
        chromo_names = [a + b for a, b in zip(['Chr']*num_chromos, num_list)]
        chromo_names += ['ChrX', 'ChrY']

        ordered_dict = OrderedDict()
        for i in chromo_names:
            #print('chromo=',i)
            for index, row in df.iterrows():
                if index.endswith(i):
                    #print('index=',index)
                    ordered_dict[index] = row.to_dict()

        df = pd.DataFrame.from_dict(ordered_dict, orient='index')

        return df


    #change labels
    if datatype == 'hic':
       plt_dict = {'Haplotype 1':{}, 'Haplotype 2': {}}       
    else:
       #plt_dict = {'Dam': {}, 'Sire':{}}
       plt_dict = {'Sire': {}, 'Dam':{}}
        

    #drop length, ref length and path name columns
    translation_merged = translation_merged.drop(['length', 'ref length', 'path name', 'path'], axis=1)
    
    #create ordered dict to capture unassigned contigs associated with a chromosome
    #this helps with the summary table
    tracker_dict = {}
 
    #format dictionary for plot
    for num, row in translation_merged.iterrows():
        #check for chromosome related rows only 
        if pd.isna(translation_merged.at[num, 'chr']):
            continue
        else:
            #format chromosome name
            name_split = row.iloc[1].split('_')     
            chr_name = 'Chr' + name_split[len(name_split)-1]
            chr_name = chromo_double_check(chr_name, plt_dict, row.iloc[0], translation_merged, num)

            #check if ctgs and scfs dfs are empty
            if ctgs.shape[0] == 0:
                if scfs.shape[0] == 0:
                    #print('no ctgs or scfs files')
                    #if telo number is less than 2 or NaN
                        if row['telomeres'] < 2 or pd.isna(row['telomeres']) == True:
                            #print('color3')
                            color = 3
                else:
                    #print('only scfs file')
                    if pd.isna(translation_merged.at[num, 'scfs']):
                        #check number of telomeres
                        if row['telomeres'] < 2 or pd.isna(translation_merged.at[num, 'telomeres']) == True:
                            color = 3
                    else:
                        #check for gaps
                        if pd.isna(translation_merged.at[num, 'gaps']):
                            continue
                        else:
                            color = 2
            else:
                if scfs.shape[0] == 0:
                    #print('only ctgs file')
                    continue
                else:
                    #print('both ctgs and scfs files')
                    if pd.isna(translation_merged.at[num, 'ctgs']):
                        #print('ctg not T2T')
                        #check for scaffold
                        if pd.isna(translation_merged.at[num, 'scfs']):
                            #print('scf not T2T')
                            #check number of telomeres
                            if row['telomeres'] < 2 or pd.isna(translation_merged.at[num, 'telomeres']) == True:
                                #print('1 telomere or NA')
                                color = 3
                        else:
                            #print('scf T2T')
                            #check for gaps
                            if pd.isna(translation_merged.at[num, 'gaps']):
                                continue
                            else:
                                #print('found gaps')
                                color = 2
                    else:
                        #print('ctg T2T')
                        #check for gaps
                        if pd.isna(translation_merged.at[num, 'gaps']):
                            #print('no gaps')
                            color = 1

            #add new information to dictionary
            if datatype != 'hic':
                #hap assocations to sire/dam are backwards - this is how vf set it up
                if 'sire' in translation_merged.at[num, 'index']:
                    plt_dict['Sire'][chr_name] = color
                    tracker = ['sire']
                if 'haplotype2' in translation_merged.at[num, 'index']:
                    plt_dict['Sire'][chr_name] = color
                    tracker = ['sire']
                if 'dam' in translation_merged.at[num, 'index']:
                    plt_dict['Dam'][chr_name] = color
                    tracker = ['dam']
                if 'haplotype1' in translation_merged.at[num, 'index']:
                    plt_dict['Dam'][chr_name] = color
                    tracker = ['dam']
                if 'unassigned' in translation_merged.at[num, 'index']:
                    #check previous row[0] string
                    if 'sire' in tracker:
                        plt_dict['Sire'][chr_name] = color
                        tracker = ['sire']
                    if 'haplotype2' in tracker:
                        plt_dict['Sire'][chr_name] = color
                        tracker = ['sire']
                    if 'dam' in tracker:
                        plt_dict['Dam'][chr_name] = color
                        tracker = ['dam']
                    if 'haplotype1' in tracker:
                        plt_dict['Dam'][chr_name] = color
                        tracker = ['dam']
                    tracker_dict[row[0]] = tracker[0]
            else:
                if 'haplotype1' in translation_merged.at[num, 'index']:
                    plt_dict['Haplotype 1'][chr_name] = color
                    tracker = ['haplotype1']
                if 'haplotype2' in translation_merged.at[num, 'index']:
                    plt_dict['Haplotype 2'][chr_name] = color
                    tracker = ['haplotype2']
                if 'unassigned' in translation_merged.at[num, 'index']:
                    #check previous row[0] string
                    if 'haplotype1' in tracker:
                        plt_dict['Haplotype 1'][chr_name] = color
                        tracker = ['haplotype1']
                    if 'haplotype2' in tracker:
                        plt_dict['Haplotype 2'][chr_name] = color
                        tracker = ['haplotype2']
                    tracker_dict[row[0]] = tracker[0]


    #format file name
    split = verkkoDir.split('/')
    fig_name = split[-1]

    df = pd.DataFrame(plt_dict)
    df = reorder(df, num_chromos)
    df.to_csv('contigPlot_df.tsv', sep='\t')

    if len(df) > num_chromos:
        fig, ax = plt.subplots(figsize=(8, 15))
    else:
        fig, ax = plt.subplots(figsize=(8, 12))
    myColors = ((0.2, 0.7, 0.3, 0.5), (0.3, 0.3, 0.6, 0.6), (0.9, 0.6, 0.5, 0.9))
    cmap = LinearSegmentedColormap.from_list('Custom', myColors, len(myColors))
    ax = sns.heatmap(df, ax=ax, cmap=cmap,
                 linewidths=.5, linecolor='lightgray',
                 cbar_kws={'orientation': 'vertical', 'shrink': 0.5})
    colorbar = ax.collections[0].colorbar
    colorbar.set_ticks([1.35, 2, 2.6])
    colorbar.set_ticklabels(['contig\n(complete T2T w/o gaps)', 'scaffold\n(T2T w/ gaps or tangles)', 'not a scaffold\n(missing one of the telomere)'])
    ax.set_title(fig_name, fontdict={'size': 14})
    ax.set_ylabel('Chromosome')
    ax.set_xlabel('Haplotype')
    ax.set_yticklabels(ax.get_yticklabels(), rotation=0)
    plt.tight_layout()
    plt.savefig(verkkoDir + '/contigPlot.png', bbox_inches='tight')
    plt.close()


    return tracker_dict



def reorder(translation_hap1, translation_hap2, num_chromos):
    """

    Reorder df by chromosome names

    """

    num_list = list(range(1, num_chromos-1))
    num_list = list(map(str, num_list))
    chromo_names = [a + b for a, b in zip(['chr_']*num_chromos, num_list)]
    chromo_names += ['chr_X', 'chr_Y']

    for j,i in enumerate([translation_hap1, translation_hap2]):
        temp_df = pd.DataFrame()
        i.reset_index(inplace=True)
        i.set_index(1, inplace=True)
        index_list = []
        for c in chromo_names:
            for index, row in i.iterrows():
                if index.endswith(c):
                    if index in index_list:
                        continue
                    else:
                        index_list.append(index)
        temp_df = i.loc[index_list].copy()
        temp_df.reset_index(inplace=True)
        temp_df.set_index(0, inplace=True)
        if j == 0:
            translation_hap1 = temp_df
        else:
            translation_hap2 = temp_df


    return translation_hap1, translation_hap2




def merge(translation, ctgs, scfs, telo, gap, scfmap_paths, rDNA):
    """
    
    Merges pandas df translation_hap1 and hap2, assembly.t2t_ctgs, assembly.t2t_scfs, assembly.telomere.bed, assembly.scfmap and assembly.paths
    Output: translation_merged3
    
    """
     
    def format(translation_merged, telo, gap):
        """
        
        Concatenates telomere and gap dictionaries to translation_merged2
        Output: translation_merged2
 
        """
        
        #Iterate telomeres and count
        telo_list = telo.index.tolist()
        telo_dict = {}
        for i in telo_list:
            if i in telo_dict.keys():
                telo_dict[i] += 1
            else:
                telo_dict[i] = 1
        
        #Create telomere dict and concatenate to translation_merged df
        telo_df = pd.DataFrame.from_dict(telo_dict, orient='index', columns=['telomeres'])
        translation_merged2 = pd.concat([translation_merged, telo_df], axis=1)

        #Iterate gaps and count
        gaps_list = gap.index.tolist()
        gaps_dict = {}
        for i in gaps_list:
            if i in gaps_dict.keys():
                gaps_dict[i] += 1
            else:
                gaps_dict[i] = 1

        #Create gap dict and concatenate to translation_merged df
        gaps_df = pd.DataFrame.from_dict(gaps_dict, orient='index', columns=['gaps'])
        translation_merged2 = pd.concat([translation_merged2, gaps_df], axis=1)

    
        return translation_merged2

    
    subset_list = []
    #check if number of T2T ctgs equals 0
    if len(ctgs.index) == 0:
        if len(scfs.index) == 0:
            #print('no ctgs or scfs files')
            translation_merged = translation
            translation_merged2 = format(translation_merged, telo, gap)
        else:
            #print('only scfs file')
            scfs = scfs.set_index(0)
            scfs['scfs'] = 1
            translation_merged = pd.concat([translation, scfs], axis=1)
            translation_merged2 = format(translation_merged, telo, gap)
            subset_list.append('scfs')
    else:
        ctgs = ctgs.set_index(0)
        ctgs['ctgs'] = 1
        if len(scfs.index) == 0:
            #print('only ctgs file')
            translation_merged = pd.concat([translation, ctgs], axis=1)
            translation_merged2 = format(translation_merged, telo, gap)
            subset_list.append('ctgs')
        else:
            #print('both ctgs and scfs files')
            scfs = scfs.set_index(0)
            scfs['scfs'] = 1
            translation_merged = pd.concat([translation, ctgs, scfs], axis=1)
            translation_merged2 = format(translation_merged, telo, gap)
            subset_list.append('scfs')
            subset_list.append('ctgs')

    
    #add to list of columns to check for NaN
    subset_list.append('telomeres')
    subset_list.append('gaps')

    #grab index as list
    translation_index = translation_merged2.index.to_list()

    #concatenate with scfmap_paths
    #includes all scfmap_paths
    translation_merged3 = translation_merged2.join(scfmap_paths, how='outer')
    translation_merged3.rename(columns={1: 'chr', 2: 'length', 3: 'ref length'}, inplace=True) 

    #include rDNA information
    #rename rDNA columns to match translation_merged3
    rDNA.drop([2, 3], axis=1, inplace=True)
    rDNA.rename(columns={1: 'length', 4: 'ref length'}, inplace=True)
    rDNA['chr'] = 'rDNA'
    translation_merged3.update(rDNA)

    #grab rDNA associated utigs
    filtered_translation_rDNA = translation_merged3.loc[translation_merged3['chr'] == 'rDNA']
    rDNA_utigs = filtered_translation_rDNA['path'].to_list()
    rDNA_utigs_cleaned = [u[:-1] for u in rDNA_utigs]
    if len(rDNA_utigs_cleaned) > 1:
        rDNA_string = ",".join(rDNA_utigs_cleaned)
    elif len(rDNA_utigs_cleaned) == 0:
        rDNA_string = []
    else:
        #only one utig listed
        rDNA_string = rDNA_utigs_cleaned[0]

    #includes scfmap_paths associated with ctg, scf, gap or telomere
    translation_merged4 = translation_merged2.join(scfmap_paths)
    translation_merged4.rename(columns={1: 'chr', 2: 'length', 3: 'ref length'}, inplace=True)

    #drop all rows with no data other than path name
    translation_merged_wo_na = translation_merged4.dropna(subset=subset_list, how='all')
    translation_merged_wo_na = translation_merged_wo_na.filter(items=translation_index, axis=0)


    #grab rows that were removed and print any that are related to a chromosome
    only_na = translation_merged3[~translation_merged3.index.isin(translation_merged_wo_na.index)]
    only_na.replace(to_replace='rDNA', value=' ')
    only_na_w_chr = only_na[only_na['chr'].str.contains('chr', case=False, na=False)]
    only_na_w_chr_cleaned = only_na_w_chr.dropna(axis=1, how='all')
    if only_na_w_chr_cleaned.empty:
        print('contigs assigned to chr are complete')
    else:
        print('contigs assigned to chr but no scfs, ctgs, gaps, or telomeres')
        print(only_na_w_chr_cleaned)


    #reset index
    translation_merged_wo_na.reset_index(inplace=True)
    translation_merged3.reset_index(inplace=True)


    return translation_merged_wo_na, translation_merged3, rDNA_string

 


def duplicate_chr_check(translation_hap1, translation_hap2):
    """

    Checks chromosomes associated with multiple contigs
    Creates a warning to check translation files

    """

   #check chromosomes with multiple contigs
    for i,j in enumerate([translation_hap1, translation_hap2]):
        chr_list = j[1].tolist()
        for c in chr_list:
            count = chr_list.count(c)
            if count > 1:
                #filter by chr
                chr_df = j[j[1] == c]
                #check seq length against reference length
                seq_len = chr_df[2].sum()
                ref_len = chr_df.iloc[0,3]
                #is the seq_len greater than the reference length plus half
                if seq_len > (ref_len + ref_len/2):
                    print('WARNING: ' + c + ' may have contig issues')
                    print('check verkko-fillet/chromosome_assignment/translation files for duplicates')
                    print('remove unnecessary rows and rerun verkko-fillet after chrAssign')

                #remove all instances from list
                chr_list = [item for item in chr_list if item != c]

        if i == 0:
           translation_hap1 = translation_hap1.set_index(0)
        else:
           translation_hap2 = translation_hap2.set_index(0)
    

    return translation_hap1, translation_hap2




def duplicate_contig_check(translation_hap1, translation_hap2, scfs, ctgs, telo, gap, scfmap_paths):
    """

    Check translation files for duplicate haplotype names. 
    If a duplicate is found, an error will be flagged.
    Output: translation_hap1, translation_hap2, and contig_error

    """
    
    def update_dups(dups, translation, scfs, ctgs, telo, gap, scfmap_paths):
        """

        Adds '_d' to duplicate contig name
        Adds corresponding contig to related files

        """

        def add_dup_df(df, dup):
            """

            Concatenates duplcate df to original df

            """

            dup_count = df.index.value_counts().get(dup[:-2], 0)

            if dup_count > 1:
                #print('more than one duplicate row')
                duplicate = df.loc[dup[:-2]].reset_index()
            else:
                duplicate = df.loc[dup[:-2]].reset_index().T
                duplicate = duplicate.reset_index()
                duplicate.columns = duplicate.iloc[0]
                duplicate = duplicate[1:].reset_index(drop=True)
                duplicate = duplicate.reset_index(drop=True)                    #reset index numbering

                if len(df.columns) > 3:
                    duplicate = duplicate.rename(columns={'index': 0})
                else:
                    duplicate = duplicate.rename(columns={0: 1 , 'index': 0})

            for i in range(0,len(duplicate)):
                duplicate.loc[i,0] = dup
            duplicate = duplicate.set_index(0)

            df_temp = pd.concat([df, duplicate], axis=0)

            return df_temp  
    

        #identify duplicate and append '_d' to the end
        dups = dups.reset_index()
        if dups.shape[0] == 1:
            #print('one duplicate')
            dup = dups.iloc[0,1] + '_d'
            translation.loc[dups.iloc[0,0], 0] = dup

            #add scf, ctg, telo, gap and scfmap_paths info
            if scfs.shape[0] != 0:
                dup_check = (scfs[0].eq(dup[:-2])).any()
                if dup_check:
                    scfs.loc[len(scfs)] = dup
            if ctgs.shape[0] != 0:
                dup_check = (ctgs[0].eq(dup[:-2])).any()
                if dup_check:
                    ctgs.loc[len(ctgs)] = dup

            for index,d in enumerate([telo, gap, scfmap_paths]):
                if dup[:-2] in d.index:
                    df_temp = add_dup_df(d, dup)
                    if index == 0:
                        telo = df_temp
                    if index == 1:
                        gap = df_temp
                    if index == 2:
                        scfmap_paths = df_temp

        else:
            #print('multiple duplicates')
            dup = dups[0] + '_d'

            #check for duplicates within the dup list
            unique_dup_count = dup.duplicated().sum()
            if unique_dup_count > 0:
                print('ERROR: more than 2 contigs share same name')
                print('check verkko-fillet/chromosome_assignment/translation files for duplicates')
                print('remove unnecessary rows and rerun verkko-fillet after chrAssign')
                sys.exit()

            for index, row in dups.iterrows():
                translation.loc[dups.iloc[index,0],0] = dup[index]
                if scfs.shape[0] != 0:
                    dup_check = (scfs[0].eq(row[0])).any()
                    if dup_check:
                        scfs.loc[len(scfs)+index+2] = dup[index]
                if ctgs.shape[0] != 0:
                    dup_check = (ctgs[0].eq(row[0])).any()
                    if dup_check:
                        ctgs.loc[len(ctgs)+index+2] = dup[index]

            for index,d in enumerate([telo, gap, scfmap_paths]):
                for index1, row in dups.iterrows():
                    if row[0] in d.index:
                        df_temp = add_dup_df(d, dup[index1])
                        if index == 0:
                            telo = df_temp
                        if index == 1:
                            gap = df_temp
                        if index == 2:
                            scfmap_paths = df_temp


        return translation, scfs, ctgs, telo, gap, scfmap_paths

   
    #check for duplications in each translation file
    hap1_duplicate = translation_hap1[translation_hap1.duplicated([0])]
    hap2_duplicate = translation_hap2[translation_hap2.duplicated([0])]
    
    for j, i in enumerate([hap1_duplicate, hap2_duplicate]):
        #print('haplotype ' + str(j+1))
        if len(i) > 0:
            #print('duplicate contigs exist')
            #print(i)
            if j == 0:
                translation_hap1, scfs, ctgs, telo, gap, scfmap_paths = update_dups(i, translation_hap1, scfs, ctgs, telo, gap, scfmap_paths)               
            else:
                translation_hap2, scfs, ctgs, telo, gap, scfmap_paths = update_dups(i, translation_hap2, scfs, ctgs, telo, gap, scfmap_paths) 
        else:
            print('no duplicate contigs')

    return translation_hap1, translation_hap2, scfs, ctgs, telo, gap, scfmap_paths




def summary_table(df, phase_type, tracker_dict):
    """

    Sums ctgs, scfs, gaps, and telomeres for each haplotype
    Output: csv

    """

    def sum_columns(i, sum_dict, df, tracker_dict):
        
        #grab column names
        cols = df.columns.tolist()
        #remove chr and lengths from list
        cols = cols[3:-2]
        #filter
        temp_df = df.filter(like=i, axis=0)
        
        #check for unassigned rows that need to be added
        if len(tracker_dict) > 0:
            for key, value in tracker_dict.items():
                if value == i:
                    #add df row to temp_df
                    temp_df = pd.concat([temp_df, df.loc[[key]]], axis=0)

        #remove rows with all NAN
        temp_df = temp_df[temp_df['chr'].notna()]
        #sum columns and add to dictionary
        temp_dict = temp_df[cols].sum().astype(int).to_dict()
        #add to dict
        sum_dict[i] = temp_dict

        return sum_dict


    df = df.set_index('index')
    sum_dict = {}
    if phase_type == 'hic':
        print('summing for hap1/hap2')
        for i in ['haplotype1', 'haplotype2']:
            sum_dict = sum_columns(i, sum_dict, df, tracker_dict)
    if phase_type == 'trio':
        print('summing for dam/sire')
        #for i in ['dam', 'sire']:
        for i in ['sire', 'dam']:
            sum_dict = sum_columns(i, sum_dict, df, tracker_dict)
    if phase_type == 'trio_hic':
        print('summing for hap1/hap2 and dam/sire')
        for i in ['haplotype1', 'haplotype2']:
            sum_dict = sum_columns(i, sum_dict, df, tracker_dict)
        #for i in ['dam', 'sire']:
        for i in ['sire', 'dam']:
            sum_dict = sum_columns(i, sum_dict, df, tracker_dict)

    df_summary = pd.DataFrame.from_dict(sum_dict, orient='index')


    return df_summary




def upload_files(verkkoDir, rDNA_fasta, new_row):
    """
    
    Open all files needed. Check if ctgs and/or scfs tables are empty.

    """


    def filter_concat_addrow(new_row_df, translation, new_row, sex_type, hap_type):
        """

        Function will filter for sex type, haplotype and then add new row of data

        """


        def add_new_row(translation, new_row):
            """

            Use this function when a contig shows to be T2T but is not associated with a chromosome.

            A message similar to this will print on the .std outfile:

            check T2T ctgs and scfs
            WARNING: not all T2T ctgs/scfs are associated with a chromosome
            Update translation files, then remerge
            index  chr  length  ref length  ctgs  scfs  telomeres  gaps  path name
            83  haplotype2-0000071  NaN     NaN     NaN   1.0   1.0 2.0   NaN utig4-2978

            This function will add the unassociated contig, chr name, seq start, and ref start to translation file

            """
            
            print(new_row)
            extended_translation = pd.concat([translation, new_row], axis=0)
            print(extended_translation)

            return extended_translation



        def process_unassigned(translation, filtered_new_row, chromo, row_index, df_list, sex_type):
            """

            Identify correct haplotype to assign unassigned hapmer.
            Checks translation file for chromosome, if not found - added to df_list for concatenation

            """

            def sex_chromo_check(translation, sex_type, alt_sex_type, chromo, row_index, df_list, filtered_new_row):
                """

                This function checks for sire/dam and expected associated sex chromosome in translation file

                """

                if translation[0].str.contains(sex_type).any():
                    df_list.append(filtered_new_row.iloc[[row_index]])
                else:
                    if translation[1].str.contains(alt_sex_type).any():
                        print('sex chromosome X already exists')
                    else:
                        df_list.append(filtered_new_row.iloc[[row_index]])

                return df_list


            #check translation for chromosome to be updated
            if translation[1].str.contains(chromo).any():
                print('unassigned chromosome already exists ' + str(chromo))
            else:
                #check if unassigned is a sex chromosome
                if 'chr_Y' in chromo:
                    print('unassigned chromosome is Y')
                    #check for sire
                    df_list = sex_chromo_check(translation, sex_type, 'chr_X', chromo, row_index, df_list, filtered_new_row)

                if 'chr_X' in chromo:
                    print('unassigned chromosome is X')
                    #check for dam
                    df_list = sex_chromo_check(translation, sex_type, 'chr_Y', chromo, row_index, df_list, filtered_new_row)

                #unassigned is an autosome
                if 'chr_Y' not in chromo and 'chr_X' not in chromo:
                    print('unassigned chromosome is an autosome')
                    df_list.append(filtered_new_row.iloc[[row_index]])

            return df_list


        df_list = []
        #filter for sex_type or hap_type or create an empty df
        if new_row_df[0].str.contains(sex_type).any():
            print('filtered for ' + sex_type)
            filtered_new_row = new_row_df[new_row_df[0].str.contains(sex_type)]
            df_list.append(filtered_new_row)

        elif new_row_df[0].str.contains(hap_type).any():
            print('filtered for ' + hap_type)
            filtered_new_row = new_row_df[new_row_df[0].str.contains(hap_type)]
            df_list.append(filtered_new_row)
        
        #check for unassigned
        elif new_row_df[0].str.contains('unassigned').any():
            filtered_new_row = new_row_df[new_row_df[0].str.contains('unassigned')]
            print('filtered for unassigned')
            for index,row in filtered_new_row.iterrows():
                df_list = process_unassigned(translation, filtered_new_row, row[1], index, df_list, sex_type)
        else:
            print('New row was NOT found')
            filtered_new_row = pd.DataFrame()

        #when more than one df created, concatenate
        if len(df_list) > 1:
            filtered_new_row = pd.concat(df_list, axis=0)

        #add new data if exists
        if filtered_new_row.empty:
            print('no new rows need to be appended')
        else:
            print('filtered_new_row=',filtered_new_row)
            translation = add_new_row(translation, filtered_new_row)
        
        return translation


    def format_dict_to_df(new_row):
        """

        Convert index and column 2 and 3 values to integers
        Convert dict to pandas df

        """

        new_row1 = {}
        for k, v in new_row.items():
            if k == '0' or k == '1':
                #convert index to integers
                new_row1[int(k)] = v
            else:
                #convert index to integers and column 2 and 3 values
                new_row1[int(k)] = [int(item) for item in v]

        #convert dict to df
        new_row_df = pd.DataFrame(new_row1)

        return new_row_df




    print('finding files')
    #ctgs
    if os.path.isfile(verkkoDir + "/assembly.t2t_ctgs"):
        if os.path.getsize(verkkoDir + "/assembly.t2t_ctgs") != 0:
            ctgs = pd.read_csv(verkkoDir + "/assembly.t2t_ctgs", sep='\t', header=None)
        else:
            #print('ctgs file is empty')
            ctgs  = pd.DataFrame()
    else:
        print('ctgs file not found')

    #scfs
    if os.path.isfile(verkkoDir + "/assembly.t2t_scfs"):
        if os.path.getsize(verkkoDir + "/assembly.t2t_scfs") != 0:
            scfs = pd.read_csv(verkkoDir + "/assembly.t2t_scfs", sep='\t', header=None)
        else:
            #print('scfs file is empty')
            scfs  = pd.DataFrame()
    else:
        print('scfs file not found')
    
    #translation_hap1
    if os.path.isfile(verkkoDir + "/translation_hap1"):
        translation_hap1 = pd.read_csv(verkkoDir + "/translation_hap1", sep='\t', header=None)
        
        #check if new rows need to be added to translation file
        if len(new_row) > 0:
            #convert new data from dict to df
            new_row_df = format_dict_to_df(new_row)
            #add new data to translation file
            print('translation1')
            #translation_hap1 = filter_concat_addrow(new_row_df, translation_hap1, new_row, 'dam', 'haplotype1')
            translation_hap1 = filter_concat_addrow(new_row_df, translation_hap1, new_row, 'sire', 'haplotype1')        
    else:
        print('translation_hap1 file not found')

    #translation_hap2
    if os.path.isfile(verkkoDir + "/translation_hap2"):
        translation_hap2 = pd.read_csv(verkkoDir + "/translation_hap2", sep='\t', header=None)

        #check if new rows need to be added to translation file
        if len(new_row) > 0:
            #convert new data from dict to df
            new_row_df = format_dict_to_df(new_row)
            #add new data to translation file
            print('translation2')
            #translation_hap2 = filter_concat_addrow(new_row_df, translation_hap2, new_row, 'sire', 'haplotype2')
            translation_hap2 = filter_concat_addrow(new_row_df, translation_hap2, new_row, 'dam', 'haplotype2') 
    else:
        print('translation_hap2 file not found')

    #telomeres
    if os.path.isfile(verkkoDir + "/assembly.telomere.bed"):
        telo = pd.read_csv(verkkoDir + "/assembly.telomere.bed", sep='\t', header=None, index_col=0)
    else:
        print('telomere file not found')

    #gaps
    if os.path.isfile(verkkoDir + "/assembly.gaps.bed"):
        gap = pd.read_csv(verkkoDir + "/assembly.gaps.bed", sep='\t', header=None, index_col=0)
    else:
        print('gaps file not found')

    #scfmap
    if os.path.isfile(verkkoDir + "/assembly.scfmap"):
        #open and collect utig names from scfmap
        names = {}
        with open(verkkoDir + "/assembly.scfmap", "r") as file:
            for f in file:
                if f.startswith('path'):
                    #split line and grab utig name
                    line_split = f.split(' ')  
                    path_name = line_split[2]
                    names[line_split[1]] = path_name.strip()

        #create df from scfs dict
        scfmap = pd.DataFrame.from_dict(names, orient='index')
        scfmap = scfmap.reset_index().set_index(0)
    else: 
        print('scfmap file not found')

    #paths
    if os.path.isfile(verkkoDir + "/assembly.paths.tsv"):
        paths = pd.read_csv(verkkoDir + "/assembly.paths.tsv", sep='\t', index_col='name')
        paths = paths.drop('assignment', axis=1)
    else:
        print('paths file not found')


    #rDNA
    rDNA_file = os.path.basename(rDNA_fasta)
    if os.path.isfile(verkkoDir + '/' + rDNA_file):
        print(verkkoDir + '/' + rDNA_file + ' exists')
        assembly_rDNA = pd.read_csv(verkkoDir + '/' + rDNA_file, sep='\t', index_col=0, header=None)
    else:
        print(verkkoDir + '/' + rDNA_file + ' not found')


    return ctgs, scfs, translation_hap1, translation_hap2, telo, gap, scfmap, paths, assembly_rDNA



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

ctgs, scfs, translation_hap1, translation_hap2, telo, gap, scfmap, paths, rDNA = upload_files(args.verkkoDir, args.rDNA_fasta_fai, new_row)

print('combine scfmap and paths')
scfmap_paths = pd.concat([scfmap, paths], axis=1).reset_index()
scfmap_paths = scfmap_paths.rename(columns={'level_0': 'path name'}).set_index('index')

print('looking for contig duplicates')
translation_hap1, translation_hap2, scfs, ctgs, telo, gap, scfmap_paths = duplicate_contig_check(translation_hap1, translation_hap2, scfs, ctgs, telo, gap, scfmap_paths)

print('looking for chr duplicates')
translation_hap1, translation_hap2 = duplicate_chr_check(translation_hap1, translation_hap2)

print('reorder chromosomes')
translation_hap1, translation_hap2 = reorder(translation_hap1, translation_hap2, args.num_chromosomes)

print('merging all files')
translation = pd.concat([translation_hap1, translation_hap2], axis=0)
translation_merged, translation_merged_all, rDNA_string = merge(translation, ctgs, scfs, telo, gap, scfmap_paths, rDNA)

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
translation_merged.to_csv(args.verkkoDir + '/translation_merged.tsv', sep="\t", index=False)
translation_merged_all.to_csv(args.verkkoDir + '/utig_contig_chr_path_translation.tsv', sep="\t", index=False)

print('save rDNA')
#remove path if exists
if os.path.exists("rDNA_utigs_ids_Bandage.txt"):
    os.remove("rDNA_utigs_ids_Bandage.txt")
if len(rDNA_string) > 0:
    with open("rDNA_utigs_ids_Bandage.txt", "a") as f:
        f.write(rDNA_string)
    f.close()

print('creating heatmap')
tracker_dict = contigPlot(translation_merged, args.phase_datatype, ctgs, scfs, args.verkkoDir, args.num_chromosomes)

print('sum columns in merged file')
df_summary = summary_table(translation_merged, args.phase_datatype, tracker_dict)
df_summary.to_csv(args.verkkoDir + '/translation_merged_summary.tsv', sep='\t')
   
