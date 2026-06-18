#created by Sarah E. Fumagalli - mirrored from Lee Ackerson's script - asm-path-translate.py

# This script is designed to adjust the verkko assembly.paths.tsv >/< syntax to the patch +/- syntax. E.x. <utig4-1479<utig4-1478 --> utig4-1479-,utig4-1478- 
## $ python asm-path-translate-printout-reverse.py '<utig4-1479<utig4-1478'
## > utig4-1479-,utig4-1478-

import sys # allows command line args

def convert_verkko_path(path_str): # translates +/- to >/<
    converted = []
    if 'utig4-' in path_str:
        utig_type = 'utig4-'
    else:
        utig_type = 'utig1-'
    print('utig_type=',utig_type)
    for index,segment in enumerate(path_str.split(utig_type)): 
        if index == 0:
            #grab > or < for first utig
            symbol = segment
        else:
            #subsequent segments will have number and next utig's symbol attacked
            #remove < or > at the end and add - or + based on the previous symbol
            if symbol == '<':
                if not segment.endswith(('>', '<')):
                    #last utig in list
                    converted.append(f'{utig_type}{segment}-')
                    break
                else:
                    converted.append(f'{utig_type}{segment[:-1]}-,')
                    symbol = segment[len(segment)-1]

            elif symbol == '>':
                if not segment.endswith(('>', '<')):
                    #last utig in list
                    converted.append(f'{utig_type}{segment}+')
                    break
                else:
                    converted.append(f'{utig_type}{segment[:-1]}+,')
                    symbol = segment[len(segment)-1]
                        
    return ''.join(converted)

if __name__ == "__main__": # make execution user friendly

    input_path = sys.argv[1]
    output_path = convert_verkko_path(input_path)
    print('\nInput +/- path:\n', input_path)
    print('\nTranslated >/< path:\n',output_path)

