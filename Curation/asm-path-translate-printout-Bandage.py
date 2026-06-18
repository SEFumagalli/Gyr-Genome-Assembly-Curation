# This script is designed to adjust the patch >/< syntax for Bandage. E.x. <utig4-1479<utig4-1478 -> utig4-1479,utig4-1478
# A file can be given or a sting on the command line.

## Example: python asm-path-translate.py '<utig4-1479<utig4-1478' 
## > utig4-1479,utig4-1478

import sys # allows command line args

def convert_verkko_path(path_str): 
    """

    Removes characters (>, <) and removes trailing details (_1)

    """

    def format_string(segment, converted):
        """

        Splits string and/or appends to new string

        """
     
        if len(segment) > 0:
            if segment.startswith('gap'):
                print('skipping node:' + segment)
                segment = ''
            else:
                if '_' in segment:
                    split = segment.split('_')
                    converted.append(split[0])
                    #print('segment=',split[0])
                else:
                    converted.append(segment)
                    #print('segment as is=',segment)
                segment = ''
        #else:
            #print('segment = 0')

        return segment, converted

    converted = []
    segment = ''
    path_len = len(path_str)
    skip = False
    removecomma = False
    for index, character in enumerate(path_str):
        #print('index=',index)
        #print('character=',character)
        if character == '<':
            #print('less than')
            segment, converted = format_string(segment, converted) 
            
        if character == '>':
            #print('greater than')
            segment, converted = format_string(segment, converted)

        if character != '<' and character != '>':
            if character == '[':
                #print('start of gap')
                skip = True
            elif character == ']':
                #print('end of gap')
                skip = False
                removecomma = True
            else:
                #print('+/- are being used')
                if skip:
                    #print('skipping gap')
                    continue
                else:
                    #not a gap
                    if removecomma:
                        #do not add comma after gap
                        removecomma = False
                    else:
                        #print('adding ' + character)
                        segment += character
                
                    #last node
                    if index+1 == path_len:
                        #print('last')
                        segment, converted = format_string(segment, converted)
    
            
    return ','.join(converted)

#can also be used on command line by feeding in the node path
input_path = sys.argv[1]

if input_path.startswith('/') or input_path.endswith('.txt.'):
    with open(input_path, 'r') as file:
        for line in file:
            line = line.strip()
            output_path = convert_verkko_path(line)
            print('\nConverted path:\n',output_path)
else:
    output_path = convert_verkko_path(input_path)
    print('\nConverted path:\n',output_path)

