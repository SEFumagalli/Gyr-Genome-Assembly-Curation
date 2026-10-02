import pandas as pd
import argparse
from Bio import SeqIO

parser=argparse.ArgumentParser()

parser.add_argument('--chromosome_map', help='path to manually created chromosome.map')
parser.add_argument('--reference', help='path to reference fasta')

args = parser.parse_args()

print(args.chromosome_map)
print(args.reference)

def format_chr_map(mapping):
    """
    
    If a complete chromosome.map file is used, both columns are joined and structured as a list
    If extra filtering must be done to map the chromosomes, a df is created

    """
    
    if mapping.shape[1] > 2:
        #combine col 1 and 2 into single string
        mapping[3] = mapping[1] + '_' + mapping[2]
        #drop cols 1 and 2
        mapping.drop(columns=[1,2], inplace=True)
        #set first column as index
        chr_map = mapping.set_index(0)
        extra_step = True
    else:
        chr_map = (mapping[0] + '_' + mapping[1]).tolist()
        extra_step = False

    return chr_map, extra_step


def format_reference_file_name(ref):
    """
    
    Format the reference file name for the modified version of the file

    """

    #reformat reference file name for new file
    if '/' in ref:
        ref = ref.strip().split("/")
        file_bits = ref[-1].split(".")

        if len(file_bits) > 2:
            head = ".".join(file_bits[:-1])
            tail = file_bits[-1]
        else:
            head = file_bits[0]
            tail = file_bits[1]
        file_name = ref[1:-1]
        modified_file_name = "/".join(file_name)
    else:
        file_bits = ref.split(".")

        if len(file_bits) > 1:
            head = ".".join(file_bits[:-1])
            tail = file_bits[-1]
        else:
            head = file_bits[0]
            tail = file_bits[1]
        modified_file_name = ""


    return modified_file_name, head, tail


def chromosome_mapping(ref, file_name, head, tail, chr_map, extra_step):
    """

    Match chromosome name with fasta ID.
    Modify the reference.fasta to show chromosome names.

    """
    
    if file_name == "":
        newfile = open(head + ".chr." + tail, "w")
    else:
        newfile = open("/" + file_name + "/" + head + ".chr." + tail, "w")
    found = 0
    for seq_record in SeqIO.parse(ref, "fasta"):
        ID = seq_record.id
        seq = seq_record.seq
    
        #split ID and grab first string
        name = ID.split(' ')
        new_id = name[0]

        #check if extra filtering required
        if extra_step:
            #check for id in chr_map
            if new_id in chr_map.index:
                #grab new id name from column of matching index
                c = chr_map.loc[new_id, 3]
                #save id to file
                newfile.write('>' + c)
                #next line
                newfile.write("\n")
                found = 1
        else:
            for c in chr_map:
                #find id in chomos_list
                if c.startswith(new_id):
                    #save id to file
                    newfile.write('>' + c)
                    #next line
                    newfile.write("\n")
                    found = 1
        #if id has no chromosome name match
        if found == 0:
            #save original id to file
            newfile.write('>' + ID)
            #next line
            newfile.write("\n")
        else:
            #reset found
            found = 0


        #write seq to file
        newfile.write(str(seq))
        #next line
        newfile.write("\n")
    newfile.close()
    




def create_final_chr_map(final_chr_map):
    """
    
    Creates new df by splitting column into two columns

    """
    
    final_chr_map.drop(columns=[0], inplace=True)
    final_chr_map.to_csv('chromosome.map', index=False, header=False, sep='\t')



#combine RefSeq identifier and chromosome number from chromosome.map
mapping = pd.read_csv(args.chromosome_map, sep='\t', header=None)
print(mapping)
mapping_og = mapping.copy()
chr_map, extra_step = format_chr_map(mapping)

#Read in reference and create new file name
modified_file_name, head, tail = format_reference_file_name(args.reference)

#Match chromosome to fasta ID
chromosome_mapping(args.reference, modified_file_name, head, tail, chr_map, extra_step)

print("Updated reference fasta - .chr added to file name")

#If extra_step == True --> create final chromosome.map file
if extra_step == True:
    print('creating chromosome.map file for verkko-fillet')
    create_final_chr_map(mapping_og)
else:
    mapping_og.to_csv('chromosome.map', index=False, header=False, sep='\t')
