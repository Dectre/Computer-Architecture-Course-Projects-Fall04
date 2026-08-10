# CA3: Multi-Cycle RISC-V Processor — Hardware Implementation 🔄⚡

A fully structural, multi-cycle **RISC-V 16-bit processor core** implemented in **SystemVerilog**, featuring resource sharing (single shared ALU, shared memory, internal pipeline registers), a 14-state Finite State Machine (FSM) control unit, and verified via ModelSim simulation executing an array summation algorithm ($1 + 2 + \dots + 10 = 55$).

> 👤 **Authors:** Amirali Dehghani (`810102443`) · Nazhin Nikkhahbahrami (`810102530`)  
> 🎓 **Course:** Computer Architecture — Fall 1404 (2025–2026)  
> 🏫 **University:** University of Tehran  
> 📄 **Handwritten Datapath & FSM Report Reference:** [Report.pdf](Report.pdf)  
> 📋 **Assignment Specification:** [CA#03.pdf](CA%2303.pdf)

---

## 📑 Table of Contents

- [📖 Overview & Architecture Principles](#-overview--architecture-principles)
- [🎯 Instruction Set Architecture (ISA) & Encoding](#-instruction-set-architecture-isa--encoding)
- [🏗️ Hardware System Architecture](#️-hardware-system-architecture)
  - [Top-Level Interface](#top-level-interface)
  - [Full Processor Datapath Schematic](#full-processor-datapath-schematic)
- [🗜️ Datapath Component Specifications](#️-datapath-component-specifications)
  - [Module Hierarchy Table](#module-hierarchy-table)
  - [Internal Register Map](#internal-register-map)
  - [ALU & ALU Control Unit](#alu--alu-control-unit)
- [🕹️ Controller (FSM) Design](#️-controller-fsm-design)
  - [State Diagram & Encodings](#state-diagram--encodings)
  - [14-State Control Signal Matrix](#14-state-control-signal-matrix)
- [🧪 Simulation & Verification](#-simulation--verification)
  - [Testbench Flow](#testbench-flow)
  - [Simulation Output & Memory Results](#simulation-output--memory-results)
- [📐 Compliance with Design Guidelines](#-compliance-with-design-guidelines)
- [📂 Directory Structure](#-directory-structure)

---

## 📖 Overview & Architecture Principles

Unlike single-cycle processors where each instruction executes in one long clock period, a **Multi-Cycle Processor** breaks instruction execution into multiple shorter clock cycles using a Finite State Machine (FSM). 

### Key Advantages & Design Highlights

1. **Hardware Resource Sharing:** A single 16-bit ALU executes both PC increments ($PC + 1$), branch target calculations, and data computations. A single unified memory (`DataMemory`) holds both instructions and data.
2. **Intermediate Registering:** Internal registers hold data between clock cycles:
   - **`IR` (Instruction Register):** Latches instruction fetched from memory.
   - **`MDR` (Memory Data Register):** Latches data read from memory.
   - **`A` & `B` Registers:** Latch register file read outputs $RD1$ and $RD2$.
   - **`ALUOut` Register:** Latches ALU output result for next cycle reuse.
3. **Variable Cycle Execution:** Different instructions take different numbers of clock cycles to complete:
   - **Fetch & Decode:** 2 cycles (`IF` $\to$ `ID`).
   - **Branch / Jump / Store:** 3 cycles total.
   - **R-Type (C-Type) / Addi / Subi / Load:** 4 cycles total.

---

## 🎯 Instruction Set Architecture (ISA) & Encoding

The processor operates on **16-bit instructions** and 16-bit data words:

| Instruction Class | `op` (Bits 15:12) | `Ri` (Bits 11:9) | `func` / Imm (Bits 8:0) | Description |
|---|---|---|---|---|
| **Load** | `0000` | $R_i$ | Immediate Address | $R_i = \text{Memory}[\text{Imm}]$ |
| **Store** | `0001` | $R_i$ | Immediate Address | $\text{Memory}[\text{Imm}] = R_i$ |
| **Jump** | `0010` | — | Target Address | $PC = \text{Imm}$ |
| **Branch** | `0100` | — | Target Address | $\text{if } (A == B) \ PC = \text{Imm}$ |
| **C-Type (R-Type)** | `1000` | $R_i$ | Function Code | Register operation specified by `func` |
| **Addi** | `1100` | $R_i$ | Immediate Value | $R_i = R_i + \text{Imm}$ |
| **Subi** | `1101` | $R_i$ | Immediate Value | $R_i = R_i - \text{Imm}$ |
| **Andi** | `1110` | $R_i$ | Immediate Value | $R_i = R_i \ \& \ \text{Imm}$ |
| **Ori** | `1111` | $R_i$ | Immediate Value | $R_i = R_i \ \| \ \text{Imm}$ |

### C-Type Function Codes (`func[8:0]`)

| Function Code (`func`) | Operation Name | Description |
|---|---|---|
| `9'b000000100` | `ADD` | $R_i = A + B$ |
| `9'b000001000` | `SUB` | $R_i = A - B$ |
| `9'b000010000` | `AND` | $R_i = A \ \& \ B$ |
| `9'b000100000` | `OR` | $R_i = A \ \| \ B$ |
| `9'b001000000` | `NOT` | $R_i = \sim A$ |
| `9'b000000001` | `SELB` | Write to $R_i$ from $B$ |
| `9'b000000010` | `SELA` | Write to $R_i$ from $A$ |
| `9'b010000000` | `NOP` | No Operation (asserts `nop = 1`) |

---

## 🏗️ Hardware System Architecture

### Top-Level Interface

The top module [MultiCycle.sv](MultiCycle.sv) wires the Datapath ([Datapath.sv](Datapath.sv)) and Controller ([ControlUnit.sv](ControlUnit.sv)):

```
                       ┌─────────────────────────────────────────┐
                       │          MultiCycle (Top Module)        │
                       │                                         │
  clk ────────────────►│   ┌──────────────┐    ┌─────────────┐   │
  rst ────────────────►│   │              │    │             │   │
                       │   │ ControlUnit  │◄───│  Datapath   │   │
                       │   │    (FSM)     │───►│             │   │
                       │   └──────────────┘    └─────────────┘   │
                       └─────────────────────────────────────────┘
```

---

### Full Processor Datapath Schematic

The hand-drawn hardware datapath from Page 1 of [Report.pdf](Report.pdf) is presented below:

<p align="center">
  <img src="datapath_diagram.png" alt="Multi-Cycle RISC-V Datapath Diagram" width="800"/>
</p>

---

## 🗜️ Datapath Component Specifications

### Module Hierarchy Table

| Module Name | File | Functionality |
|---|---|---|
| `MultiCycle` | [MultiCycle.sv](MultiCycle.sv) | Top-level entity integrating Datapath & ControlUnit |
| `Datapath` | [Datapath.sv](Datapath.sv) | Interconnects PC, Memory, IR, MDR, RF, A, B, ALU, ALUOut, MUXes |
| `ControlUnit` | [ControlUnit.sv](ControlUnit.sv) | 14-State FSM Controller generating control signals |
| `ALUControlUnit` | [ALUControlUnit.sv](ALUControlUnit.sv) | Secondary ALU control decoder (maps `AluOp` + `func` $\to$ `AluOpc`) |
| `ALU` | [ALU.sv](ALU.sv) | 16-bit multi-function ALU with zero detection |
| `RegisterFile` | [RegisterFile.sv](RegisterFile.sv) | $8 \times 16$-bit Register File with dual read, single write |
| `DataMemory` | [DataMemory.sv](DataMemory.sv) | 4096-word 16-bit unified Memory (loads `data.mem`) |
| `Register` | [Register.sv](Register.sv) | Generic load-enabled register (used for PC, IR, MDR, A, B, ALUOut) |
| `Mux_2to1` | [Mux.sv](Mux.sv) | 2-channel multiplexer |
| `Mux_4to1` | [Mux.sv](Mux.sv) | 4-channel multiplexer |
| `SignExtend` | [SignExtend.sv](SignExtend.sv) | 12-bit to 16-bit Sign Extension module |

---

### Internal Register Map

| Register Name | Bit Width | Function |
|---|---|---|
| `PC` | 12-bit | Program Counter, updated conditionally via `PCLoad = PCWrite \| (branch \& Zero)` |
| `IR` | 16-bit | Instruction Register, latches fetched instruction when `IRWrite == 1` |
| `MDR` | 16-bit | Memory Data Register, latches read data from memory every clock cycle |
| `A` | 16-bit | Register $A$, latches Read Register 1 output ($RD1$) every cycle |
| `B` | 16-bit | Register $B$, latches Read Register 2 output ($RD2$) every cycle |
| `ALUOut` | 16-bit | Latches ALU computation result for write-back or PC calculation |

---

### ALU & ALU Control Unit

The ALU ([ALU.sv](ALU.sv)) supports 7 operations selected by 3-bit `AluOpc`:

| `AluOpc` | Operation | RTL Expression | Usage |
|---|---|---|---|
| `3'b000` | **ADD** | `A + B` | PC increment, addition, memory address calculation |
| `3'b001` | **SUB** | `A - B` | Subtraction, branch zero evaluation |
| `3'b010` | **AND** | `A & B` | Bitwise AND |
| `3'b011` | **OR** | `A \| B` | Bitwise OR |
| `3'b100` | **NOT** | `~A` | Bitwise NOT |
| `3'b101` | **SELA** | `A` | Pass operand A through |
| `3'b110` | **SELB** | `B` | Pass operand B through |

---

## 🕹️ Controller (FSM) Design

### State Diagram & Encodings

The controller ([ControlUnit.sv](ControlUnit.sv)) implements a **14-state Finite State Machine** corresponding directly to Page 2 of [Report.pdf](Report.pdf):

<p align="center">
  <img src="fsm_diagram.png" alt="Multi-Cycle FSM State Diagram" width="800"/>
</p>

---

### 14-State Control Signal Matrix

| State Name | State Code | `PCload` | `AdrSrc` | `MemWrite` | `IRWrite` | `RFWrite` | `WriteTo` | `WriteSrc` | `SrcA` | `SrcB` | `AluOP` | `PCSrc` | `branch` |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| `IF` | `4'b0000` | **1** | `0` | `0` | **1** | `0` | — | — | `01` | `01` | `000` | `00` | `0` |
| `ID` | `4'b0001` | `0` | — | `0` | `0` | `0` | — | — | — | — | — | — | `0` |
| `Branch` | `4'b0010` | (cond) | — | `0` | `0` | `0` | — | — | `00` | `00` | `001` | `10` | **1** |
| `CType` | `4'b0011` | `0` | — | `0` | `0` | `0` | — | — | `00` | `00` | `100` | — | `0` |
| `CWrite` | `4'b0100` | `0` | — | `0` | `0` | **1** | (func) | **1** | — | — | `100` | — | `0` |
| `Jump` | `4'b0101` | **1** | — | `0` | `0` | `0` | — | — | — | — | — | `01` | `0` |
| `Store` | `4'b0110` | `0` | **1** | **1** | `0` | `0` | — | — | — | — | — | — | `0` |
| `Load` | `4'b0111` | `0` | **1** | `0` | `0` | `0` | — | — | — | — | — | — | `0` |
| `LWrite` | `4'b1000` | `0` | — | `0` | `0` | **1** | `0` | `0` | — | — | — | — | `0` |
| `Addi` | `4'b1001` | `0` | — | `0` | `0` | `0` | — | — | `10` | `10` | `000` | — | `0` |
| `Subi` | `4'b1010` | `0` | — | `0` | `0` | `0` | — | — | `10` | `10` | `001` | — | `0` |
| `Andi` | `4'b1011` | `0` | — | `0` | `0` | `0` | — | — | `10` | `10` | `010` | — | `0` |
| `Ori` | `4'b1100` | `0` | — | `0` | `0` | `0` | — | — | `10` | `10` | `011` | — | `0` |
| `ImmWrite`| `4'b1101` | `0` | — | `0` | `0` | **1** | `0` | **1** | `10` | — | — | — | `0` |

---

## 🧪 Simulation & Verification

### Testbench Flow

The testbench [Testbench.sv](Testbench.sv) initializes the processor, releases reset after 20ns, and simulates execution of the program stored in [data.mem](data.mem):

```systemverilog
`timescale 1ns/1ns

module MultiCycle_TB();
    logic clk = 1'b0, rst = 1'b1;

    MultiCycle UUT(clk, rst);
    always #10 clk = ~clk;

    initial begin
        rst = 1'b1;
        #20 rst = 1'b0;
        #20000; 
        $display("Sum : %d", UUT.DP.DM.memory[4000]);
        $stop;
    end
endmodule
```

---

### Simulation Output & Memory Results

The test program loaded into memory sums numbers from 1 to 10 in a loop ($1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 + 10 = 55$) and stores the result at memory location 4000 (`DM.memory[4000]`):

```text
ModelSim> run -all
# Sum :         55
# ** Note: $stop    : D:/University/5th Semester/Digital Systems II/Computer Assignments/CA3/Testbench.sv(14)
#    Time: 20020 ns  Iteration: 0  Instance: /MultiCycle_TB
```

> 🎯 **Result:** The computed sum equaled **55** after $20020\text{ ns}$, verifying correct multi-cycle execution for arithmetic, memory, and branch control paths.

---

## 📐 Compliance with Design Guidelines

1. **Multi-Cycle FSM Architecture:** Execution split into discrete states controlled by a 14-state FSM.
2. **Shared Hardware Resources:** Single ALU and single unified memory.
3. **Pipeline Storage Registers:** Inter-stage registers (`IR`, `MDR`, `A`, `B`, `ALUOut`) latch intermediate values properly.
4. **Modular SystemVerilog Coding:** Clean structural hierarchy adhering to course standards.

---

## 📂 Directory Structure

```
CA3/
├── MultiCycle.sv             # Top-level entity (Datapath + ControlUnit)
├── Datapath.sv               # Multi-cycle Datapath
├── ControlUnit.sv            # 14-State FSM Controller
├── ALUControlUnit.sv         # Secondary ALU control unit
├── ALU.sv                    # 16-bit Signed ALU
├── RegisterFile.sv           # 8x16-bit Register File
├── DataMemory.sv             # 4096-word 16-bit unified memory
├── Mux.sv                    # 2-to-1 and 4-to-1 Multiplexers
├── Register.sv               # Load-enabled 16-bit register module
├── SignExtend.sv             # Sign extension module
├── Testbench.sv              # Testbench running array sum program
├── data.mem                  # Hex memory initialization file
├── datapath.diagram.png      # High-res extracted datapath schematic
├── fsm_diagram.png           # High-res extracted FSM state diagram
├── CA#03.pdf                 # Project specification PDF
└── Report.pdf                # Handwritten report with datapath & FSM tables
```

---

<div align="center">

**🎓 Computer Architecture Course — Fall 1404 (2025)**  
*Department of Electrical and Computer Engineering — University of Tehran*

</div>
