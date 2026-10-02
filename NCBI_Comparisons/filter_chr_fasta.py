#created by Sarah E. Fumagalli

import argparse
from Bio import SeqIO

parser=argparse.ArgumentParser()

parser.add_argument('--fasta', type=str, help='path to fasta with chr names')
parser.add_argument('--outfile', type=str, help='output file name')

args = parser.parse_args()

#set up new filtered fasta file 
filtered_fasta = open(args.outfile, "w")

#iterate through fasta and grab IDs with 'chr'
for seq_record in SeqIO.parse(args.fasta, "fasta"):
    ID = seq_record.id
    seq = seq_record.seq
    
    if 'chr' in ID:
        print(ID)

        #write seq to file
        filtered_fasta.write('>' + ID)
        filtered_fasta.write("\n")
        filtered_fasta.write(str(seq))
        filtered_fasta.write("\n")

filtered_fasta.close()
