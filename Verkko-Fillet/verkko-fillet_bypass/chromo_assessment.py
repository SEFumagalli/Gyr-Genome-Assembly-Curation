#created by Sarah E. Fumagalli


import pandas as pd
import argparse 
import os
import numpy as np
from pandas.errors import EmptyDataError
from collections import OrderedDict

pd.set_option('display.max_columns', None)  # or 1000
pd.set_option('display.max_rows', None)  # or 1000

parser=argparse.ArgumentParser()

parser.add_argument("--mashmap", nargs="*", default=[])
parser.add_argument("--translation", nargs="*", default=[])
parser.add_argument("--num_chromosomes", help='number of chromosomes input')


args = parser.parse_args()


#Input mashmap and translation file
trans_files = args.translation
num_chromos = int(args.num_chromosomes) #excluding sex chromosomes
mashmap_files = args.mashmap

#If using trio data with overlay Hi-C, split mashmap_files into dam/sire and hap1/hap2
if len(mashmap_files) > 2:
    print('split mashmap file list for trio/hi-c data')
    trio_hic = True
    split_point = len(mashmap_files) // 2
    mashmap_files1 = mashmap_files[:split_point]
    mashmap_files2 = mashmap_files[split_point:]
else:
    print('no trio/hi-c data')
    trio_hic = False



def missing_chromos(translation, num_chromos):
    """
    
    Finding missing from expected chromosomes.
    Returns list of missing chromosomes.
    
    """
    
    #set current chromosomes to list
    if translation.empty:
        #print('Translation df is empty')
        current_chromos = []
    else:
        current_chromos_temp = translation.iloc[:,1].tolist()
        
        #reformat
        current_chromos = []
        for j in current_chromos_temp:
            spliter = j.split('_')
            if len(spliter) > 3:
                c = "_".join([spliter[2], spliter[3]])
                current_chromos.append(c)
            if len(spliter) == 3:
                c = "_".join([spliter[1], spliter[2]])
                current_chromos.append(c)
            if len(spliter) == 2:
                current_chromos.append(j)
                break

    #Iterate through the expected chromosomes and compare to translation file
    needed_chromos = []
    for j in range(1,num_chromos+1):
        if j < num_chromos-1:
            name = 'chr_' + str(j)
        elif j == num_chromos-1:
            name = 'chr_X'
        elif j == num_chromos:
            name = 'chr_Y'

        if any(filter(lambda x: name in x, current_chromos)):
            continue
        else: 
            if j < num_chromos-1:
                print('chromosome needed:=', j)
                needed_chromos.append(j)
            elif j == num_chromos-1:
                print('chromosome needed:=', 'X')
                needed_chromos.append('X')
            elif j == num_chromos:
                print('chromosome needed:=', 'Y')
                needed_chromos.append('Y')
        
    #check numbers 
    count = len(needed_chromos) + len(current_chromos)
    if count == num_chromos:
        print('chromosome numbers equal to expectation')
        print('number of needed chromosomes:=', len(needed_chromos))
        print('number of current chromosomes:=', len(current_chromos))
    else:
        print('chromosome numbers not adding up to expectation')
        print('count of needed and current=', count)
        print('number of needed chromosomes:=', len(needed_chromos))
        print('number of current chromosomes:=', len(current_chromos))


    return needed_chromos


        
def add_chromos(mashmap_sub, num_chromos, translation):
    '''
    
    Finds missing chromosomes in mashmap and adds to translation file.
    Returns translation file.

    '''
    def chromo_to_translation(df, translation):
        '''

        Appends necessary information from mashmap to translation file.
        Output: translation

        '''

        print('adding contig to translation')
        addition = df.values.tolist()[0]

        if translation.empty:
            #print('Filling empty translation df')
            translation = pd.DataFrame([[addition[0], addition[5], addition[1], addition[6]]])
        else:
            translation.loc[len(translation)] = [addition[0], addition[5], addition[1], addition[6]]

        return translation

     
    def sex_chr_check(j, i, unique_contigs, mashmap_sub, translation, current_haps, contig_exists):
        """
        
        Check sex chromosome for length and PAR

        """
        #print('unique_contigs=',unique_contigs) 
        #if more than one contig, check lengths and for PAR
        if len(unique_contigs) > 1:
            #print('more than one contig')
            temp_df = mashmap_sub.copy()
            temp_df = temp_df[temp_df.iloc[:,0].apply(lambda x:i in x)]

            if 'X' in j:
                #check if any contigs are longer than 1000000 and start before 6000000 (PAR)
                if (temp_df[10] >= 1000000).any() and (temp_df[1] - temp_df[3] > 6000000).any():
                    #print('X contig greater than 1mb and not PAR')
                    if contig_exists:
                        print('contig exists')
                    else:
                        translation = chromo_to_translation(temp_df, translation)
                        print('adding contig ' + i)
                        current_haps.append(i)
                    reorder_df = False
                else:
                    #print('X contig less than 1mb - ignoring or PAR')
                    #if contig_exists:
                        #print('dropping PAR related chromosome')
                    #    translation.drop(translation[translation[1].str.contains(j)].index, inplace=True)
                    reorder_df = False

            if 'Y' in j:
                #check if any contigs are longer than 1000000 and start after 7000000 (PAR)
                if (temp_df[10] >= 1000000).any() and (temp_df[7] > 7000000).any():
                        #print('Y contig greater than 1mb and not PAR')
                        if contig_exists:
                            print('contig exists')
                        else:
                            translation = chromo_to_translation(temp_df, translation)
                            print('adding contig ' + i)
                            current_haps.append(i)
                        reorder_df = True
                else:
                    #print('Y contig less than 1mb - ignoring or PAR')
                    #if contig_exists:
                        #print('dropping PAR related chromosome')
                        #translation.drop(translation[translation[1].str.contains(j)].index, inplace=True)
                    reorder_df = True
        else:
            #print('only one contig')    
            if (mashmap_sub[10] >= 1000000).any():
                #print('contig greater than 1mb')
                if contig_exists:
                    #print('contig exists')
                    #check to see if chromosome exists
                    if translation[1].str.contains(j).any():
                        print('contig really does exist')
                    else:
                        #add chromosome
                        translation = chromo_to_translation(mashmap_sub, translation)
                        print('adding contig ' + i)
                        current_haps.append(i)
                else:
                    #print('add contig')
                    translation = chromo_to_translation(mashmap_sub, translation)
                    print('adding contig ' + i)
                    current_haps.append(i)
                if 'Y' in j:
                    reorder_df = True
                else:
                    reorder_df = False
            else:
                #print('contig less than 1mb - ignoring')
                #if contig_exists:
                    #print('dropping PAR related contig')
                    #translation.drop(translation[translation[1].str.contains(j)].index, inplace=True)
                if 'Y' in j:
                    reorder_df = True
                else:
                    reorder_df = False


        return translation, reorder_df


       
    chromo_list = list(range(1,num_chromos-1)) + ['X', 'Y']
    chromo_list = ['chr_' + str(s) for s in chromo_list]
    
    if translation.empty:
        current_haps = []
    else:
        current_haps = translation.iloc[:,0].tolist()

    for index, j in enumerate(chromo_list):
        #print('chromo=',j)
        #filter for chromosome
        mashmap_temp = mashmap_sub[mashmap_sub.iloc[:,5].apply(lambda x:j in x)] 
        if mashmap_temp.empty:
            #print('chromosome not found in mashmap')
            if j == 'chr_Y':
                reorder_df = True
            continue

        #sort by alignment length
        mashmap_temp = mashmap_temp.sort_values(by=[10], ascending=False)

        #identify unique contigs listed in mashimap_sub
        unique_contigs = mashmap_temp[0].unique() 

        #for each contig, filter df and check alignment length. if > 1mb contig gets added to translation df
        for i in unique_contigs:
            if i in current_haps:
                #print('contig already exists in translation file')
                #this may be incorrect if there is a duplicate contig name (happens more often for sex chromosomes)
                contig_exists = True
                #double check verkko-fillet's decision 
                if j == 'chr_X' or j == 'chr_Y':
                    #print('double checking sex chromosomes')
                    translation, reorder_df = sex_chr_check(j, i, unique_contigs, mashmap_temp, translation, current_haps, contig_exists)
                if j == 'chr_Y':
                    #marked as need for reformatting
                    reorder_df = True
                    break
            else:
                #check sex chromosomes 
                contig_exists = False
                if 'X' in j or 'Y' in j:
                    #print('X or Y contig')
                    translation, reorder_df = sex_chr_check(j, i, unique_contigs, mashmap_temp, translation, current_haps, contig_exists)             
                else:
                    #check non-sex chromosomes
                    if len(unique_contigs) > 1:
                        #print('more than one contig')
                        temp_df = mashmap_temp.copy()
                        temp_df = mashmap_temp[mashmap_temp.iloc[:,0].apply(lambda x:i in x)]
                        #check if any contigs are longer than 1000000
                        if (temp_df[10] >= 1000000).any():
                            #print('contig greater than 1mb')
                            translation = chromo_to_translation(temp_df, translation)
                            print('adding contig ' + i)
                            current_haps.append(i)
                        #else:
                            #print('contig less than 1mb - ignoring')
                    else:
                        #print('only one contig')
                        translation = chromo_to_translation(mashmap_temp, translation)
                        print('adding contig ' + i)
                        current_haps.append(i)

           
    return translation, reorder_df



def reorder(translation, num_chromos):
    """

    Reorder translation file by contig names
    
    """
    #reindex using chromo_names
    num_list = list(range(1, num_chromos-1))
    num_list = list(map(str, num_list))
    chromo_names = [a + b for a, b in zip(['chr_']*num_chromos, num_list)]
    chromo_names += ['chr_X', 'chr_Y']
    
    ordered_dict = OrderedDict()
    counter = 0
    for i in chromo_names:
        if i.endswith('X') or i.endswith('Y'):
            for index, row in translation.iterrows():
                split1 = row[1].split('_')
                if i.endswith(split1[len(split1)-1]):
                    ordered_dict[counter] = row.to_dict()
                    counter += 1
        else:
            split1 = i.split('_')
            for index, row in translation.iterrows():
                split2 = row[1].split('_')
                if split1[1] == split2[len(split2)-1]:
                    ordered_dict[counter] = row.to_dict()
                    counter += 1
    
    ordered_df = pd.DataFrame.from_dict(ordered_dict, orient='index')
    ordered_df = ordered_df.reset_index(drop=True)
    if 'index' in ordered_df.columns:
        ordered_df = ordered_df.rename(columns={'index': 1})
    ordered_df = ordered_df.reindex(columns=[0,1,2,3])
    print('ordered_df=',ordered_df)
    
    return ordered_df



def find_sex_chromos(mashmap, translation_hap1, translation_hap2):
    """
    
    if using sire/dam, look at haplotype contigs for sex chromosomes

    """
    print('looking for sex chromosomes')
    chr_X = mashmap[mashmap[5].str.contains('chr_X')].sort_values(by=10, ascending=False)
    chr_Y = mashmap[mashmap[5].str.contains('chr_Y')].sort_values(by=10, ascending=False)

    if len(translation_hap1[translation_hap1[1].str.contains('chr_X')]) > 0 or len(translation_hap2[translation_hap2[1].str.contains('chr_X')]) > 0:
        print('chromosome X already exists in translation files')
    else:
        if (chr_X[10] >= 1000000).any() and (chr_X[1] - chr_X[3] > 6000000).any():
            #print('X contig greater than 1mb and not PAR')
            addition = chr_X.values.tolist()[0]
            if 'haplotype1' in addition[0]:
                print('chr_X added to dam')
                #translation_hap1.loc[len(translation_hap1)] = [addition[0], addition[5], addition[1], addition[6]]
                translation_hap2.loc[len(translation_hap2)] = [addition[0], addition[5], addition[1], addition[6]]
            else:
                print('chr_X added to sire')
                #translation_hap2.loc[len(translation_hap2)] = [addition[0], addition[5], addition[1], addition[6]]
                translation_hap1.loc[len(translation_hap1)] = [addition[0], addition[5], addition[1], addition[6]]
        #else:
            #print('X contig less than 1mb - ignoring or PAR')

    if len(translation_hap1[translation_hap1[1].str.contains('chr_Y')]) > 0 or len(translation_hap2[translation_hap2[1].str.contains('chr_Y')]) > 0:
        print('chromosome Y already exists in translation files')
    else:
        if (chr_Y[10] >= 1000000).any() and (chr_Y[7] > 7000000).any():
            #print('Y contig greater than 1mb and not PAR')
            addition = chr_Y.values.tolist()[0]
            print('added chr_Y to sire')
            #translation_hap2.loc[len(translation_hap2)] = [addition[0], addition[5], addition[1], addition[6]]
            translation_hap1.loc[len(translation_hap1)] = [addition[0], addition[5], addition[1], addition[6]]
        #else:
            #print('Y contig less than 1mb - ignoring or PAR')


    return translation_hap1, translation_hap2




def remove_sex_duplicates(df1, df2):
    """

    Removes X for sire and Y for dam

    """

    #drop chr Y from df1
    print('dropping chr Y from dam')
    #df1.drop(df1[df1[1].str.contains('_chr_Y')].index, inplace=True)
    df2.drop(df2[df2[1].str.contains('_chr_Y')].index, inplace=True)

    #drop chr X from df2
    print('dropping chr X from sire')
    #df2.drop(df2[df2[1].str.contains('_chr_X')].index, inplace=True)
    df1.drop(df1[df1[1].str.contains('_chr_X')].index, inplace=True)


    return df1, df2




def fix_sex_chromosomes(df1, df2):
    """

    Check dfs X and Y chromosome. Make sure they are not on the same haplotype.

    """

    if df1[1].str.contains('_chr_Y').any() and df1[1].str.contains('_chr_X').any():
        #both dfs have X and Y
        print('df1 has X and Y')
        if df2[1].str.contains('_chr_Y').any() and df2[1].str.contains('_chr_X').any():
            print('both translation files have chr X and Y')
            df1_chrY = df1[df1[1].str.contains('_chr_Y')]
            df2_chrY = df2[df2[1].str.contains('_chr_Y')]

            #df1 > df2
            if int(df1_chrY.iloc[2]) > int(df2_chrY.iloc[2]):
                #drop chr Y from df2
                print('dropped chr Y from df2')
                df2.drop(df2[df2[1].str.contains('_chr_Y')].index, inplace=True)
                #check df1 has chr X
                if df1[1].str.contains('_chr_X').any():
                    print('df1 has chr X')
            else:
                #df1 < df2
                #drop chr Y from df1
                print('dropped chr Y from df1')
                df1.drop(df1[df1[1].str.contains('_chr_Y')].index, inplace=True)
                #check df2 has chr X
                if df2[1].str.contains('_chr_X').any():
                    print('df2 has chr X')

        #df1 has X and Y but df2 has Y
        elif df2[1].str.contains('_chr_Y').any():
            print('df1 has X and Y but df2 has Y')
            df1.drop(df1[df1[1].str.contains('_chr_Y')].index, inplace=True)

        #df1 has X and Y but df2 has X
        elif df2[1].str.contains('_chr_X').any():
            print('df1 has X and Y but df2 has X')
            df1.drop(df1[df1[1].str.contains('_chr_X')].index, inplace=True)

    #df1 has Y
    elif df1[1].str.contains('_chr_Y').any():
        print('df1 has Y')
        #df2 has Y
        if df2[1].str.contains('_chr_Y').any():
            print('df2 has Y')
            df1_chrY = df1[df1[1].str.contains('_chr_Y')]
            df2_chrY = df2[df2[1].str.contains('_chr_Y')]

            #df1 > df2
            if int(df1_chrY.iloc[2]) > int(df2_chrY.iloc[2]):
                #drop chr Y from df2
                print('dropped chr Y from df2')
                df2.drop(df2[df2[1].str.contains('_chr_Y')].index, inplace=True)
            else:
                #df1 < df2
                #drop chr Y from df1
                print('dropped chr Y from df1')
                df1.drop(df1[df1[1].str.contains('_chr_Y')].index, inplace=True)


    #df1 has X
    elif df1[1].str.contains('_chr_X').any():
        print('df1 has X')
        #df2 has X and Y
        if df2[1].str.contains('_chr_Y').any():
            print('df2 has X and Y')
            contains_Y = True
        else:
            contains_Y = False

        #df2 has X
        if df2[1].str.contains('_chr_X').any():
            print('df2 has X')      
            if contains_Y:
                df1_chrX = df1[df1[1].str.contains('_chr_X')]
                df2_chrX = df2[df2[1].str.contains('_chr_X')]

                #df1 > df2
                if int(df1_chrX.iloc[2]) > int(df2_chrX.iloc[2]):
                    #drop chr X from df2
                    print('dropped chr X from df2')
                    df2.drop(df2[df2[1].str.contains('_chr_X')].index, inplace=True)
                else:
                    #df1 < df2
                    #drop chr X from df1
                    print('dropped chr X from df1')
                    df1.drop(df1[df1[1].str.contains('_chr_X')].index, inplace=True)


    return df1, df2




#initial 'reorder_df' is set to false -- df will not be reordered
reorder_df = False

#iterate through each translation file
for j,i in enumerate(trans_files):
    print(i)
    #check if translation file is empty
    file_size = os.path.getsize(i)
    if file_size > 0:
        translation = pd.read_csv(i, sep='\t', header=None)
    else:
        translation = pd.DataFrame() 
    
    #if phasing data is trio and hic, mashmap has been previously filtered
    if trio_hic:
        try:
            mashmap = pd.read_csv(mashmap_files1[j], sep='\t', header=None)
        except EmptyDataError:
            print("Mashmap haplotype file is empty. May need to # out mashmap_hap1 and mashmap_hap2 lines of code in sh file")
    else:
        try:
            mashmap = pd.read_csv(mashmap_files[j], sep='\t', header=None)
        except EmptyDataError:
            print("Mashmap file is empty. May have the wrong set of mashmap files # out in sh file")
            
    #check if mashmap is empty
    if mashmap.empty:
        print('Haplotype1/2 or dam/sire needs to be chosen in sh file')
        break
    else:
        print('find missing chromosomes')
        needed_chromos = missing_chromos(translation, num_chromos)
    
        print('add new chromosomes to translation file')
        mashmap_sub = mashmap.copy()
        translation, reorder_df = add_chromos(mashmap_sub, num_chromos, translation)
        if reorder_df: 
            translation = reorder(translation, num_chromos)       
                              
        #check for duplicate contigs
        duplicate_contigs = translation[translation.duplicated([0])]
        if len(duplicate_contigs) > 0:
            print('warning: duplicate contig names')
            print('duplicate_contigs=',duplicate_contigs)
            translation = reorder(translation, num_chromos)
               
        if j == 0:
            translation_hap1 = translation
        else:
            translation_hap2 = translation
            
    

if trio_hic:
    print('check haplotype files for missing chromosomes')
    if os.path.getsize(mashmap_files2[0]) != 0:
        mashmap1 = pd.read_csv(mashmap_files2[0], sep='\t', header=None)
    else:
        print('mashmap_hap1.out is empty')
        mashmap1  = pd.DataFrame()

    if os.path.getsize(mashmap_files2[1]) != 0:
        mashmap2 = pd.read_csv(mashmap_files2[1], sep='\t', header=None)
    else:
        print('mashmap_hap2.out is empty')
        mashmap2  = pd.DataFrame()

    mashmap = pd.concat([mashmap1, mashmap2], axis=0)

    if mashmap.empty:
        print('mashmap1 and 2 are empty - no other sex chromosomes to add')
    else:
        print('looking for sex chromosomes in haplotype files')
        translation_hap1, translation_hap2 = find_sex_chromos(mashmap, translation_hap1, translation_hap2)   



print('checking sex chromosome duplicates')
#if translation_hap2[0].str.contains('sire').any() and translation_hap1[0].str.contains('dam').any():
if translation_hap2[0].str.contains('dam').any() and translation_hap1[0].str.contains('sire').any():
    print('checking sire/dam sex chromosomes')
    translation_hap1, translation_hap2 = remove_sex_duplicates(translation_hap1, translation_hap2)
else:
    print('checking hap1/hap2 sex chromosomes')
    translation_hap1, translation_hap2 = fix_sex_chromosomes(translation_hap1, translation_hap2)

translation_hap1.to_csv('translation_hap1.csv', sep="\t", header=False, index=False)
translation_hap2.to_csv('translation_hap2.csv', sep="\t", header=False, index=False)
