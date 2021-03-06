import os
import sys
import pickle
import re
pattern = re.compile(r'\t(ctxt|line) "(.*)"')


def get_path(tree, character):
    output = []
    if isinstance(tree, bytes):
        tree = tree.decode('utf-8')
    if isinstance(tree, list):
        left = get_path(tree[0], character)
        if left is not None:
            return [0] + left
        right = get_path(tree[1], character)
        if right is not None:
            return [1] + right
    elif tree == character:
        return []


def write_paths(outstream, paths):
    cur_byte = 0
    cur_mask = 0x80
    outbytes = [[]]
    for bit in paths:
        cur_byte |= cur_mask * bit
        cur_mask >>= 1
        if not cur_mask:
            cur_mask = 0x80
            outbytes[-1].append(cur_byte)
            if len(outbytes[-1]) == 16:
                outbytes.append([])
            cur_byte = 0
    for row in outbytes:
        if row:
            out = ', '.join(map('${:02x}'.format, row))
            outstream.write('\tdb ' + out + '\n')


def textcomp(filename):
    kata = True
    instream = open(filename, 'r')
    outstream = open(os.path.splitext(filename)[0] + '.ctf', 'w')
    paths = []
    tree = []
    for line in instream.readlines():
        if line.startswith('\ttree "'):
            treefname = line[7:-2]
            tree = pickle.load(open(treefname, 'rb'))
            ctrlhira = get_path(tree, '<HIRA>') or get_path(tree, '(')
            ctrlkata = get_path(tree, '<KATA>') or get_path(tree, ')')
            ctrlterm = get_path(tree, '<TERM>')
            ctrlline = get_path(tree, '<NL>')
            ctrlplater = get_path(tree, '<PLAYER>')
            ctrldaku = get_path(tree, 'ﾞ')
            ctrlhand = get_path(tree, 'ﾟ')
            continue
        M = pattern.match(line)
        if M:
            opcode, characters = M.groups()
            characters = list(characters)
            # Resolve control characters
            while '<' in characters:
                start = characters.index('<')
                end = characters.index('>') + 1
                characters = characters[:start] + \
                        [''.join(characters[start:end])] + characters[end:]
            # <NL>
            if opcode == 'line':
                paths += ctrlline
            # Signal text start
            elif opcode == 'ctxt':
                if paths:
                    write_paths(outstream, paths)
                    paths = []
                kata = True
            for character in characters:
                if len(character) == 1:
                    value = ord(character)
                    if value in range(0x30a0, 0x30f8):
                        value -= 0x60
                        character = chr(value)
                        if not kata:
                            paths += ctrlkata
                            kata = True
                    elif value in range(0x3040, 0x3098):
                        if kata:
                            paths += ctrlhira
                            kata = False
                elif character == '<PLAYER>' and not kata:
                    paths += ctrlkata
                    kata = True
                # elif character == '<KATA>':
                    # kata = True
                # elif character == '<HIRA>':
                    # kata = False
                path = get_path(tree, character)
                if path:
                    paths += path
                elif len(character) > 1:
                    raise ValueError('invalid character:', character)
                elif value < 0x3040:
                    raise ValueError('invalid character:', character)
                else:
                    path = get_path(tree, chr(value - 1))
                    if path:
                        paths += path
                        paths += ctrldaku
                    else:
                        path = get_path(tree, chr(value - 2))
                        if not path:
                            raise ValueError('invalid character:', character)
                        paths += path
                        paths += ctrlhand
        # Signal text end
        elif line.startswith('\tdone'):
            if not kata:
                paths += ctrlkata
                kata = True
            paths += ctrlterm
            if '%' in line:
                paths += list(map(int, line.split('%')[1].strip()))
            write_paths(outstream, paths)
            paths = []
        else:
            if paths:
                write_paths(outstream, paths)
                paths = []
            outstream.write(line)

if __name__ == '__main__':
    for filename in sys.argv[1:]:
        textcomp(filename)

