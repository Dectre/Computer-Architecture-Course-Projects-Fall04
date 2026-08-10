# CA4: 5-Stage Pipelined RISC-V Processor with Hazard Handling Unit ⚙️⚡

A 32-bit **5-Stage Pipelined RISC-V (RV32I) Processor Core** implemented in **SystemVerilog**, featuring full **Data Hazard Forwarding**, **Load-Use Data Hazard Stalling**, **Control Hazard Branch Flushing**, and verified via ModelSim simulation executing an array minimum finding algorithm (finding $\text{min\_val} = -2$ in an array of 10 integers).

> 👤 **Authors:** Amirali Dehghani (`810102443`) · Nazhin Nikkhahbahrami (`810102530`)  
> 🎓 **Course:** Computer Architecture — Fall 1404 (2025–2026)  
> 🏫 **University:** University of Tehran  
> 📄 **Handwritten Datapath & Waveform Report Reference:** [ComputerArchitecture-CA4-810102443-810102530.pdf](ComputerArchitecture-CA4-810102443-810102530.pdf)  
> 📋 **Assignment Specification:** [CA#04 - Description.pdf](CA%2304%20-%20Description.pdf)

---

## 📑 Table of Contents

- [📖 Overview & Pipelining Fundamentals](#-overview--pipelining-fundamentals)
- [🎯 Instruction Set Architecture (ISA) & Control Matrix](#-instruction-set-architecture-isa--control-matrix)
- [🏗️ Hardware System Architecture](#️-hardware-system-architecture)
  - [Top-Level Processor Entity](#top-level-processor-entity)
  - [Full Processor Datapath & Hazard Unit Schematic](#full-processor-datapath--hazard-unit-schematic)
- [🗜️ Datapath Component Specifications](#️-datapath-component-specifications)
  - [Module Hierarchy Table](#module-hierarchy-table)
  - [Pipeline Register Banks](#pipeline-register-banks)
- [🛡️ Hazard Handling Unit Architecture](#️-hazard-handling-unit-architecture)
  - [Data Forwarding Logic](#data-forwarding-logic)
  - [Load-Use Data Hazard Stalling](#load-use-data-hazard-stalling)
  - [Control Hazard Branch Flushing](#control-hazard-branch-flushing)
- [💻 Software & Toolchain Benchmark](#-software--toolchain-benchmark)
  - [C Reference Implementation](#c-reference-implementation)
  - [Hand-Crafted RISC-V Assembly](#hand-crafted-risc-v-assembly)
  - [Custom Python Assembler](#custom-python-assembler)
- [🧪 Simulation & Verification](#-simulation--verification)
  - [Testbench Flow](#testbench-flow)
  - [Waveform & Memory Verification](#waveform--memory-verification)
- [📐 Compliance with Design Guidelines](#-compliance-with-design-guidelines)
- [📂 Directory Structure](#-directory-structure)

---

## 📖 Overview & Pipelining Fundamentals

Pipelining increases processor throughput by overlapping the execution of multiple instructions in hardware. This 32-bit RISC-V processor breaks instruction execution into **5 pipeline stages**:

```
      ┌───────────┐     ┌───────────┐     ┌───────────┐     ┌───────────┐     ┌───────────┐
      │ Fetch     │ ──► │ Decode    │ ──► │ Execute   │ ──► │ Memory    │ ──► │ WriteBack │
      │ (IF)      │     │ (ID)      │     │ (EX)      │     │ (MEM)     │     │ (WB)      │
      └───────────┘     └───────────┘     └───────────┘     └───────────┘     └───────────┘
```

1. **Instruction Fetch (IF):** Reads next instruction from [InstructionMemory.sv](src/InstructionMemory.sv) using $PC$.
2. **Instruction Decode (ID):** Decodes instruction ([ControlUnit.sv](src/ControlUnit.sv)), reads operands from [RegisterFile.sv](src/RegisterFile.sv), and extends immediate ([ImmediateExtend.sv](src/ImmediateExtend.sv)).
3. **Execute (EX):** Computes arithmetic/logic result ([ALU.sv](src/ALU.sv)), computes branch targets, and resolves branch conditions.
4. **Memory Access (MEM):** Performs load/store operations in [DataMemory.sv](src/DataMemory.sv).
5. **Write-Back (WB):** Writes final result back to the destination register $Rd$.

---

## 🎯 Instruction Set Architecture (ISA) & Control Matrix

The processor supports **16 core RISC-V (RV32I) instructions**, controlled by 10 decoder signals generated in [ControlUnit.sv](src/ControlUnit.sv):

| Instruction | Type | `opcode` | `funct3` | `funct7` | `ImmSrc` | `ALUSrc` | `ALUControl` | `Branch` | `Jump` | `MemWrite` | `ResultSrc` | `RegWrite` | `JumpSel` |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **add** | R | `0110011` | `000` | `0000000` | — | `0` | `ADD` | `00` | `0` | `0` | `00` | `1` | X |
| **sub** | R | `0110011` | `000` | `0100000` | — | `0` | `SUB` | `00` | `0` | `0` | `00` | `1` | X |
| **and** | R | `0110011` | `111` | `0000000` | — | `0` | `AND` | `00` | `0` | `0` | `00` | `1` | X |
| **or** | R | `0110011` | `110` | `0000000` | — | `0` | `OR` | `00` | `0` | `0` | `00` | `1` | X |
| **slt** | R | `0110011` | `010` | `0000000` | — | `0` | `SLT` | `00` | `0` | `0` | `00` | `1` | X |
| **addi** | I | `0010011` | `000` | — | `I(000)` | `1` | `ADD` | `00` | `0` | `0` | `00` | `1` | X |
| **xori** | I | `0010011` | `100` | — | `I(000)` | `1` | `XOR` | `00` | `0` | `0` | `00` | `1` | X |
| **ori** | I | `0010011` | `110` | — | `I(000)` | `1` | `OR` | `00` | `0` | `0` | `00` | `1` | X |
| **slti** | I | `0010011` | `010` | — | `I(000)` | `1` | `SLT` | `00` | `0` | `0` | `00` | `1` | X |
| **lw** | I | `0000011` | `010` | — | `I(000)` | `1` | `ADD` | `00` | `0` | `0` | `01` | `1` | X |
| **sw** | S | `0100011` | `010` | — | `S(001)` | `1` | `ADD` | `00` | `0` | `1` | `00` | `0` | X |
| **beq** | B | `1100011` | `000` | — | `B(010)` | `0` | `SUB` | `01` | `0` | `0` | `00` | `0` | X |
| **bne** | B | `1100011` | `001` | — | `B(010)` | `0` | `SUB` | `11` | `0` | `0` | `00` | `0` | X |
| **jal** | J | `1101111` | — | — | `J(011)` | X | `ADD` | `00` | `1` | `0` | `10` | `1` | `0` |
| **jalr** | I | `1100111` | `000` | — | `I(000)` | `1` | `ADD` | `00` | `1` | `0` | `10` | `1` | `1` |
| **lui** | U | `0110111` | — | — | `U(100)` | `1` | `PASS_B`| `00` | `0` | `0` | `00` | `1` | X |

---

## 🏗️ Hardware System Architecture

### Top-Level Processor Entity

The top-level entity [Processor.sv](src/Processor.sv) (`RISCV_Top`) instantiates and interconnects three primary blocks:

```
                       ┌────────────────────────────────────────────────────────┐
                       │                     RISCV_Top                          │
                       │                                                        │
                       │   ┌──────────────┐                 ┌───────────────┐   │
  clk ────────────────►│   │ ControlUnit  │                 │  HazardUnit   │   │
  rst ────────────────►│   └──────┬───────┘                 └───────▲───────┘   │
                       │          │ Control Signals                 │ Forward / │
                       │          ▼                                 │ Stall /   │
                       │   ┌────────────────────────────────────────┴───────┐   │
                       │   │                   Datapath                     │   │
                       │   └────────────────────────────────────────────────┘   │
                       └────────────────────────────────────────────────────────┘
```

---

### Full Processor Datapath & Hazard Unit Schematic

The complete hardware architecture from Page 1 of [ComputerArchitecture-CA4-810102443-810102530.pdf](ComputerArchitecture-CA4-810102443-810102530.pdf) is presented below:

<p align="center">
  <img src="datapath_diagram.png" alt="5-Stage Pipelined RISC-V Datapath with Hazard Unit Diagram" width="800"/>
</p>

---

## 🗜️ Datapath Component Specifications

### Module Hierarchy Table

| Module Name | File | Description |
|---|---|---|
| `RISCV_Top` | [Processor.sv](src/Processor.sv) | Top-level entity integrating Datapath, ControlUnit, & HazardUnit |
| `Datapath` | [Datapath.sv](src/Datapath.sv) | 5-stage pipelined datapath with pipeline registers and forwarding MUXes |
| `ControlUnit` | [ControlUnit.sv](src/ControlUnit.sv) | Decoder producing 10 control signals for D stage |
| `HazardUnit` | [HazardUnit.sv](src/HazardUnit.sv) | Hazard handling unit for forwarding, stalls, and branch flushes |
| `ALU` | [ALU.sv](src/ALU.sv) | 32-bit Arithmetic Logic Unit |
| `RegisterFile` | [RegisterFile.sv](src/RegisterFile.sv) | $32 \times 32$-bit register file ($x0$ hardwired to 0) |
| `DataMemory` | [DataMemory.sv](src/DataMemory.sv) | 8192-word RAM data memory (initializes from `data.mem`) |
| `InstructionMemory` | [InstructionMemory.sv](src/InstructionMemory.sv) | 8192-word ROM instruction memory (initializes from `instructions.mem`) |
| `ImmediateExtend` | [ImmediateExtend.sv](src/ImmediateExtend.sv) | Sign extension unit for I, S, B, J, and U instruction formats |
| `Mux_2to1` / `Mux_4to1` | [Mux.sv](src/Mux.sv) | Generic 32-bit multiplexers |

---

### Pipeline Register Banks

Inter-stage pipeline registers latch data and control signals on positive clock edges:

| Register Bank | Latched Data Signals | Latched Control Signals |
|---|---|---|
| **IF/ID** | `PCF`, `InstrF`, `PCPlus4F` | Controlled by `StallD` and `FlushD` |
| **ID/EX** | `PCD`, `Rs1D`, `Rs2D`, `RdD`, `RD1D`, `RD2D`, `ExtImmD`, `PCPlus4D` | `RegWriteD`, `ResultSrcD`, `MemWriteD`, `JumpD`, `BranchD`, `ALUControlD`, `ALUSrcD`, `JumpSelD` |
| **EX/MEM**| `ALUResultE`, `WriteDataE`, `RdE`, `PCPlus4E` | `RegWriteE`, `ResultSrcE`, `MemWriteE` |
| **MEM/WB**| `ALUResultM`, `ReadDataM`, `RdM`, `PCPlus4M` | `RegWriteM`, `ResultSrcM` |

---

## 🛡️ Hazard Handling Unit Architecture

The Hazard Handling Unit ([HazardUnit.sv](src/HazardUnit.sv)) resolves pipeline hazards dynamically:

### Data Forwarding Logic

When an instruction in the EX stage requires operand data produced by an earlier instruction currently in the MEM or WB stage, data is forwarded directly without stalling:

$$\text{ForwardAE} = \begin{cases}
\text{2'b10} & \text{if } (Rs1E == RdM \ \land \ RegWriteM \ \land \ Rs1E \neq 0) \quad \text{(EX-to-EX Forwarding)} \\
\text{2'b01} & \text{if } (Rs1E == RdW \ \land \ RegWriteW \ \land \ Rs1E \neq 0) \quad \text{(MEM-to-EX Forwarding)} \\
\text{2'b00} & \text{otherwise (Use RD1E from ID/EX register)}
\end{cases}$$

$$\text{ForwardBE} = \begin{cases}
\text{2'b10} & \text{if } (Rs2E == RdM \ \land \ RegWriteM \ \land \ Rs2E \neq 0) \quad \text{(EX-to-EX Forwarding)} \\
\text{2'b01} & \text{if } (Rs2E == RdW \ \land \ RegWriteW \ \land \ Rs2E \neq 0) \quad \text{(MEM-to-EX Forwarding)} \\
\text{2'b00} & \text{otherwise (Use RD2E from ID/EX register)}
\end{cases}$$

---

### Load-Use Data Hazard Stalling

When a `lw` instruction in EX stage produces a result needed immediately by an instruction in ID stage, forwarding cannot solve the hazard (data is not yet read from memory). A 1-cycle stall is inserted:

$$\text{LWStall} = ((Rs1D == RdE) \ \lor \ (Rs2D == RdE)) \ \land \ ResultSrcE_0$$

- **`StallF = LWStall`:** Freezes the Program Counter ($PC$).
- **`StallD = LWStall`:** Freezes the IF/ID pipeline register.
- **`FlushE = LWStall`:** Clears the ID/EX pipeline register (inserts a bubble into EX stage).

---

### Control Hazard Branch Flushing

When a branch or jump is taken in the EX stage ($PCSrcE = 1$), the instructions fetched into IF and ID stages are invalid:

- **`FlushD = PCSrcE`:** Flushes the IF/ID register (clears wrong instruction).
- **`FlushE = PCSrcE`:** Flushes the ID/EX register.

---

## 💻 Software & Toolchain Benchmark

### C Reference Implementation

The benchmark algorithm finds the minimum value in an array of 10 signed integers ([code.c](src/Assembly/code.c)):

```c
#include <stdio.h>
int main() {
    int array[10] = {5, 12, -1, 16, -2, 3, 8, 0, 9, 20};
    int min_val = array[0];
    for (int i = 1; i < 10; i++) {
        int current_val = array[i];
        if (current_val < min_val) {
            min_val = current_val;
        }
    }
    printf("The minimum value is: %d\n", min_val);
    return 0;
}
```

---

### Hand-Crafted RISC-V Assembly

The algorithm translated into RISC-V assembly ([code.s](src/Assembly/code.s)):

```assembly
start:
    addi x10, x0, 0          # x10 = array base pointer offset (0)
    addi x11, x0, 9          # x11 = loop counter (9 iterations)
    lw   x12, 0(x10)         # x12 = min_val = array[0]
    addi x10, x10, 4         # move pointer to array[1]

loop:
    beq  x11, x0, finish     # exit loop if counter == 0
    lw   x13, 0(x10)         # x13 = current_val = array[i]
    slt  x14, x13, x12       # x14 = (current_val < min_val)
    beq  x14, x0, skip_update# if not smaller, skip update
    add  x12, x13, x0        # min_val = current_val

skip_update:
    addi x10, x10, 4         # move pointer to array[i+1]
    addi x11, x11, -1        # counter--
    jal  x0, loop            # repeat loop

finish:
    addi x15, x0, 400        # x15 = 400 (target memory address)
    sw   x12, 0(x15)         # store min_val (-2) into memory[400]
```

---

### Custom Python Assembler

The assembler script [assembly_to_machine.py](src/Assembly/assembly_to_machine.py) translates the assembly instructions into 32-bit hex machine code stored in [instructions.mem](src/instructions.mem).

---

## 🧪 Simulation & Verification

### Testbench Flow

The testbench [Testbench.sv](src/Testbench.sv) drives `clk` and `rst`, running the pipelined core until the minimum calculation finishes:

```systemverilog
`timescale 1ns/1ns

module RISCV_TB();
    logic clk = 1'b0, rst = 1'b1;

    RISCV_Top UUT(clk, rst);
    always #5 clk = ~clk;

    initial begin
        rst = 1'b1;
        #10 rst = 1'b0;
    end
endmodule
```

---

### Waveform & Memory Verification

The simulation waveform from Page 4 of [ComputerArchitecture-CA4-810102443-810102530.pdf](ComputerArchitecture-CA4-810102443-810102530.pdf) confirms correct array minimum search execution:

<p align="center">
  <img src="waveform.png" alt="ModelSim Simulation Waveform Result" width="800"/>
</p>

### Final State Verification Summary

- **Register `x12` (`registers[12]`):** Contains `-2` (the array minimum).
- **Memory Address `400` (`memory[100]` word):** Stores `-2` at the conclusion of execution.

---

## 📐 Compliance with Design Guidelines

1. **5-Stage Pipelined Microarchitecture:** Full separation into IF, ID, EX, MEM, and WB stages with dedicated pipeline register banks.
2. **Dynamic Data Hazard Forwarding:** 3-to-1 MUXes in EX stage eliminate RAW stalls for arithmetic and memory dependencies.
3. **Load-Use Stall Mechanism:** Interlocking logic handles memory read latencies by inserting controlled bubbles.
4. **Control Hazard Branch Speculation:** Branch flushing logic clears invalid instructions upon misprediction or branch resolution.
5. **Modular SystemVerilog HDL:** Modular design adhering strictly to academic coding standards.

---

## 📂 Directory Structure

```
CA4/
├── src/
│   ├── Processor.sv            # Top-level entity RISCV_Top
│   ├── Datapath.sv             # 5-stage pipelined Datapath
│   ├── ControlUnit.sv          # Control Decoder Matrix
│   ├── HazardUnit.sv           # Hazard Forwarding, Stalling, & Flushing Unit
│   ├── ALU.sv                  # 32-bit Arithmetic Logic Unit
│   ├── RegisterFile.sv         # 32x32-bit Register File
│   ├── DataMemory.sv           # 8192-word Data RAM Memory
│   ├── InstructionMemory.sv    # 8192-word Instruction ROM Memory
│   ├── ImmediateExtend.sv      # Immediate Sign Extension module
│   ├── Mux.sv                  # 2-to-1 and 4-to-1 Multiplexer modules
│   ├── Register.sv             # Load-enabled Register module
│   ├── RegisterDefinitions.sv  # Shared package parameters
│   ├── Testbench.sv            # ModelSim Testbench
│   ├── data.mem                # Initial input array data memory
│   ├── instructions.mem        # Machine code instructions memory
│   └── Assembly/
│       ├── code.c              # C benchmark algorithm source
│       ├── code.s              # Hand-crafted RISC-V assembly
│       ├── assembly_to_machine.py # Custom Python assembler
│       ├── make_data_mem.py    # Python memory initialization script
│       └── array_of_integers.txt # Input array values
├── datapath_diagram.png        # High-res 5-stage Pipelined Datapath diagram
├── waveform.png                # High-res ModelSim simulation waveform
├── CA#04 - Description.pdf     # Project prompt specification
└── ComputerArchitecture-CA4-810102443-810102530.pdf # Full project report
```

---

<div align="center">

**🎓 Computer Architecture Course — Fall 1404 (2025)**  
*Department of Electrical and Computer Engineering — University of Tehran*

</div>
