# CA2: Single-Cycle RISC-V (RV32I) Processor — Hardware Implementation ⚙️🚀

A fully structural, single-cycle **RV32I RISC-V** 32-bit processor core implemented in **SystemVerilog**, featuring complete datapath-control unit integration, custom toolchain (assembler & memory generator), and verified via execution of a **Bubble Sort** program on 20 signed integers.

> 👤 **Authors:** Amirali Dehghani (`810102443`) · Nazhin Nikkhahbahrami (`810102530`)  
> 🎓 **Course:** Computer Architecture — Fall 1404 (2025–2026)  
> 🏫 **University:** University of Tehran  
> 📄 **Hardware Datapath & Control Report Reference:** [ComputerArchitecture-CA2-810102443-810102530.pdf](ComputerArchitecture-CA2-810102443-810102530.pdf)  
> 📋 **Assignment Specification:** [CA#02.pdf](CA%2302.pdf)

---

## 📑 Table of Contents

- [CA2: Single-Cycle RISC-V (RV32I) Processor — Hardware Implementation ⚙️🚀](#ca2-single-cycle-risc-v-rv32i-processor--hardware-implementation-️)
  - [📑 Table of Contents](#-table-of-contents)
  - [📖 Overview \& Processor Core Details](#-overview--processor-core-details)
    - [Core Features](#core-features)
  - [🎯 Instruction Set Architecture (ISA) \& Encoding](#-instruction-set-architecture-isa--encoding)
  - [🏗️ Hardware System Architecture](#️-hardware-system-architecture)
    - [Top-Level Interface](#top-level-interface)
    - [Full Processor Datapath Schematic](#full-processor-datapath-schematic)
  - [🗜️ Datapath Component Specifications](#️-datapath-component-specifications)
    - [Module Hierarchy Table](#module-hierarchy-table)
    - [Register File Architecture](#register-file-architecture)
    - [Immediate Extension Unit](#immediate-extension-unit)
    - [32-bit Arithmetic Logic Unit (ALU)](#32-bit-arithmetic-logic-unit-alu)
  - [🕹️ Control Unit Design](#️-control-unit-design)
    - [Control Signals Decoder Matrix](#control-signals-decoder-matrix)
    - [Control Signal Definitions](#control-signal-definitions)
  - [💻 Software \& Custom Toolchain Pipeline](#-software--custom-toolchain-pipeline)
    - [Bubble Sort C Reference Implementation](#bubble-sort-c-reference-implementation)
    - [Hand-Crafted RISC-V Assembly Program](#hand-crafted-risc-v-assembly-program)
    - [Custom Python Assembler (`assembly_to_machine.py`)](#custom-python-assembler-assembly_to_machinepy)
  - [🧪 Simulation \& Verification](#-simulation--verification)
    - [Testbench Setup](#testbench-setup)
    - [Data Memory State: Input vs. Sorted Output](#data-memory-state-input-vs-sorted-output)
      - [Initial Data Memory (`data.mem`)](#initial-data-memory-datamem)
      - [Final Sorted Data Memory (Simulation Waveform Result)](#final-sorted-data-memory-simulation-waveform-result)
  - [📐 Compliance with Design Guidelines](#-compliance-with-design-guidelines)
  - [📂 Directory Structure](#-directory-structure)

---

## 📖 Overview & Processor Core Details

The **Single-Cycle RISC-V Processor** is a classic Harvard-architecture implementation of the 32-bit RISC-V base integer instruction set (RV32I). In a single-cycle design, the execution of every instruction — including instruction fetch, decode, operand fetch, ALU execution, memory access, and write-back — occurs entirely within **one single clock cycle**.

### Core Features

- **Single-Cycle Execution:** $CPI = 1.0$ across all instruction types.
- **Support for 16 Instructions:** Covers R-type, I-type, S-type, B-type, J-type, and U-type formats.
- **Word-Addressed Memory Interface:** Memory units use word-aligned addressing ($A[31:2]$) for 32-bit access.
- **Dedicated Register $x0$ Guard:** Register `x0` is hardwired to zero, preventing accidental writes.
- **Custom Toolchain:** Self-contained assembler written in Python translates assembly directly to machine code hex files (`instructions.mem`), while a data-generator prepares memory initialization files (`data.mem`).

---

## 🎯 Instruction Set Architecture (ISA) & Encoding

The core supports **16 essential instructions** from the RV32I instruction set:

| Instruction | Type | Opcode (`op`) | `funct3` | `funct7` / Imm Format | Operation Summary |
|---|---|---|---|---|---|
| `add` | R-Type | `0110011` | `000` | `0000000` | $rd = rs1 + rs2$ |
| `sub` | R-Type | `0110011` | `000` | `0100000` | $rd = rs1 - rs2$ |
| `and` | R-Type | `0110011` | `111` | `0000000` | $rd = rs1 \ \& \ rs2$ |
| `or` | R-Type | `0110011` | `110` | `0000000` | $rd = rs1 \ \| \ rs2$ |
| `slt` | R-Type | `0110011` | `010` | `0000000` | $rd = (rs1 < rs2) \ ? \ 1 : 0$ |
| `addi` | I-Type | `0010011` | `000` | I-Immediate | $rd = rs1 + \text{Imm}$ |
| `xori` | I-Type | `0010011` | `100` | I-Immediate | $rd = rs1 \oplus \text{Imm}$ |
| `ori` | I-Type | `0010011` | `110` | I-Immediate | $rd = rs1 \ \| \ \text{Imm}$ |
| `slti` | I-Type | `0010011` | `010` | I-Immediate | $rd = (rs1 < \text{Imm}) \ ? \ 1 : 0$ |
| `lw` | I-Type | `0000011` | `010` | I-Immediate | $rd = \text{DataMem}[rs1 + \text{Imm}]$ |
| `jalr` | I-Type | `1100111` | `000` | I-Immediate | $rd = PC + 4; \ PC = (rs1 + \text{Imm})$ |
| `sw` | S-Type | `0100011` | `010` | S-Immediate | $\text{DataMem}[rs1 + \text{Imm}] = rs2$ |
| `beq` | B-Type | `1100011` | `000` | B-Immediate | $\text{if } (rs1 == rs2) \ PC = PC + \text{Imm}$ |
| `bne` | B-Type | `1100011` | `001` | B-Immediate | $\text{if } (rs1 \neq rs2) \ PC = PC + \text{Imm}$ |
| `jal` | J-Type | `1101111` | — | J-Immediate | $rd = PC + 4; \ PC = PC + \text{Imm}$ |
| `lui` | U-Type | `0110111` | — | U-Immediate | $rd = \text{Imm} \ll 12$ |

---

## 🏗️ Hardware System Architecture

### Top-Level Interface

The top-level module [RiscV.sv](RiscV.sv) orchestrates the communication between the [Datapath.sv](Datapath.sv) and [ControlUnit.sv](ControlUnit.sv):

```
                       ┌─────────────────────────────────────────┐
                       │            RiscV (Top Module)           │
                       │                                         │
  clk ────────────────►│   ┌──────────────┐    ┌─────────────┐   │
  rst ────────────────►│   │              │    │             │   │
                       │   │ ControlUnit  │◄───│  Datapath   │   │
                       │   │              │───►│             │   │
                       │   └──────┬───────┘    └─────────────┘   │
                       │          │                              │
                       └──────────┼──────────────────────────────┘
                                  ▼
                                Ready
```

---

### Full Processor Datapath Schematic

The hardware structure implemented in [Datapath.sv](Datapath.sv) and illustrated in Page 1 of [ComputerArchitecture-CA2-810102443-810102530.pdf](ComputerArchitecture-CA2-810102443-810102530.pdf) is detailed below:

<p align="center">
  <img src="datapath_diagram.png" alt="Single-Cycle RISC-V Datapath Diagram" width="800"/>
</p>

---

## 🗜️ Datapath Component Specifications

### Module Hierarchy Table

| Module Name | File | Description & Sub-components |
|---|---|---|
| `RiscV` | [RiscV.sv](RiscV.sv) | Top-level entity instantiating Datapath and ControlUnit |
| `Datapath` | [Datapath.sv](Datapath.sv) | Interconnects PC, IM, RF, ALU, DM, ImmExtend, Adders, MUXes |
| `ControlUnit` | [ControlUnit.sv](ControlUnit.sv) | Combinational decoder generating 7 main control signals |
| `Register_32` | [register.sv](register.sv) | 32-bit D-register used as Program Counter (PC) |
| `InstructionMemory` | [InstructionMemory.sv](InstructionMemory.sv) | 8192-word ROM, loaded from `instructions.mem` |
| `Adder_32` | [Adder.sv](Adder.sv) | 32-bit signed adder for PC+4 and PC+Imm calculations |
| `RegisterFile` | [RegisterFile.sv](RegisterFile.sv) | 32 $\times$ 32-bit multi-port register file ($x0$ hardwired to 0) |
| `ImmediateExtend` | [ImmediateExtend.sv](ImmediateExtend.sv) | Sign-extension logic for I, S, B, J, and U instruction types |
| `ALU` | [ALU.sv](ALU.sv) | 32-bit multi-function arithmetic logic unit |
| `DataMemory` | [DataMemory.sv](DataMemory.sv) | 8192-word RAM, reloads from `data.mem` on reset |
| `Mux_4to1_32` | [Mux.sv](Mux.sv) | 4-channel 32-bit multiplexer for PC select & Write-Back select |
| `Mux_2to1_32` | [Mux.sv](Mux.sv) | 2-channel 32-bit multiplexer for ALU input B selection |

---

### Register File Architecture

The Register File ([RegisterFile.sv](RegisterFile.sv)) provides dual asynchronous read ports (`RD1`, `RD2`) and a single synchronous write port (`WD3`):

- **Asynchronous Read:** Outputs `RD1 = registers[A1]` and `RD2 = registers[A2]` instantly.
- **Synchronous Write:** Writes on `posedge clk` when `WE3 == 1`.
- **Zero Register Lock:** Writing to register `x0` (`A3 == 5'd0`) is explicitly blocked (`A3 != 5'd0`), ensuring `x0` remains constant `32'b0`.

---

### Immediate Extension Unit

The Immediate Extension Unit ([ImmediateExtend.sv](ImmediateExtend.sv)) constructs sign-extended 32-bit immediates based on `ImmSrc`:

| `ImmSrc` | Format | Bit-Slicing & Sign-Extension Logic |
|---|---|---|
| `3'b000` | **I-Type** | `{{20{immediate[31]}}, immediate[31:20]}` |
| `3'b001` | **S-Type** | `{{20{immediate[31]}}, immediate[31:25], immediate[11:7]}` |
| `3'b010` | **B-Type** | `{{20{immediate[31]}}, immediate[7], immediate[30:25], immediate[11:8], 1'b0}` |
| `3'b011` | **J-Type** | `{{12{immediate[31]}}, immediate[19:12], immediate[20], immediate[30:21], 1'b0}` |
| `3'b100` | **U-Type** | `{immediate[31:12], 12'b00}` |

---

### 32-bit Arithmetic Logic Unit (ALU)

The ALU ([ALU.sv](ALU.sv)) executes arithmetic and logical operations controlled by `ALUControl`:

| `ALUControl` | Code Name | Operation | Description |
|---|---|---|---|
| `3'b000` | `ALU_ADD` | $A + B$ | Signed 32-bit Addition |
| `3'b001` | `ALU_SUB` | $A - B$ | Signed 32-bit Subtraction |
| `3'b010` | `ALU_AND` | $A \ \& \ B$ | Bitwise AND |
| `3'b011` | `ALU_OR` | $A \ \| \ B$ | Bitwise OR |
| `3'b100` | `ALU_XOR` | $A \oplus B$ | Bitwise XOR |
| `3'b101` | `ALU_SLT` | $(A < B) \ ? \ 1 : 0$ | Set Less Than (signed comparison) |

- **Zero Flag Output:** Asserted (`zero = 1`) whenever `result == 0`.

---

## 🕹️ Control Unit Design

### Control Signals Decoder Matrix

The Control Unit ([ControlUnit.sv](ControlUnit.sv)) decodes instruction opcodes and function fields to generate all processor control signals:

| Instr | Format | `op` | `funct3` | `funct7` | `ImmSrc` | `ALUSrc` | `ResultSrc` | `PCSrc` | `MemWrite` | `RegWrite` | `ALUControl` |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `add` | R-Type | `0110011` | `000` | `0000000` | — | `0` | `00` | `00` | `0` | `1` | `000` (`ADD`) |
| `sub` | R-Type | `0110011` | `000` | `0100000` | — | `0` | `00` | `00` | `0` | `1` | `001` (`SUB`) |
| `and` | R-Type | `0110011` | `111` | `0000000` | — | `0` | `00` | `00` | `0` | `1` | `010` (`AND`) |
| `or` | R-Type | `0110011` | `110` | `0000000` | — | `0` | `00` | `00` | `0` | `1` | `011` (`OR`) |
| `slt` | R-Type | `0110011` | `010` | `0000000` | — | `0` | `00` | `00` | `0` | `1` | `101` (`SLT`) |
| `addi` | I-Type | `0010011` | `000` | — | `000` (I) | `1` | `00` | `00` | `0` | `1` | `000` (`ADD`) |
| `xori` | I-Type | `0010011` | `100` | — | `000` (I) | `1` | `00` | `00` | `0` | `1` | `100` (`XOR`) |
| `ori` | I-Type | `0010011` | `110` | — | `000` (I) | `1` | `00` | `00` | `0` | `1` | `011` (`OR`) |
| `slti` | I-Type | `0010011` | `010` | — | `000` (I) | `1` | `00` | `00` | `0` | `1` | `101` (`SLT`) |
| `lw` | I-Type | `0000011` | `010` | — | `000` (I) | `1` | `01` | `00` | `0` | `1` | `000` (`ADD`) |
| `jalr` | I-Type | `1100111` | `000` | — | `000` (I) | `1` | `10` | `10` | `0` | `1` | `000` (`ADD`) |
| `sw` | S-Type | `0100011` | `010` | — | `001` (S) | `1` | `00` | `00` | `1` | `0` | `000` (`ADD`) |
| `beq` | B-Type | `1100011` | `000` | — | `010` (B) | `0` | `00` | `Zero?01:00` | `0` | `0` | `001` (`SUB`) |
| `bne` | B-Type | `1100011` | `001` | — | `010` (B) | `0` | `00` | `!Zero?01:00` | `0` | `0` | `001` (`SUB`) |
| `jal` | J-Type | `1101111` | — | — | `011` (J) | `0` | `10` | `01` | `0` | `1` | `000` (`ADD`) |
| `lui` | U-Type | `0110111` | — | — | `100` (U) | `1` | `00` | `00` | `0` | `1` | `000` (`ADD`) |

---

### Control Signal Definitions

- `PCSrc`: Selects PC source (`00` = PC+4, `01` = Target `PC+ImmExt`, `10` = `ALUResult` for `jalr`).
- `ResultSrc`: Selects Write-Back data to Register File (`00` = ALU, `01` = Memory, `10` = `PC+4`, `11` = `PC`).
- `MemWrite`: Asserts memory write enable for `sw`.
- `ALUSrc`: Selects ALU B operand (`0` = Register `RD2`, `1` = `ImmExt`).
- `RegWrite`: Asserts register file write enable.
- `Ready`: Asserts high when an unhandled opcode is reached (signals simulation termination).

---

## 💻 Software & Custom Toolchain Pipeline

### Bubble Sort C Reference Implementation

Located in [Assembly/sort.c](Assembly/sort.c), sorting 20 signed integers:

```c
#include <stdint.h>
#define N 20

int32_t arr[N] = {
    12, -5, 33, 7, 0, 19, -12, 44, 8, -1,
    3, 27, 15, 2, -8, 6, 9, -3, 25, 1
};

int main() {
    for (int i = 0; i < N - 1; i++) {
        for (int j = 0; j < N - 1 - i; j++) {
            if (arr[j] > arr[j + 1]) {
                int32_t temp = arr[j];
                arr[j] = arr[j + 1];
                arr[j + 1] = temp;
            }
        }
    }
    return 0;
}
```

---

### Hand-Crafted RISC-V Assembly Program

Located in [Assembly/sort.s](Assembly/sort.s):

```assembly
    addi x1, x0, 0       # x1 = base array pointer (0)
    addi x2, x0, 0       # x2 = outer loop counter (i = 0)
    addi x8, x0, 20      # x8 = N = 20
    addi x4, x0, 19      # x4 = N-1 = 19
LOOP1:
    slt  x12, x2, x4     # x12 = (i < N-1) ? 1 : 0
    beq  x12, x0, DONE   # if i >= N-1 exit
    addi x3, x0, 0       # x3 = inner loop counter (j = 0)
    addi x7, x1, 0       # x7 = current element address &arr[j]
    sub  x9, x4, x2      # x9 = N-1-i (inner loop bound)
LOOP2:
    slt  x10, x3, x9     # x10 = (j < N-1-i) ? 1 : 0
    beq  x10, x0, END_LOOP2 # if j >= bound exit inner
    lw   x5, 0(x7)       # x5 = arr[j]
    lw   x6, 4(x7)       # x6 = arr[j+1]
    slt  x11, x6, x5     # x11 = (arr[j+1] < arr[j]) ? 1 : 0
    beq  x11, x0, NO_SWAP  # if arr[j] <= arr[j+1], skip swap
    sw   x6, 0(x7)       # arr[j] = arr[j+1]
    sw   x5, 4(x7)       # arr[j+1] = arr[j] (swap)
NO_SWAP:
    addi x3, x3, 1       # j++
    addi x7, x7, 4       # pointer += 4 (next word)
    jal  x0, LOOP2       # repeat inner loop
END_LOOP2:
    addi x2, x2, 1       # i++
    jal  x0, LOOP1       # repeat outer loop
DONE:
    # Program finished: hits default opcode to assert Ready
```

---

### Custom Python Assembler (`assembly_to_machine.py`)

The self-contained Python script [Assembly/assembly_to_machine.py](Assembly/assembly_to_machine.py) translates `.s` files into 32-bit hexadecimal machine code (`instructions.mem`):

```bash
# Execute Assembler
python Assembly/assembly_to_machine.py

# Generated Machine Code (instructions.mem):
00000093
00000113
01400413
01300213
00412633
04060263
00000193
...
```

---

## 🧪 Simulation & Verification

### Testbench Setup

The testbench [RiscV_TB.sv](RiscV_TB.sv) verifies processor execution:

```systemverilog
`timescale 1ns/1ns

module RiscV_TB();
    logic clk = 1'b0, rst = 1'b1;
    wire Ready;

    RiscV UUT(clk, rst, Ready);

    always #20 clk = ~clk;

    always @(posedge Ready) #10 $stop;
    initial #10 rst = 1'b0;
endmodule
```

---

### Data Memory State: Input vs. Sorted Output

As illustrated on Page 3 of [ComputerArchitecture-CA2-810102443-810102530.pdf](ComputerArchitecture-CA2-810102443-810102530.pdf), 20 signed integers are loaded into memory:

#### Initial Data Memory (`data.mem`)

```
Memory[0..9]  :  12,  -5,  33,   7,   0,  19, -12,  44,   8,  -1
Memory[10..19]:   3,  27,  15,   2,  -8,   6,   9,  -3,  25,   1
```

#### Final Sorted Data Memory (Simulation Waveform Result)

Upon completion when `Ready == 1`, memory dump confirms perfect ascending order:

```
Memory[0..9]  : -12,  -8,  -5,  -3,  -1,   0,   1,   2,   3,   6
Memory[10..19]:   7,   9,  12,  15,  19,  25,  27,  33,  44
```

> 🎯 **Result:** The array is completely sorted in memory, confirming correct execution of all R, I, S, B, and J instructions.

---

## 📐 Compliance with Design Guidelines

The implementation satisfies all guidelines from [CA#02.pdf](CA%2302.pdf):

1. **Single-Cycle RISC-V Architecture:** Complete instruction cycle executed in one clock period.
2. **RV32I Base Subset Support:** Complete support for 16 key instructions across all six format types (R, I, S, B, J, U).
3. **Word-Aligned Memory Access:** Addresses mapped using `A[31:2]`.
4. **Hardwired Zero Register ($x0$):** `x0` register write-protected.
5. **Structural & Combinational Design:** Modular SystemVerilog code with combinational Control Unit decoding.

---

## 📂 Directory Structure

```
CA2/
├── RiscV.sv                  # Top-level module (wires Datapath + ControlUnit)
├── Datapath.sv               # Structural Datapath module
├── ControlUnit.sv            # Combinational Control Unit decoder
├── ALU.sv                    # 32-bit Signed ALU
├── RegisterFile.sv           # 32x32-bit Register File (x0 hardwired to zero)
├── ImmediateExtend.sv        # Sign-extension logic for I/S/B/J/U immediates
├── InstructionMemory.sv      # 8192-word ROM (loads instructions.mem)
├── DataMemory.sv             # 8192-word RAM (loads data.mem on reset)
├── Mux.sv                    # 2-to-1 and 4-to-1 32-bit Multiplexers
├── Adder.sv                  # 32-bit Adder
├── register.sv               # 32-bit PC Register
├── RiscV_TB.sv               # Processor Testbench
├── instructions.mem          # Hex machine code (22 instructions)
├── data.mem                  # Hex data memory (20 signed integers)
├── Assembly/
│   ├── sort.c                # Reference C implementation of bubble sort
│   ├── sort.s                # Hand-crafted RISC-V assembly code
│   ├── assembly_to_machine.py  # Custom Python RISC-V Assembler
│   ├── make_data_mem.py      # Python script generating data.mem
│   └── array_of_integers.txt # Raw input array (20 signed integers)
├── CA#02.pdf                 # Project specification PDF
└── ComputerArchitecture-CA2-810102443-810102530.pdf  # Report PDF with datapath diagram & results
```

---

<div align="center">

**🎓 Computer Architecture Course — Fall 1404 (2025)**  
*Department of Electrical and Computer Engineering — University of Tehran*

</div>
