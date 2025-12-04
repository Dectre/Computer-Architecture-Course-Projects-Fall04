import re
import sys

REGS = {f"x{i}": i for i in range(32)}


def parse_reg(tok):
    tok = tok.strip()
    if tok not in REGS:
        raise ValueError(f"Unknown register: {tok}")
    return REGS[tok]


def parse_imm(tok):
    tok = tok.strip()
    base = 10
    if tok.startswith("0x") or tok.startswith("0X"):
        base = 16
    return int(tok, base)


def enc_R(funct7, funct3, opcode, rd, rs1, rs2):
    return ((funct7 & 0x7F) << 25) | ((rs2 & 0x1F) << 20) | \
           ((rs1 & 0x1F) << 15) | ((funct3 & 0x7) << 12) | \
           ((rd & 0x1F) << 7) | (opcode & 0x7F)


def enc_I(funct3, opcode, rd, rs1, imm):
    imm &= 0xFFF
    return (imm << 20) | ((rs1 & 0x1F) << 15) | \
           ((funct3 & 0x7) << 12) | ((rd & 0x1F) << 7) | (opcode & 0x7F)


def enc_S(funct3, opcode, rs1, rs2, imm):
    imm &= 0xFFF
    imm_low = imm & 0x1F
    imm_high = (imm >> 5) & 0x7F
    return (imm_high << 25) | ((rs2 & 0x1F) << 20) | \
           ((rs1 & 0x1F) << 15) | ((funct3 & 0x7) << 12) | \
           (imm_low << 7) | (opcode & 0x7F)


def enc_B(funct3, opcode, rs1, rs2, offset_bytes):
    off = offset_bytes & 0x1FFF  # 13-bit signed offset in BYTES

    bit12  = (off >> 12) & 1
    bit11  = (off >> 11) & 1
    bits10_5 = (off >> 5) & 0x3F
    bits4_1  = (off >> 1) & 0x0F

    return (bit12 << 31) | (bits10_5 << 25) | ((rs2 & 0x1F) << 20) | \
           ((rs1 & 0x1F) << 15) | ((funct3 & 0x7) << 12) | \
           (bits4_1 << 8) | (bit11 << 7) | (opcode & 0x7F)



def enc_J(opcode, rd, offset_bytes):
    imm = offset_bytes & 0x1FFFFF

    b20    = (imm >> 20) & 1
    b10_1  = (imm >> 1) & 0x3FF
    b11    = (imm >> 11) & 1
    b19_12 = (imm >> 12) & 0xFF

    return (b20 << 31) | (b10_1 << 21) | (b11 << 20) | \
           (b19_12 << 12) | ((rd & 0x1F) << 7) | (opcode & 0x7F)



def enc_U(opcode, rd, imm):
    imm &= 0xFFFFF
    return (imm << 12) | ((rd & 0x1F) << 7) | (opcode & 0x7F)


def assemble(text):
    raw_lines = []
    for line in text.splitlines():
        line = line.split('#')[0]
        line = line.split('//')[0]
        if line.strip():
            raw_lines.append(line.strip())

    labels = {}
    insts = []
    pc = 0
    for line in raw_lines:
        if ':' in line:
            label, rest = line.split(':', 1)
            label = label.strip()
            labels[label] = pc
            rest = rest.strip()
            if rest:
                insts.append((pc, rest))
                pc += 4
        else:
            insts.append((pc, line))
            pc += 4

    code = []
    for pc, line in insts:
        parts = re.split(r'[,\s]+', line.strip())
        parts = [p for p in parts if p]
        if not parts:
            continue

        mnem = parts[0].lower()

        if mnem in ('add', 'sub', 'and', 'or', 'slt'):
            rd = parse_reg(parts[1])
            rs1 = parse_reg(parts[2])
            rs2 = parse_reg(parts[3])
            opcode = 0b0110011
            if mnem == 'add':
                funct3, funct7 = 0b000, 0b0000000
            elif mnem == 'sub':
                funct3, funct7 = 0b000, 0b0100000
            elif mnem == 'and':
                funct3, funct7 = 0b111, 0b0000000
            elif mnem == 'or':
                funct3, funct7 = 0b110, 0b0000000
            else:
                funct3, funct7 = 0b010, 0b0000000
            inst = enc_R(funct7, funct3, opcode, rd, rs1, rs2)

        elif mnem in ('addi', 'xori', 'ori', 'slti'):
            rd = parse_reg(parts[1])
            rs1 = parse_reg(parts[2])
            imm = parse_imm(parts[3])
            opcode = 0b0010011
            if mnem == 'addi':
                funct3 = 0b000
            elif mnem == 'xori':
                funct3 = 0b100
            elif mnem == 'ori':
                funct3 = 0b110
            else:
                funct3 = 0b010
            inst = enc_I(funct3, opcode, rd, rs1, imm)

        elif mnem == 'lw':
            rd = parse_reg(parts[1])
            m = re.match(r'(-?\d+|0x[0-9a-fA-F]+)\((x\d+)\)', parts[2])
            if not m:
                raise ValueError(f"Bad lw address: {parts[2]}")
            imm = parse_imm(m.group(1))
            rs1 = parse_reg(m.group(2))
            opcode, funct3 = 0b0000011, 0b010
            inst = enc_I(funct3, opcode, rd, rs1, imm)

        elif mnem == 'sw':
            rs2 = parse_reg(parts[1])
            m = re.match(r'(-?\d+|0x[0-9a-fA-F]+)\((x\d+)\)', parts[2])
            if not m:
                raise ValueError(f"Bad sw address: {parts[2]}")
            imm = parse_imm(m.group(1))
            rs1 = parse_reg(m.group(2))
            opcode, funct3 = 0b0100011, 0b010
            inst = enc_S(funct3, opcode, rs1, rs2, imm)

        elif mnem in ('beq', 'bne'):
            rs1 = parse_reg(parts[1])
            rs2 = parse_reg(parts[2])
            label = parts[3]
            if label not in labels:
                raise ValueError(f"Unknown label: {label}")
            target = labels[label]
            offset = target - pc
            opcode = 0b1100011
            funct3 = 0b000 if mnem == 'beq' else 0b001
            inst = enc_B(funct3, opcode, rs1, rs2, offset)

        elif mnem == 'jal':
            if len(parts) == 3:
                rd = parse_reg(parts[1])
                label = parts[2]
            else:
                rd = 1
                label = parts[1]
            if label not in labels:
                raise ValueError(f"Unknown label: {label}")
            target = labels[label]
            offset = target - pc
            opcode = 0b1101111
            inst = enc_J(opcode, rd, offset)

        elif mnem == 'jalr':
            rd = parse_reg(parts[1])
            m = re.match(r'(-?\d+|0x[0-9a-fA-F]+)\((x\d+)\)', parts[2])
            if not m:
                raise ValueError(f"Bad jalr address: {parts[2]}")
            imm = parse_imm(m.group(1))
            rs1 = parse_reg(m.group(2))
            opcode, funct3 = 0b1100111, 0b000
            inst = enc_I(funct3, opcode, rd, rs1, imm)

        elif mnem == 'lui':
            rd = parse_reg(parts[1])
            imm = parse_imm(parts[2])
            opcode = 0b0110111
            inst = enc_U(opcode, rd, imm)

        else:
            raise ValueError(f"Unknown mnemonic: {mnem}")

        code.append(inst)

    return code, labels


def main():
    INPUT_FILE = "Assembly/sort.s"
    OUTPUT_FILE = "instructions.mem"

    with open(INPUT_FILE, "r") as f:
        text = f.read()

    code, labels = assemble(text)

    with open(OUTPUT_FILE, "w") as out:
        for w in code:
            out.write(f"{w:08x}\n")


if __name__ == "__main__":
    main()
