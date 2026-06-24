#!/usr/bin/env python3

## created by Sarah E. Fumagalli using a combination of Lee Ackerson's and Sergey Koren's scripts

## Run using bash script or command line
## python3 update_patch_2_path.py --utig4s tsv_file_path_to_utig4s --patches tsv_file_path_to_patches --combine formatted_list_of_hapmers



##------------------------------------------------------------------------------------------------------------------------------------------------------------------------------##
##  --utig4s                                                                                                                                                                    
##
##      Assemblies phased with trio: yourOriginalAssembly/6-rukki/unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.paths.tsv
##      Assemblies phased without trio: yourOriginalAssembly/8-hicPipeline/rukki.paths.tsv
##
##
##  --patches
##
##      patches file formatting example - include <hapmer_name> !tab! <overlap_patch_overlap>
##
##      sire_compressed.k31.hapmer_from_utig4-1772   utig4-2010-,utig4-2008-,utig4-2009+,utig4-2008-,utig4-1772-
##      dam_compressed.k31.hapmer_from_utig4-820     >utig1-16631<utig1-2376<utig1-2373<utig1-2376<utig1-2373>utig1-2374>utig1-6098>utig1-16116<utig1-5459
##
##      In the sire patch, utig4-2010 and utig4-1772 overlap with utig4s in the full path
##      In the dam patch, we are adding a telomere to the end of utig4-820. utig1-16631 is the overlapping utig1 we want to aim for.
##
##
##      If you have more than one patch per hapmer, show separation with :.
##      Patches can be of different formatting.
##
##      sire_compressed.k31.hapmer_from_utig4-1772   utig4-2010-,utig4-2008-,utig4-2009+,utig4-2008-,utig4-1772-:>utig1-16631<utig1-2376<utig1-2373<utig1-2376
##
##
##      If splitting a path, add hapmer name twice with final patches 
##          !!for now, these paths must be the final path - it does not go through the add patch process!!
##
##      sire_compressed.k31.hapmer_from_utig4-1772   utig4-2010-,utig4-2008-
##      sire_compressed.k31.hapmer_from_utig4-1772   utig4-2009+,utig4-2008-,utig4-1772-
##
##  
##  --combine
##      
##      hapmer paths to combine formatting example - 'hapmer_name;hapmer_name'
##
##      !!must be set as string!!
##
##      If you have more than one set of hapmers to combine, show separtion with :. 
##
##      'sire_compressed.k31.hapmer_from_utig4-1772;sire_compressed.k31.hapmer_from_utig4-1532:dam_compressed.k31.hapmer_from_utig4-820;dam_compressed.k31.hapmer_from_utig4-20'
##
##
##  Output
##
##      Bandage plot formatted paths -> either listed in std file or printed on screen
##      patches_2_final_paths.tsv    -> lists hapmer names and updated paths - formatted for Wen Huang's perl script
##
##--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------##




## !! Make sure you are running from your verkko assembly directory !!




import sys
import pandas as pd
import time
import argparse
import os
import itertools
import re
import random
import graph_functions as gf


parser=argparse.ArgumentParser()

parser.add_argument("--utig4s", type=str, help='tsv file of utig4s')
parser.add_argument("--patches", type=str, help='tsv file of patches')
parser.add_argument("--combine", type=str, help='list of hapmers to combine', required=False)


args = parser.parse_args()


def get_utig1_from_utig4(og_path):
    """

    script converts utig4 paths into utig1 paths 
    it takes into account duplicate utig1s - unlike utig4_2_utig1.py
    path must be in gaf formatting
    
    """
    
    MAX_GAP_SIZE=100000
    cwd = os.getcwd()
    mapping_file = cwd + '/6-layoutContigs/combined-nodemap.txt'
    edge_overlap_file = cwd + '/6-layoutContigs/combined-edges.gfa'

    #Either paths from rukki or just single nodes
    paths_file = og_path

    nodelens_file = cwd + '/6-layoutContigs/nodelens.txt'

    #transform paths to base elements - mbg nodes and gaps.
    def get_leafs(path, mapping, edge_overlaps, raw_node_lens):
            path_len = 0
            for i in range(0, len(path)):
                    path_len += raw_node_lens[path[i][1:]]
                    if i > 0: path_len -= edge_overlaps[gf.canon(path[i-1], path[i])]
            result = [(n, 0, raw_node_lens[n[1:]]) for n in path]
            overlaps = []
            for i in range(1, len(path)):
                    overlaps.append(edge_overlaps[gf.canon(path[i-1], path[i])])
            current_len = 0
            for i in range(0, len(result)):
                    assert result[i][2] > result[i][1]
                    assert result[i][2] <= raw_node_lens[result[i][0][1:]]
                    assert result[i][1] >= 0
                    current_len += result[i][2] - result[i][1]
                    if i > 0: current_len -= overlaps[i-1]
            assert current_len == path_len
            while True:
                    any_replaced = False
                    new_result = []
                    new_overlaps = []
                    for i in range(0, len(result)):
                            if result[i][0][1:] not in mapping:
                                    new_result.append(result[i])
                                    if i > 0: new_overlaps.append(overlaps[i-1])
                            else:
                                    any_replaced = True
                                    part = [(n, 0, raw_node_lens[n[1:]]) for n in mapping[result[i][0][1:]][0]]
                                    part[0] = (part[0][0], part[0][1] + mapping[result[i][0][1:]][1], part[0][2])
                                    part[-1] = (part[-1][0], part[-1][1], part[-1][2] - mapping[result[i][0][1:]][2])
                                    if result[i][0][0] == "<":
                                            part = [(gf.revnode(n[0]), raw_node_lens[n[0][1:]] - n[2], raw_node_lens[n[0][1:]] - n[1]) for n in part[::-1]]
                                    old_start_clip = result[i][1]
                                    old_end_clip = (raw_node_lens[result[i][0][1:]] - result[i][2])
                                    part[0] = (part[0][0], part[0][1] + old_start_clip, part[0][2])
                                    part[-1] = (part[-1][0], part[-1][1], part[-1][2] - old_end_clip)
                                    new_result += part
                                    if i > 0: new_overlaps.append(overlaps[i-1])
                                    for j in range(1, len(part)):
                                            new_overlaps.append(edge_overlaps[gf.canon(part[j-1][0], part[j][0])])
                    assert len(new_result) == len(new_overlaps)+1
                    assert len(new_result) >= len(result)
                    if not any_replaced: break
                    result = new_result
                    overlaps = new_overlaps
                    current_len = 0
                    for i in range(0, len(result)):
                            # strangely, this assertion is not always true.
                            # The ONT based k-mer increase can create a node where the overlap is greater than the initial MBG node size
                            # and in that case the initial MBG node will have a "negative" length within the contig
                            # assert result[i][2] > result[i][1]
                            assert result[i][2] <= raw_node_lens[result[i][0][1:]]
                            assert result[i][1] >= 0
                            current_len += result[i][2] - result[i][1]
                            if i > 0: current_len -= overlaps[i-1]
                    assert current_len == path_len
            return (result, overlaps)

    raw_node_lens = {}
    with open(nodelens_file) as f:
            for l in f:
                    parts = l.strip().split('\t')
                    assert parts[0] not in raw_node_lens or raw_node_lens[parts[0]] == int(parts[1])
                    raw_node_lens[parts[0]] = int(parts[1])

    edge_overlaps = {}
    with open(edge_overlap_file) as f:
            for l in f:
                    parts = l.strip().split('\t')
                    assert parts[0] == "L"
                    fromnode = (">" if parts[2] == "+" else "<") + parts[1]
                    tonode = (">" if parts[4] == "+" else "<") + parts[3]
                    overlap = int(parts[5][:-1])
                    key = gf.canon(fromnode, tonode)
                    if key in edge_overlaps: assert edge_overlaps[key] == overlap
                    edge_overlaps[key] = overlap

    node_mapping = {}
    cut_mapping  = {}
    with open(mapping_file) as f:
            for l in f:

                    parts = l.strip().split('\t')
                    assert parts[0] not in node_mapping
                    if not re.search(r"utig\d+[a-z]?-" , parts[1]):
                            continue
                    path = parts[1].split(':')[0].replace('<', "\t<").replace('>', "\t>").strip().split('\t')
                    left_clip = int(parts[1].split(':')[1])
                    right_clip = int(parts[1].split(':')[2])
                    node_mapping[parts[0]] = (path, left_clip, right_clip)
                    left_len = raw_node_lens[parts[0]]
                    right_len = 0
                    for i in range(0, len(path)):
                            right_len += raw_node_lens[path[i][1:]]
                            if i > 0: right_len -= edge_overlaps[gf.canon(path[i-1], path[i])]
                    assert left_len == right_len - left_clip - right_clip

                    # save the mapping of cut nodes to their respective coordinates so we can find them later
                    if (len(path) == 1 and path[0][1:] in raw_node_lens):
                            new_name = path[0][1:] + ":" + str(left_clip) + ":" + str(raw_node_lens[path[0][1:]]-right_clip)
                            cut_mapping[new_name] = parts[0]
    pieceid = 0

    #all these contains info about contigs - here nodes or rukki paths splitted by N
    #paths are transformed into mbg nodes and gaps with get_leafs procedure
    contig_lens = {}
    contig_node_offsets = {}
    contig_pieces = {}
    comments = {}
    lp  = og_path.strip().split('\t')

    #  Find all words that
    #       begin with [<>], contain anything but [
    #       begin with [N, contain digits and end with N] or N:optional-description]
    #       we dump the description here and anly keep the N, digits N] part
    #
    fullname = lp[0]
    comments[fullname] = lp[2] if len(lp) >= 3 else ""
    pathfull = re.findall(r"([<>][^[]+|\[N\d+N(?:[^\]]+){0,1}\])", lp[1])

    contig_pieces[fullname] = []

    for pp in pathfull:
        #pp is either path without gaps or gap. In latest case do nothing
        gp = re.match(r"\[(N\d+N)(?:[^\]]+){0,1}\]", pp)
        if gp:
                tuned_numn = min(round(int(gp.group(1)[1:-1]) * 1.5), MAX_GAP_SIZE)
                contig_pieces[fullname].append("[N" + str(tuned_numn) + "N:gap]")
                continue

        pieceid = pieceid + 1
        pathname = fullname

        (path, overlaps) = get_leafs(re.findall(r"[<>][^<>]+", pp), node_mapping, edge_overlaps, raw_node_lens)
        # skip a path if the only thing in it is a gapfill
        if len(path) == 1 and path[0][0][1:4] == "gap":
                continue

        contig_node_offsets[pathname] = []
        pos = 0
        end = -1
        for i in range(0, len(path)-1):
                contig_node_offsets[pathname].append(pos)
                pos += path[i][2] - path[i][1]
                pos -= overlaps[i]
        contig_node_offsets[pathname].append(pos)
        contig_lens[pathname] = contig_node_offsets[pathname][-1] + path[-1][2] - path[-1][1]
        check_len = 0
        for i in range(0, len(path)):
                check_len += path[i][2] - path[i][1]
                if i > 0: check_len -= overlaps[i-1]
        assert contig_lens[pathname] == check_len
        pathstr = ""
        for i in range(0, len(path)):
                # build a name using the contig without the <> but also append coordinates if it's partial match to check for cut node
                # if a cut version exists, use that name instead, otherwise use the original node name
                new_name = path[i][0][1:]
                if path[i][1] != 0 or path[i][2] != raw_node_lens[new_name]:
                        if path[i][0][0] == ">":
                                new_name = path[i][0][1:] + ":" + str(path[i][1]) + ":" + str(path[i][2])
                        else:
                                new_name = path[i][0][1:] + ":" + str(raw_node_lens[new_name]-path[i][2]) + ":" + str(raw_node_lens[new_name]-path[i][1])
                        if new_name not in cut_mapping:
                                new_name = path[i][0][1:]

                # when we see the name in our path already and the offset is earlier than the largest we have already seen, this is an overlap
                # we skip these overlapping nodes from the path and continue at the new unique/larger offset node
                #sys.stderr.write("Checking node %s with coordinates %d-%d and offset is %d vs %d and is already used is %d\n"%(path[i][0], path[i][1], path[i][2], (contig_node_offsets[pathname][i]-path[i][1]), end, (new_name in pathstr)))
                if (contig_node_offsets[pathname][i]-path[i][1]) <= end and new_name in pathstr:
                        continue
                end = contig_node_offsets[pathname][i]-path[i][1]
                if path[i][1] != 0 or path[i][2] != raw_node_lens[path[i][0][1:]]:
                        if (new_name in cut_mapping):
                                pathstr += path[i][0] + "_" + cut_mapping[new_name].strip().split("_")[-1]
                        else:
                                pathstr += path[i][0]
                else:
                        pathstr += path[i][0]
        contig_pieces[fullname].append(pathstr)

    for fullname in contig_pieces:
            if "name" in fullname: continue
            result = "".join(contig_pieces[fullname])


    return result




def convert_verkko_path(path_str):
    """

     translates path from >/< to +/-


    """
    converted = []
    if 'utig4-' in path_str:
        utig_type = 'utig4-'
    else:
        utig_type = 'utig1-'
    for index,segment in enumerate(path_str.split(utig_type)):
        if index == 0:
            #grab > or < for first utig
            symbol = segment
        else:
            #subsequent segments will have number and next utig's symbol attacked
            #remove < or > at the end and add - or + based on the previous symbol
            if symbol == '<':
                if not segment.endswith(('>', '<')):
                    converted.append(f'{utig_type}{segment}-')
                    break
                else:
                    converted.append(f'{utig_type}{segment[:-1]}-,')
                    symbol = segment[len(segment)-1]
            elif symbol == '>':
                if not segment.endswith(('>', '<')):
                    converted.append(f'{utig_type}{segment}+')
                    break
                else:
                    converted.append(f'{utig_type}{segment[:-1]}+,')
                    symbol = segment[len(segment)-1]

    return ''.join(converted)




def flip_and_swap(input_path, final_format):
    """

    reverse path and symbol according to utig

    """

    if type(input_path) == str:
        entries = input_path.split(',')
    else:
        entries = input_path

    #reverse path
    entries.reverse()

    swapped = []
    for item in entries:
        if item.endswith('+'):
            swapped.append(item[:-1] + '-')
        elif item.endswith('-'):
            swapped.append(item[:-1] + '+')
        else:
            swapped.append(item)

    if final_format == str:
        swapped = ','.join(swapped)

    return swapped



def clean_utig1s(utigs):
    """

    remove gap info from +/- formatted utig1 path

    """

    #split path into list
    utig_list = utigs.split(",")
    #strip extra space around each utig
    utig_list = [x.strip() for x in utig_list]

    cleaned_utigs = []
    for u in utig_list:
        if '[' in u:
            utig_name, direction = u.split('[')
            #keep utig name and the last character - direction
            u = utig_name + direction[-1:]
            cleaned_utigs.append(u)
        else:
            #no modification necessary
            cleaned_utigs.append(u)

    
    return cleaned_utigs




def clean_utig4s(utig_list):
    """

    remove gap/tangle information

    """

    cleaned_utigs = []
    for u in utig_list:
        if "utig" in u:
            cleaned_utigs.append(u)
        #else:
        #    print('removed item in utig4_list=',u)

    return cleaned_utigs



def gaf_format(path_str):
    """

    translates +/- to >/<

    """

    converted = []
    for segment in path_str.split(','):
        if segment.endswith('-'):
            converted.append(f'<{segment[:-1]}')
        elif segment.endswith('+'):
            converted.append(f'>{segment[:-1]}')
        else:
            converted.append(segment)  # catch unexpected format

    return ''.join(converted)



def find_duplicates(utig_list):
    """

    finds consecutive duplicate utigs - gives warning and removes duplicates for Bandage

    """
    
    #convert string in list to multiple strings
    #split_utigs = utig_list[0].split(",")

    #check for utigs that are duplicates and consecutive
    bandage_formatted = []
    for index,item in enumerate(utig_list):
        #print(item)
        if utig_list.count(item) > 1 and utig_list[index-1] == item:
            continue
            #print('removed utig from Bandage list= ' + item + ' from index location ' + str(index))
        else:
            #print('adding item')
            bandage_formatted.append(item)

    print('bandage formatted=', ",".join(bandage_formatted))



def prepare_path(path, convert_verkko_path):
    """
    
    this splits path by utig4s, removes extra space, removes items that do not contain 'utig'

    """
    

    #check path format - hapmer full paths should be +/- already
    if '<' in path or '>' in path:
        #print('converting </> to +/-')
        path = convert_verkko_path(path)
    
    #split path into list
    utig4_list = path.split(",")
    #strip extra space around each utig
    utig4_list = [x.strip() for x in utig4_list]
    #clean utig4 list of gap/tangle and other ambiguous formatting
    #utig4s = []
    #for u in utig4_list:
    #    if "utig" in u:
    #        utig4s.append(u)


    return utig4_list



def patches_to_dict(patches, name):
    """

    converts patches file to dict

    """
    
    def ostrip(o):
        try: return o.strip()
        except: return list(map(str.strip, o))
    
    patch_string = patches.loc[name,'paths']
    patches_list = patch_string.split(":")
    
    #convert patches_list to dict
    patches_dict = {index: value.split(",") for index, value in enumerate(patches_list)}
    patches_dict = {k: ostrip(v) for k, v in patches_dict.items()}

    return patches_dict



def prepare_utig1_path(data, get_utig1_from_utig4, gaf_format, convert_verkko_path, flip_and_swap, clean_utig1s):
    """

    convert utig4 path to utig1 path, convert to +/- format, flip orientation when needed, 
    and clean utig1s

    """

    #double check path is utig4
    if data[0][0].startswith('utig4'):
        #convert utig4s back into gaf format
        utig4s = gaf_format(",".join(data[0]))
        #print('utig4s=',utig4s)

        #grab utig1 path from get_utig1_from_utigs
        utig1 = get_utig1_from_utig4(data[1] + '\t' + utig4s + '\t' + data[2])
        #print('utig1=',utig1)

        #convert to +/-
        utig1 = convert_verkko_path(utig1)
        utig1s = [utig1]
        #print('utig1s=',utig1s)

    else:
        print('check path for utig4s')

    return utig1s



def find_locations(v, utigs, flip_and_swap, flipped):
    """

    identify possible leader (insert_after) and tail (insert_before) of patch
    flip patch path if needed

    """
    
    def find_header_tail(patch_path, utigs):
        insert_after = patch_path[0]
        insert_before = patch_path[-1]
        insert_after_loc = ''
        insert_before_loc = ''
        #iterate through utigs for leader and tail locations
        for i,j in enumerate(utigs):
            if insert_after == j:
                insert_after_loc = i
                #print('found leader=',j)
                #print('leader location=', i)
            #check if patch utig in utigs path
            if j in utigs:
                if insert_before == j:
                    insert_before_loc = i
                    #print('found tail=',j)
                    #print('tail location=', i)

        return insert_after, insert_before, insert_after_loc, insert_before_loc

    insert_after, insert_before, insert_after_loc, insert_before_loc = find_header_tail(v, utigs)
 
    #if insert_before_loc and insert_after_loc are empty strings, try flipping the path
    if insert_after_loc == '' and insert_before_loc == '':
        if flipped == False:
            print('flipping patch path')
            v = flip_and_swap(v, list)
            insert_after, insert_before, insert_after_loc, insert_before_loc = find_header_tail(v, utigs)
            flipped = True
        else:
            print('already been flipped')
            #print('insert_before_loc=', insert_before_loc)
            #print('insert_after_loc=', insert_after_loc)

    
    return insert_after, insert_before, insert_after_loc, insert_before_loc, flipped, v




def add_patch(utigs, v, find_locations, insert_after, insert_before, insert_after_loc, insert_before_loc, flipped):

    """

    add patch to path

    """
 
    def join_to_end(insert_after_loc, utigs, insert_before_loc, v):
        """

        join patch to the end of the path

        """

        utigs = utigs + v[1:]

        return utigs


    def remove_join_to_end(insert_after_loc, utigs, insert_before_loc, v, find_locations):
        """

        remove some utigs and then join patch to the end of the path

        """

        utigs = utigs[:(insert_after_loc+1)]
        #print('reduced utigs=',utigs)

        #no need to flip_and_swap if header/tail were identified
        flipped = True

        #find location of utig patch leader and tail
        insert_after, insert_before, insert_after_loc, insert_before_loc, flipped, v = find_locations(v, utigs, flip_and_swap, flipped)

        #joining patch to end of path
        utigs = utigs + v[1:]

        return utigs


    def remove_insert_patch(insert_after_loc, utigs, insert_before_loc, v, find_locations):
        """

        remove utigs between leader and tail, then insert patch

        """

        del utigs[(insert_after_loc+1):insert_before_loc]
        #print('reduced utigs=',utigs)

        #no need to flip_and_swap if header/tail were identified
        flipped = True
        
        #find location of utig patch leader and tail
        insert_after, insert_before, insert_after_loc, insert_before_loc, flipped, v = find_locations(v, utigs, flip_and_swap, flipped)

        #insert patch
        utigs = utigs[:(insert_after_loc+1)] + v[1:-1] + utigs[insert_before_loc:]

        return utigs


    def insert_patch(insert_after_loc, utigs, insert_before_loc, v):
        """
    
        insert patch between leader and tail
    
        """
        
        utigs = utigs[:(insert_after_loc+1)] + v[1:-1] + utigs[insert_before_loc:]
            
        return utigs        


    #join patch to the end of the path
    if (insert_after_loc + 1) == len(utigs) and insert_before_loc == '':
        #print('add patch to end of path')
        utigs = join_to_end(insert_after_loc, utigs, insert_before_loc, v)

    #remove some utig1s and then add patch to end of path
    elif (insert_after_loc + 1) != len(utigs) and insert_before_loc == '':
        #print('some utig4s need removed and then add patch to end of path')
        utigs = remove_join_to_end(insert_after_loc, utigs, insert_before_loc, v, find_locations)

    #remove some utig1s and then insert patch between header and tail
    elif (insert_before_loc - insert_after_loc) > 1:
        #print('leader and tail are not next to each other - removing utigs')
        utigs = remove_insert_patch(insert_after_loc, utigs, insert_before_loc, v, find_locations)

    #insert batch between header and tail
    elif (insert_before_loc - insert_after_loc) == 1:
        #print('leader and tail are next to each other')
        utigs = insert_patch(insert_after_loc, utigs, insert_before_loc, v)

    else:
        sys.exit('check header/tail in patch - patch not making sense')


    return utigs



def hapmer_splits(updated_splits, assignment, patches, name, convert_verkko_path, find_duplicates, gaf_format):

    """

    finds hapmers that were split in the patches file
    for each new hapmer, it is converted to +/-, set up for Bandage, reverted to </> for verkko and saved

    """
   
    temp_patches = patches[patches['name'] == name]
    count = 1
    for k,v in temp_patches.iterrows():
        #remove extra spaces
        v['paths'] = v['paths'].replace(" ", "")
        if '<' in v['paths'] and '>' in v['paths']:
            #convert from </> to +/-
            temp_path = convert_verkko_path(v['paths'])
            temp_path = temp_path.split(',')
        else:
            temp_path = v['paths'].split(',')

        #create bandage formatted path
        find_duplicates(temp_path)

        #format path for verkko </>
        translated_path = gaf_format(",".join(temp_path))

        #save split info
        updated_splits.append([name, translated_path, name + '_new' + str(count), assignment])
        count += 1


    return updated_splits





def combine_hapmers(final_paths, combine, combos_list, prepare_utig1_path, gaf_format):
    """

    iterates through combos_list, splits hapmer names, checks if utig1 conversion is necessary, 
    and combines paths 

    """

    if len(combine) > 0:
        #combine paths in combine_split dict
        for c in combos_list:
            parts_names = c.split(';')

            #check for utig1 usage
            utig1_convert = False
            for p in parts_names:
                if 'utig1' in combine[p][0][0]:
                    utig1_convert = True

            if utig1_convert == True:
                #print('hapmer needs converting to utig1')
                parts = []
                for p in parts_names:
                    if 'utig4' in combine[p][0][0]:
                        #print('converting to utig1')
                        utig1s = prepare_utig1_path(combine[p][0], get_utig1_from_utig4, gaf_format, convert_verkko_path, flip_and_swap, clean_utig1s)
                        parts.append(utig1s)
                    else:
                        #print('already in utig1')
                        parts.append(combine[p][0])

                #join paths
                final_path = list(itertools.chain.from_iterable(parts))

                #format path for verkko </>
                translated_path = gaf_format(",".join(final_path))

                #final dict using combined hapmer list and path - grabbing the first hapmer's name and assignment
                final_paths[c] = [translated_path, parts_names[0], combine[parts_names[0]][2]]

            else:
                #no need to convert to utig1
                #print('no conversion needed')
                parts = []
                for p in parts_names:
                    parts.append(combine[p][0])

                #join paths
                final_path = list(itertools.chain.from_iterable(parts))

                #format path for verkko </>
                translated_path = gaf_format(",".join(final_path))

                #final dict using combined hapmer list and path - grabbing the first hapmer's name and assignment
                final_paths[c] = [translated_path, parts_names[0], combine[parts_names[0]][2]]

    else:
        print('no hapmers to combine')



    return final_paths




## --------------------------------------------------------------------------------------------------------------------------



#open patches file as df (may have more than one row with same hapmer name)
patches = pd.read_csv(args.patches, sep="\t", header=None, names=['name', 'paths'])
patches = patches.set_index(patches.columns[0])
hapmer_list = patches.index.tolist()


#create list of lists for hapmers that need to be combined
if args.combine is not None:
    combos_list = args.combine.split(":")
else:
    combos_list = []


#grab utig4s_file
orig_utig4 = pd.read_csv(args.utig4s, sep="\t", index_col=[0])


final_paths = {}
combine = {}
updated_splits = []
split_index = 0
#iterate hapmer_list
for index, name in enumerate(hapmer_list):
    print('hapmer=',name)
    utig1_list = []
    #identify utig4 row by hapmer name
    path = orig_utig4.loc[name,'path']
    assignment = orig_utig4.loc[name, 'assignment']
    #print('initial index=',index)
    
    #reset index after splits
    #print('split index=',split_index)
    if split_index != index:
        index = split_index
        #print('adjusted index=',index)

    #format and clean path 
    utig4s = prepare_path(path, convert_verkko_path)
    print('cleaned_utig4s=',utig4s)

    #check patches for hapmer splits
    hapmer_split = patches.loc[name].value_counts().get(name, 0)
    #print('hapmer_splits=',hapmer_split)
    if hapmer_split > 1:
        print('setting up splits')
        updated_splits = hapmer_splits(updated_splits, assignment, patches, name, convert_verkko_path, find_duplicates, gaf_format)
        split_index = index + len(updated_splits)
        continue
    else:
        print('no splits')
        #format patches
        patches_dict = patches_to_dict(patches, name)
        #update split_index
        split_index += 1
    
    #check if utig4s are in patch
    if 'utig4' in patches.loc[name,'paths']:
        print('processing utig4 patches')
        utig4_patches = {}
        for key, val in patches_dict.items():
            if 'utig4' in val[0]:
                utig4_patches[key] = val
        for k, v in utig4_patches.items():                 
            #check formatting of utig4 patch
            if '<' in v[0] and '>' in v[0]:
                #print('converting utig4 patch to +/-')
                string_v = convert_verkko_path(v[0])
                v = string_v.split(",")        
            print('converted v=',v)

            #set flipped to False - this makes sure it the patch does not flip again once a header/tail is found
            flipped = False

            #find location of utig patch leader and tail
            insert_after, insert_before, insert_after_loc, insert_before_loc, flipped, v = find_locations(v, utig4s, flip_and_swap, flipped)
            #print('insert_after=',insert_after)
            #print('insert_after_loc=',insert_after_loc)    
            #print('insert_before=',insert_before)
            #print('insert_before_loc=',insert_before_loc)
        
            #add patch to path
            utig4s = add_patch(utig4s, v, find_locations, insert_after, insert_before, insert_after_loc, insert_before_loc, flipped)    
            break
        
        final_path = utig4s
        bandage_version = ",".join(final_path)
        print('bandage_version=',bandage_version)


    #check if utig1s are in patch
    if 'utig1' in patches.loc[name,'paths']:
        print('processing utig1 patches')                
        #grabbing utig1 patch key:values
        utig1_patches = {}
        for key, val in patches_dict.items():
            if 'utig1' in val[0]:
                utig1_patches[key] = val
        
        #convert utig4s back into gaf format
        utig4s = gaf_format(",".join(utig4s))
        #convert utig4s into utig1s
        utig1s = get_utig1_from_utig4(name + '\t' + utig4s + '\t' + assignment)
        #convert utig1s to +/- format
        utig1s = convert_verkko_path(utig1s)
        #remove gap information
        utig1s = clean_utig1s(utig1s)
        
        print('path_2_utig1s=',utig1s)
        print('utig1_patch=',utig1_patches)

        for k, v in utig1_patches.items():
            #check formatting of utig1 patch
            if '<' in v[0] or '>' in v[0]:
                #print('converting utig1 patch to +/-')
                string_v = convert_verkko_path(v[0])
                v = string_v.split(",")   
            print('converted patch=',v) 
        
            #set flipped to False - this makes sure it the patch does not flip again once a header/tail is found
            flipped = False

            #find location of utig patch leader and tail
            insert_after, insert_before, insert_after_loc, insert_before_loc, flipped, v = find_locations(v, utig1s, flip_and_swap, flipped)
            #print('insert_after=',insert_after)
            #print('insert_before=',insert_before)
            #print('insert_before_loc=',insert_before_loc)
            #print('insert_after_loc=',insert_after_loc)

            #add patch to path
            utig1s = add_patch(utig1s, v, find_locations, insert_after, insert_before, insert_after_loc, insert_before_loc, flipped)
            break

        final_path = utig1s
        bandage_version = ",".join(final_path)
        print('bandage_version=',bandage_version)
    
    #create bandage formatted path
    find_duplicates(final_path)
    #print('combos_list=',combos_list) 
    #create dict with fixed paths that need to be combined
    if not combos_list:
        #format path for verkko </>
        print('no combination needed')
        translated_path = gaf_format(",".join(final_path))
        final_paths[name] = [translated_path, name, assignment]
        print('\n')
    else:
        for c in combos_list:
            if name in c:
                print('adding to combine')
                combine[name] = [final_path, name, assignment] 
                print('\n')
                break

final_paths = combine_hapmers(final_paths, combine, combos_list, prepare_utig1_path, gaf_format)

#convert to pandas
df = pd.DataFrame.from_dict(final_paths, orient="index")

#format df
df.reset_index(inplace=True)
df.columns=["old_names(semicolon_separated)",  "new_path(patch)", "new_name", "new_assignment"]

#join df and updated_splits
if updated_splits:
    for i in updated_splits:
        df.loc[len(df)] = i

#save as tsv for perl script
df.to_csv(os.getcwd() + '/patches_2_final_paths.tsv', sep='\t', index=False)

