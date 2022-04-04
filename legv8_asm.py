#!/usr/bin/python3
import re
'''
    File: legv8_asm.py
    Description: A python script to generate machine code for a subset of ARM LEGv8 instructions
    Version: 2(Tested to work with: LDUR, STUR, ADD, SUB, ORR, AND, CBZ and B instructions)
    How to use:
    1. Run Python script (using Python3)
    2. Input instruction (example: ADD r5, r3, r2) or (example: LDUR x10 [x1, #10])
    3. See the C-interpretation, machine code in binary format and machine code in decimal format
    Developers: Warren Seto and Ralph Quinto

    Modify: Zehua Dong, SIGS, 2022.04.03
    Version: 3
    NOTE:
    1. Support some other instructions: LSL, BR, MUL, ADDI, SUBS, SUBI, SUBIS, BL, B.cond, CMP, MUL, MOV.
    2. Package this file into a function named as 'single_inst_parse()' in order to parse instructions in batch mode.
    3. This function is only allow you to use one space to separate each keyword, such as: 'ADD X1, X2, X3' but
        'ADD  X1,    X2, X3' is not allowed. Also you can ignore space between the two registers, such as:
        'ADD X1,X2,X3'. Besides, you can use a lowercase letter to name register, such as: 'ADD x1, x2, x3' but
        instruction name must be all uppercase. In fact, you can use other letters to name registers, such as
        'ADD, r1, x2, y3', or just ignore the register name(ADD 1,2,3), we dont really care it.
    4. Support XZR, SP, FP, LR registers, you can use it in anywhere, such as: 'ADD XZR, FP, SP'.
    5. Negative is not allowed, you cannot input 'ADDI X1, X2, #-3' or maybe 'B #-6'.
    6. Comment in your asm code is allowed now, such as: 'ADD X1, X2, X3 ;X1 = X2 + X3' or maybe "; This is a asm code" 
        on a separate line.
    7. '\n' is allowed in your instruction, such as: 'ADD X1, X2, X3\n', empty is also allowed.
    8. You can write 32 bits binary or 32 bits hexadecimal into your files by specify the 'bin', 'BIN' or 'hex', 'HEX'
        in single_inst_parse() func parameter 'base', such as: 'single_inst_parse(raw_instruction, 'bin')'.
    9. We dont support Label in your asm code.

    How to use:
    There are two ways to use: one is input a single instruction each time realized in single_inst_from_keyboard(),
      another is specify a file contained all your code realized in batch_process_insts(src_file, obj_file, 'BIN').
'''


def trans_inst(insts):
    i = 0
    for inst in insts:
        if inst == 'SP':
            insts[i] = inst.replace('SP', 'X28')
        elif inst == 'FP':
            insts[i] = inst.replace('FP', 'X29')
        elif inst == 'LR':
            insts[i] = inst.replace('LR', 'X30')
        elif inst == 'XZR':
            insts[i] = inst.replace('XZR', 'X31')
        elif inst == 'MOV':
            insts[i] = inst.replace('MOV', 'ADDI')
            insts.append('#0')
        elif inst == 'CMP':
            insts[i] = inst.replace('CMP', 'SUBS')
            insts.insert(1, 'X31')
        i = i + 1

    return insts


def single_inst_parse(raw_instruction, base):
    
    # Formatting the inputted string for parsing
    formatted_instruction = raw_instruction.replace(', ', ',').replace(' ', ',').replace(']', '')\
        .replace('[', '').replace('.', '.,')
    # Split input into list for parsing
    instruction_list = list(filter(None, formatted_instruction.split(',')))
    instruction_list = trans_inst(instruction_list)
    
    # One-to-one relationship between opcodes and their binary representation
    OPCODES = {
        'LDUR' : ['11111000010'],
        'STUR' : ['11111000000'],
        'ADD'  : ['10001011000', '+'],
        'SUB'  : ['11001011000', '-'],
        'MUL'  : ['10011011000', '*'],
        'ORR'  : ['10101010000', '|'],
        'AND'  : ['10001010000', '&'],
        'ADDI' : ['10010001000',  '+'],
        'ADDS' : ['10101011000', '+'],
        'ADDIS': ['10110001000',  '+'],
        'SUBI' : ['11010001000',  '-'],
        'SUBS' : ['11101011000', '-'],
        'SUBIS': ['11110001000',  '-'],
        'LSL'  : ['11010011011', '<<'],
        'LSR'  : ['11010011010', '>>'],
        'CBZ'  : ['10110100000'],
        'B'    : ['00010100000'],
        'BR'   : ['11010110000'],
        'BL'   : ['10010100000'],
        'B.'   : ['01010100000']
    }

    BCOND = {
        'EQ': ['00001', '=='],
        'NE': ['00010', '!='],
        'LT': ['01110', '<' ],
        'LE': ['00100', '<='],
        'GT': ['01111', '>' ],
        'GE': ['01101', '>='],
        'LO': ['00101', '<' ],
        'LS': ['01100', '<='],
        'HI': ['01011', '>' ],
        'HS': ['00011', '>=']
    }

    # [31:0] == [MSB:LSB]
    machine_code = OPCODES[instruction_list[0]][0]

    print('\n------- C Interpretation -------')

    if (instruction_list[0] == 'LDUR' or instruction_list[0] == 'STUR'): # D-Type
        # LDUR X10, [X9, #16]

        dt_address = 0 if len(instruction_list) < 4 else int(''.join(filter(str.isdigit, instruction_list[3])))

        op = '00'
        rn = int(''.join(filter(str.isdigit, instruction_list[2])))
        rt = int(''.join(filter(str.isdigit, instruction_list[1])))

        if (instruction_list[0] == 'LDUR'): # LDUR
            print('Register[' + str(rt) + '] = RAM[ Register[' + str(rn) + ']' +
                  ('' if len(instruction_list) < 4 else (' + ' + str(dt_address))) + ' ]')
        else: # STUR
            print('RAM[ Register[' + str(rn) + ']' +
                  ('' if len(instruction_list) < 4 else (' + ' + str(dt_address))) + ' ] = Register[' + str(rt) + ']')

        machine_code += str(bin(dt_address)[2:].zfill(9)) + op + str(bin(rn)[2:].zfill(5)) + str(bin(rt)[2:].zfill(5))

    elif (instruction_list[0] == 'ADD' or
            instruction_list[0] == 'SUB' or
            instruction_list[0] == 'MUL' or
            instruction_list[0] == 'ORR' or
            instruction_list[0] == 'AND' or
            instruction_list[0] == 'ADDS' or
            instruction_list[0] == 'SUBS'): # R-Type
        # ADDS X10, X9, X2

        rm = int(''.join(filter(str.isdigit, instruction_list[3])))
        shamt = '000000' # LSL and LSR support has not been added
        rn = int(''.join(filter(str.isdigit, instruction_list[2])))
        rd = int(''.join(filter(str.isdigit, instruction_list[1])))
        print('Register[' + str(rd) + '] = Register[' + str(rn) + '] '
              + OPCODES[instruction_list[0]][1] + ' Register[' + str(rm) + ']')

        machine_code += str(bin(rm)[2:].zfill(5)) + shamt + str(bin(rn)[2:].zfill(5)) + str(bin(rd)[2:].zfill(5))

    elif (instruction_list[0] == 'ADDI' or instruction_list[0] == 'SUBI' or
          instruction_list[0] == 'ADDIS' or instruction_list[0] == 'SUBIS'):  # I-Type
        # ADDI X2, X1, #2
        immediate = int(''.join(filter(str.isdigit, instruction_list[3])))
        rn = int(''.join(filter(str.isdigit, instruction_list[2])))
        rd = int(''.join(filter(str.isdigit, instruction_list[1])))
        print('Register[' + str(rd) + '] = Register[' + str(rn) + '] '
              + OPCODES[instruction_list[0]][1] + ' ' + str(immediate))

        machine_code += str(bin(immediate)[2:].zfill(11)) + str(bin(rn)[2:].zfill(5)) + str(bin(rd)[2:].zfill(5))

    elif (instruction_list[0] == 'LSL' or instruction_list[0] == 'LSR'): # LSL, LSR
        # LSL X10, X9, #3
        shamt = int(''.join(filter(str.isdigit, instruction_list[3])))
        rn = int(''.join(filter(str.isdigit, instruction_list[2])))
        rd = int(''.join(filter(str.isdigit, instruction_list[1])))
        print('Register[' + str(rd) + '] = Register[' + str(rn) + '] '
              + OPCODES[instruction_list[0]][1] + ' ' + str(shamt))

        machine_code += str(bin(shamt)[2:].zfill(11)) + str(bin(rn)[2:].zfill(5)) + str(bin(rd)[2:].zfill(5))

    elif (instruction_list[0] == 'BR'):
        # BR X30
        rd = int(''.join(filter(str.isdigit, instruction_list[1])))
        print('PC = ' + 'Register[' + str(rd) + ']')

        machine_code += str(bin(rd)[2:].zfill(21))

    elif (instruction_list[0] == 'B' or instruction_list[0] == 'BL'): # B-Type
        # BL 20

        br_address = int(''.join(filter(str.isdigit, instruction_list[1])))
        if(instruction_list[0] == 'B') :
            print('PC = PC + 1 + ' + str(br_address))
        else: # BL
            print('Register[30] = PC + 1' + ', PC = PC + 1 + ' + str(br_address))

        machine_code += str(bin(br_address)[2:].zfill(21))

    elif (instruction_list[0] == 'CBZ'): # CB-Type
        # CBZ X20, 20

        cond_br_address = int(''.join(filter(str.isdigit, instruction_list[2])))
        rt = int(''.join(filter(str.isdigit, instruction_list[1])))
        print('if ( Register[' + str(rt) + '] == 0 ) { PC = PC + 1 + ' + str(cond_br_address) + ' }')
        print('else { PC++ }')

        machine_code += str(bin(cond_br_address)[2:].zfill(16)) + str(bin(rt)[2:].zfill(5))

    elif (instruction_list[0] == 'B.'):  # CB-Type
        # B.LT 20

        cond_br_address = int(''.join(filter(str.isdigit, instruction_list[2])))
        rt = ''.join(BCOND[instruction_list[1]][0])
        print('if ( A ' + BCOND[instruction_list[1]][1] + ' B ) { PC = PC + 1 + ' + str(cond_br_address) + ' }')
        print('else { PC++ }')
    
        machine_code += str(bin(cond_br_address)[2:].zfill(16)) + rt
    
    
    else:
        raise RuntimeError('OPCODE (' + instruction_list[0] + ') not supported')
    
    # Output the machine code representation of the input
    print('\n------- Machine Code (' + str(len(machine_code)) + '-bits) -------')
    print('BINARY : ' + machine_code)
    print('HEX    : ' + str(hex(int(machine_code, 2)))[2:])
    print('')

    if base == 'bin' or 'BIN':
        return machine_code
    elif base == 'hex' or 'HEX':
        return str(hex(int(machine_code, 2)))[2:]


def read_inst(file):

    fp = open(file, 'r')
    lines = []
    for line in fp:
        # Remove comment
        line = line.replace('\n', '')
        tmp = re.sub(r"[ ]*[;]+[a-zA-Z0-9\W]*[\W]*", '', line)
        if tmp == '':
            pass
        else:
            lines.append(tmp)
    # print(lines)
    fp.close()

    return lines


# @param:
# file is the destination file to be written
# text is the content to be written
# base is the text base format which can be 'bin', 'BIN' or 'hex', 'HEX'
def write_file(file, text, base):
    fp = open(file, 'w')
    for s in text:
        fp.write(str(single_inst_parse(s, base)) + '\n')
    fp.close()


def single_inst_from_keyboard():
    raw_instruction = input('\nEnter an ARM LEGv8 Assembly Instruction: ')
    single_inst_parse(raw_instruction, 'bin')


def batch_process_insts(src_file, obj_file, base):
    insts = read_inst(src_file)
    write_file(obj_file, insts, base)


if __name__ == '__main__':

    # Get Instruction from keyboard and display
    # single_inst_from_keyboard()


    # Process instructions in batch mode
    src_file1 = './data/factorial/factorial.asm'
    obj_file1 = './data/factorial/inst_mem.txt'
    batch_process_insts(src_file1, obj_file1, 'HEX')

    src_file2 = './data/bubble_sort/bubble_sort.asm'
    obj_file2 = './data/bubble_sort/inst_mem.txt'
    batch_process_insts(src_file2, obj_file2, 'HEX')
