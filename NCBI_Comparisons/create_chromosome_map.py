#created by Sarah E. Fumagalli

import pandas as pd
import argparse



parser=argparse.ArgumentParser()

parser.add_argument("--reference_ids", type=str, help='fna.fai file for reference genomic assembly')
parser.add_argument("--sequence_report", type=str, help='chromosome sequence_report.tsv downloaded from NCBI')

args = parser.parse_args()

ref_data = args.reference_ids
seq_report = args.sequence_report


def chromosome_map(ref_data, seq_report):

    """
    #This function creates a pandas df with two columns: RefSeq names and associated chromosomes
    #Outputs pandas df called chromosome.map

    """
    

    def match_chromos(seq_report_df, id_data):

        """

        Selects and matches ID columns and chromosomes
        Creates final df

        """

        filtered_seq_report_df = seq_report_df[(seq_report_df['Role'] == "assembled-molecule")]

        chromo_map_dict = {}
        count = 1
        
        final_seq_report_df = filtered_seq_report_df[['Chromosome name', id_data]]
        final_seq_report_df.set_index(id_data, inplace=True)

        for index, row in final_seq_report_df.iterrows():
            if index in filtered_ref:
                chromo_map_dict[count] = {'ID': index, 'chromo name': 'chr_' + str(row['Chromosome name'])}
                count += 1

        map_file = pd.DataFrame.from_dict(chromo_map_dict).T
        map_file.to_csv('chromosome.map', sep="\t", header=False, index=False)



    #read in reference fna.fai file
    ref_df = pd.read_csv(ref_data, sep="\t", header=None)

    #select first column
    filtered_ref = ref_df[ref_df.columns[0]].tolist()


    #read in sequence_report.tsv
    if 'sequence_report' in seq_report:
        print('using sequence_report.tsv')
        seq_report_df = pd.read_csv(seq_report, sep="\t")
    else:
        print('using assembly_report.txt')
        seq_report_df = pd.read_csv(seq_report, sep="\t", skiprows=31, header=None)
        seq_report_df.columns = ['Sequence-Name', 'Role', 'Chromosome name', 'Assigned-Molecule-Location/Type', 'GenBank seq accession', 'Relationship', 'RefSeq seq accession', 'Assembly-Unit', 'Sequence-Length', 'UCSC-style-name']


    #check for RefSeq/GenBank column name
    if seq_report_df['RefSeq seq accession'].eq('na').all():
        print('RefSeq all na - using GenBank')
        match_chromos(seq_report_df, 'GenBank seq accession')
    else:
        match_chromos(seq_report_df, 'RefSeq seq accession')




chromosome_map(ref_data, seq_report)

