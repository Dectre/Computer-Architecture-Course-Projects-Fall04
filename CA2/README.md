# CA2: Single-Cycle RISC-V Processor ⚙️

A fully structural, **single-cycle RV32I RISC-V processor** implemented in SystemVerilog. The processor executes one instruction per clock cycle and is verified by running a **Bubble Sort** algorithm on an array of 20 signed integers loaded from data memory.

> **Authors:** Amirali Dehghani (`810102443`) · Nazhin Nikkhahbahrami (`810102530`)
>
> **Course:** Computer Architecture — Fall 1404 (2025)

---

## 📖 Overview

This project implements a **single-cycle RISC-V processor** supporting a subset of the **RV32I** base integer instruction set. In a single-cycle design, every instruction — from fetch to write-back — completes within exactly **one clock cycle**. The processor is tested by sorting a 20-element signed integer array using bubble sort, demonstrating correct execution of arithmetic, memory, branching, and jump instructions.

### Supported Instructions

| Type | Instructions | Opcode |
|---|---|---|
| **R-type** | `add`, `sub`, `and`, `or`, `slt` | `0110011` |
| **I-type (Arithmetic)** | `addi`, `xori`, `ori`, `slti` | `0010011` |
| **I-type (Load)** | `lw` | `0000011` |
| **I-type (JALR)** | `jalr` | `1100111` |
| **S-type (Store)** | `sw` | `0100011` |
| **B-type (Branch)** | `beq`, `bne` | `1100011` |
| **J-type (Jump)** | `jal` | `1101111` |
| **U-type (Upper Imm)** | `lui` | `0110111` |

---

## 🏗️ Architecture

The processor follows a classic **Controller–Datapath** decomposition. All instructions complete in a single clock cycle — no pipeline, no multi-cycle FSM.

```
                         ┌──────────────────────────────────────────────────┐
                         │                RiscV (Top Module)                │
                         │                                                  │
                         │   ┌──────────────────────────────────────────┐   │
                         │   │              Datapath                    │   │
  clk ──────────────────►│   │                                          │   │
  rst ──────────────────►│   │  ┌────┐  ┌────┐  ┌───┐  ┌─────┐  ┌───┐ │   │
                         │   │  │ PC ├─►│ IM ├─►│ RF├─►│ ALU ├─►│DM │ │   │
                         │   │  └────┘  └────┘  └───┘  └─────┘  └───┘ │   │
                         │   │         op, funct3, funct7, Zero        │   │
                         │   └──────────────┬───────────────────────────┘   │
                         │                  │  ▲                            │
                         │         status   │  │  control signals           │
                         │                  ▼  │                            │
                         │   ┌──────────────────────────────────────────┐   │
                         │   │           Control Unit                   │   │──► Ready
                         │   └──────────────────────────────────────────┘   │
                         └──────────────────────────────────────────────────┘
```

### Top Module — `RiscV`

The [RiscV.sv](file:///d:/Amirali/AntiIDE/Computer-Architecture-Course-Projects-Fall04/CA2/RiscV.sv) top module wires the Datapath and Control Unit together. The Datapath sends instruction fields (`op`, `funct3`, `funct7_5`, `Zero`) to the Control Unit, which generates all control signals back to the Datapath.

### Datapath

The [Datapath.sv](file:///d:/Amirali/AntiIDE/Computer-Architecture-Course-Projects-Fall04/CA2/Datapath.sv) instantiates and connects all functional units:

| Component | Module | Description |
|---|---|---|
| **Program Counter** | `Register_32` | 32-bit register holding the current PC |
| **PC Mux** | `Mux_4to1_32` | Selects next PC: `PC+4`, `PCTarget` (branch/jal), `ALUResult` (jalr) |
| **PC Adder** | `Adder_32` | Computes `PC + 4` |
| **PC Target Adder** | `Adder_32` | Computes `PC + ImmExt` (for branches & JAL) |
| **Instruction Memory** | `InstructionMemory` | 8192-word ROM, loaded from `instructions.mem` (hex) |
| **Register File** | `RegisterFile` | 32 × 32-bit registers with dual read, single write. `x0` is hardwired to zero |
| **Immediate Extend** | `ImmediateExtend` | Sign-extends immediates for I/S/B/J/U types |
| **ALU Src Mux** | `Mux_2to1_32` | Selects ALU operand B: `rs2` data or immediate |
| **ALU** | `ALU` | 32-bit signed ALU with 6 operations |
| **Data Memory** | `DataMemory` | 8192-word read/write memory, initialized from `data.mem` |
| **Result Mux** | `Mux_4to1_32` | Selects write-back: ALU result, memory data, `PC+4`, or PC |

### Control Unit

The [ControlUnit.sv](file:///d:/Amirali/AntiIDE/Computer-Architecture-Course-Projects-Fall04/CA2/ControlUnit.sv) is a purely combinational unit that decodes the opcode, `funct3`, and `funct7` fields to produce all control signals:

| Control Signal | Width | Purpose |
|---|---|---|
| `PCSrc` | 2-bit | Next PC selection: `00` = PC+4, `01` = PC+Imm, `10` = ALUResult (jalr) |
| `ResultSrc` | 2-bit | Write-back source: `00` = ALU, `01` = Memory, `10` = PC+4, `11` = PC |
| `MemWrite` | 1-bit | Data memory write enable |
| `ALUSrc` | 1-bit | ALU source B: `0` = register, `1` = immediate |
| `RegWrite` | 1-bit | Register file write enable |
| `ALUControl` | 3-bit | ALU operation select |
| `ImmSrc` | 3-bit | Immediate type select |
| `Ready` | 1-bit | Asserted when an unrecognized opcode is hit (program termination) |

### ALU Operations

| `ALUControl` | Operation | Description |
|---|---|---|
| `000` | `A + B` | Addition |
| `001` | `A - B` | Subtraction |
| `010` | `A & B` | Bitwise AND |
| `011` | `A \| B` | Bitwise OR |
| `100` | `A ^ B` | Bitwise XOR |
| `101` | `A < B ? 1 : 0` | Set Less Than (signed) |

The `zero` flag is asserted when `result == 0`, used for branch decisions.

### Immediate Extension

The [ImmediateExtend.sv](file:///d:/Amirali/AntiIDE/Computer-Architecture-Course-Projects-Fall04/CA2/ImmediateExtend.sv) sign-extends immediates for all five instruction formats:

| Type | `ImmSrc` | Bit Layout |
|---|---|---|
| **I-type** | `000` | `{20{inst[31]}, inst[31:20]}` |
| **S-type** | `001` | `{20{inst[31]}, inst[31:25], inst[11:7]}` |
| **B-type** | `010` | `{20{inst[31]}, inst[7], inst[30:25], inst[11:8], 1'b0}` |
| **J-type** | `011` | `{12{inst[31]}, inst[19:12], inst[20], inst[30:21], 1'b0}` |
| **U-type** | `100` | `{inst[31:12], 12'b0}` |

---

## 🧪 Test Program: Bubble Sort

The processor is verified by running **Bubble Sort** on an array of 20 signed 32-bit integers.

### Original C Code

```c
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

### RISC-V Assembly (`sort.s`)

```asm
    addi x1, x0, 0       # x1 = base address of array (0)
    addi x2, x0, 0       # x2 = i (outer loop counter)
    addi x8, x0, 20      # x8 = N = 20
    addi x4, x0, 19      # x4 = N-1 = 19
LOOP1:
    slt  x12, x2, x4     # x12 = (i < N-1) ? 1 : 0
    beq  x12, x0, DONE   # if i >= N-1, exit
    addi x3, x0, 0       # x3 = j (inner loop counter)
    addi x7, x1, 0       # x7 = &arr[j] (pointer)
    sub  x9, x4, x2      # x9 = N-1-i (inner loop bound)
LOOP2:
    slt  x10, x3, x9     # x10 = (j < N-1-i) ? 1 : 0
    beq  x10, x0, END_LOOP2  # if j >= bound, exit inner
    lw   x5, 0(x7)       # x5 = arr[j]
    lw   x6, 4(x7)       # x6 = arr[j+1]
    slt  x11, x6, x5     # x11 = (arr[j+1] < arr[j]) ? 1 : 0
    beq  x11, x0, NO_SWAP    # if arr[j] <= arr[j+1], skip swap
    sw   x6, 0(x7)       # arr[j] = arr[j+1]
    sw   x5, 4(x7)       # arr[j+1] = arr[j] (swap)
NO_SWAP:
    addi x3, x3, 1       # j++
    addi x7, x7, 4       # pointer += 4
    jal  x0, LOOP2       # jump to inner loop
END_LOOP2:
    addi x2, x2, 1       # i++
    jal  x0, LOOP1       # jump to outer loop
DONE:                     # program ends (Ready asserted)
```

### Register Usage

| Register | Purpose |
|---|---|
| `x0` | Hardwired zero |
| `x1` | Base address of the array |
| `x2` | Outer loop counter (`i`) |
| `x3` | Inner loop counter (`j`) |
| `x4` | `N - 1 = 19` |
| `x5`, `x6` | Loaded array elements for comparison |
| `x7` | Pointer to current array element |
| `x8` | `N = 20` |
| `x9` | Inner loop bound (`N - 1 - i`) |
| `x10`, `x11`, `x12` | Comparison results (SLT output) |

### Data Memory — Initial Array

```
Address 0x00: 12, -5, 33, 7, 0, 19, -12, 44, 8, -1
Address 0x28: 3, 27, 15, 2, -8, 6, 7, -3, 25, 1
```

After sorting, the expected output in memory:

```
-12, -8, -5, -3, -1, 0, 1, 2, 3, 6, 7, 7, 8, 12, 15, 19, 25, 27, 33, 44
```

---

## 🛠️ Toolchain

Two custom Python scripts automate the assembly-to-hex pipeline:

### 1. Assembler — `assembly_to_machine.py`

A full **RISC-V assembler** that:
- Parses `.s` assembly files with label support
- Encodes all supported instruction types (R/I/S/B/J/U)
- Outputs machine code as hex to `instructions.mem`
- Handles two-pass assembly (labels resolved in first pass, encoding in second)

```bash
python Assembly/assembly_to_machine.py
# Output: instructions.mem (22 instructions in hex)
```

### 2. Data Memory Generator — `make_data_mem.py`

Converts the array of signed integers to 32-bit two's complement hex:

```bash
python Assembly/make_data_mem.py
# Input:  Assembly/array_of_integers.txt (20 integers, one per line)
# Output: data.mem (20 hex values)
```

---

## 📁 File Structure

```
CA2/
├── RiscV.sv                  # Top-level module (wires Datapath + ControlUnit)
├── Datapath.sv               # Datapath with PC, memories, RF, ALU, MUXes, adders
├── ControlUnit.sv            # Combinational control unit (decodes opcode/funct)
├── ALU.sv                    # 32-bit signed ALU (add/sub/and/or/xor/slt)
├── RegisterFile.sv           # 32 × 32-bit register file (x0 hardwired to zero)
├── ImmediateExtend.sv        # Sign-extension for I/S/B/J/U immediate formats
├── InstructionMemory.sv      # 8192-word instruction ROM (reads instructions.mem)
├── DataMemory.sv             # 8192-word data RAM (initialized from data.mem)
├── Mux.sv                    # 2-to-1 and 4-to-1 32-bit multiplexers
├── Adder.sv                  # 32-bit adder
├── register.sv               # 32-bit register (used for PC)
├── RiscV_TB.sv               # Testbench — clocks processor until Ready is asserted
├── instructions.mem          # Machine code (22 hex instructions for bubble sort)
├── data.mem                  # Initial data memory (20 signed integers in hex)
├── Assembly/
│   ├── sort.c                # Reference C implementation of bubble sort
│   ├── sort.s                # Hand-written RISC-V assembly for bubble sort
│   ├── assembly_to_machine.py  # Custom assembler: .s → instructions.mem
│   ├── make_data_mem.py      # Converts integer array → data.mem (hex)
│   └── array_of_integers.txt # Raw input array (20 signed integers)
├── CA#02.pdf                 # Project specification / assignment description
└── ComputerArchitecture-CA2-810102443-810102530.pdf  # Handwritten report
```

---

## ⚙️ Simulation

### Running in ModelSim / QuestaSim

```tcl
# Compile all sources
vlog *.sv

# Run simulation
vsim work.RiscV_TB
run -all
```

### Testbench Behavior

The [RiscV_TB.sv](file:///d:/Amirali/AntiIDE/Computer-Architecture-Course-Projects-Fall04/CA2/RiscV_TB.sv) testbench:
1. Asserts reset for 10ns, then releases
2. Generates a clock with **40ns period** (20ns half-period)
3. Runs until the `Ready` signal is asserted (when the processor hits an unrecognized opcode after `DONE` label)
4. Stops simulation automatically 10ns after `Ready` rises

### Verification

After simulation completes, the data memory should contain the sorted array:
- Inspect `DM.memory[0]` through `DM.memory[19]` in the waveform viewer
- Values should be in ascending order: `-12, -8, -5, -3, -1, 0, 1, 2, 3, 6, 7, 7, 8, 12, 15, 19, 25, 27, 33, 44`

---

## 📝 Key Design Decisions

- **Word-addressed memories** — Both instruction and data memory use `A[31:2]` as the address, implementing word-aligned access (each address maps to a 32-bit word)
- **Hardwired x0** — The register file explicitly prevents writes to `x0` (`A3 != 5'd0` guard), ensuring it always reads zero
- **Data memory initialized on reset** — Unlike instruction memory (which uses `initial`), data memory reloads from `data.mem` on every reset via `$readmemh`, allowing clean re-runs
- **Ready signal as program terminator** — The `default` case in the control unit asserts `Ready`, providing a clean halt mechanism when the PC runs past valid instructions
- **Custom Python assembler** — Rather than relying on external toolchains (gcc, objcopy), a self-contained Python assembler handles the full assembly-to-hex pipeline with label resolution
- **Result mux includes PC** — The 4-to-1 result mux supports `PC+4` (for JAL/JALR link address) and raw `PC` as write-back sources, enabling proper return address saving
