import re

regDictionary = {
    'zero': 0,
    'at': 1,
    'v0': 2,
    'v1': 3,
    'a0': 4,
    'a1': 5,
    'a2': 6,
    'a3': 7,
    't0': 8,
    't1': 9,
    't2': 10,
    't3': 11,
    't4': 12,
    't5': 13,
    't6': 14,
    't7': 15,
    's0': 16,
    's1': 17,
    's2': 18,
    's3': 19,
    's4': 20,
    's5': 21,
    's6': 22,
    's7': 23,
    't8': 24,
    't9': 25,
    'k0': 26,
    'k1': 27,
    'gp': 28,
    'sp': 29,
    'fp': 30,
    'ra': 31,

}


def readFile(Path):
    File = open(Path, 'r')
    String = File.readlines()
    File.close()
    return String


def printFile(Text):
    for line in Text:
        print(line)


def instructionType(Instruction):
    if Instruction == 'add':
        Type = 'r'
        Opcode = 0
        Funct = 0x20

    elif Instruction == 'and':
        Type = 'r'
        Opcode = 0
        Funct = 0x24

    elif Instruction == 'beq':
        Type = 'i'
        Opcode = 0x4
        Funct = None

    elif Instruction == 'j':
        Type = 'j'
        Opcode = 0x2
        Funct = None

    elif Instruction == 'lw':
        Type = 'i'
        Opcode = 0x23
        Funct = None

    elif Instruction == 'or':
        Type = 'r'
        Opcode = 0
        Funct = 0x25

    elif Instruction == 'slt':
        Type = 'r'
        Opcode = 0
        Funct = 0x2a

    elif Instruction == 'sw':
        Type = 'i'
        Opcode = 0x2b
        Funct = None

    elif Instruction == 'sub':
        Type = 'r'
        Opcode = 0
        Funct = 0x22

    else:
        Type = None
        Opcode = None
        Funct = None

    return [Type, Opcode, Funct]


def transformReg(Type, Instruction, Register):
    global imm
    if Type == 'r':
        if Instruction == 'add' or Instruction == 'sub' or Instruction == 'and' or Instruction == 'or' or Instruction == 'slt':
            return [regDictionary[Register[1]], regDictionary[Register[2]], regDictionary[Register[0]], 0]
        else:
            return None
    elif Type == 'i':
        if Instruction == 'lw' or Instruction == 'sw':
            if int(Register[1]) >= 0:
                imm = int(Register[1])

            return [regDictionary[Register[2]], regDictionary[Register[0]], imm]
        elif Instruction == 'beq':
            if int(Register[2]) >= 0:
                imm = int(Register[2])
            return [regDictionary[Register[1]], regDictionary[Register[0]], imm]
        else:
            return None

    elif Type == 'j':
        if Instruction == 'j':
            if int(Register[0]) >= 0:
                imm = int(Register[0])

        return [imm]


if __name__ == '__main__':

    TextFile_new = []
    File = open('Output.txt', 'w')

    # Searching characters
    SpecialCharacters = [',', '(', ')', '$']
    Pattern = '[' + ''.join(SpecialCharacters) + ']'

    # Reading from file

    TextFile_old = readFile('Notepad.txt')

    # Printing the text from file
    print('Printing original text: \n')
    printFile(TextFile_old)

    # Removing special characters
    for line in TextFile_old:
        TextFile_new.append(re.sub(Pattern, ' ', line))

    print('Printing modified text: \n')
    printFile(TextFile_new)

    for line in TextFile_new:  # Each line will have the instruction
        Temp = line.split();
        Instruction_Code = instructionType(Temp[0])  # Type, Opcode, Function
        Registers = transformReg(Instruction_Code[0], Temp[0], Temp[1:4])
        if Instruction_Code[0] == 'r':
            opcode = '{0:06b}'.format(Instruction_Code[1])
            rs = '{0:05b}'.format(Registers[0])
            rt = '{0:05b}'.format(Registers[1])
            rd = '{0:05b}'.format(Registers[2])
            shamt = '{0:05b}'.format(Registers[3])
            funct = '{0:06b}'.format(Instruction_Code[2])
            print('INSTRUCTION : ' + line)
            print('Instruction form: opcode | rs | rt | rd | shamt | funct' + '\n')
            print('Formatted binary: ' + opcode + '|' + rs + '|' + rt + '|' + rd + '|' + shamt + '|' + funct + '\n')
            binary = '0b' + opcode + rs + rt + rd + shamt + funct
            print('Binary:           ' + binary + '\n')
            hex_string = '{0:08x}'.format(int(binary, base=2))
            print('Hex:              0x' + hex_string + '\n')
            for Index in range(0, len(hex_string) - 1, 2):
                File.write(hex_string[Index] + hex_string[Index + 1] + '\n')
            File.write('\n')
        elif Instruction_Code[0] == 'i':
            opcode = '{0:06b}'.format(Instruction_Code[1])
            rs = '{0:05b}'.format(Registers[0])
            rt = '{0:05b}'.format(Registers[1])
            imm = '{0:016b}'.format(Registers[2])
            print('INSTRUCTION : ' + line)
            print('Instruction form: opcode | rs | rt | immediate' + '\n')
            print('Formatted binary: ' + opcode + '|' + rs + '|' + rt + '|' + imm + '\n')
            binary = '0b' + opcode + rs + rt + imm
            print('Binary:           ' + binary + '\n')
            hex_string = '{0:08x}'.format(int(binary, base=2))
            print('Hex:              0x' + hex_string + '\n')
            for Index in range(0, len(hex_string) - 1, 2):
                File.write(hex_string[Index] + hex_string[Index + 1] + '\n')
            File.write('\n')
        elif Instruction_Code[0] == 'j':
            opcode = '{0:06b}'.format(Instruction_Code[1])
            imm = '{0:026b}'.format(Registers[0])
            print('INSTRUCTION : ' + line)
            print('Instruction form: opcode | immediate ' + '\n')
            print('Formatted binary: ' + opcode + '|' + imm + '\n')
            binary = '0b' + opcode + imm
            print('Binary:           ' + binary + '\n')
            hex_string = '{0:08x}'.format(int(binary, base=2))
            print('Hex:              0x' + hex_string + '\n')
            for Index in range(0, len(hex_string) - 1, 2):
                File.write(hex_string[Index] + hex_string[Index + 1] + '\n')
            File.write('\n')

    File.close()