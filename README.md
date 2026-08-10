<div align="center">

# 🏛️ Computer Architecture Course — Fall 1404 (2025–2026)
### Department of Electrical and Computer Engineering — University of Tehran

![SystemVerilog](https://img.shields.io/badge/Language-Verilog-blue.svg?style=for-the-badge&logo=IEEE)
![RISC-V](https://img.shields.io/badge/ISA-RISC--V%20(RV32I)-red.svg?style=for-the-badge&logo=riscv)
![ModelSim](https://img.shields.io/badge/Simulator-ModelSim-green.svg?style=for-the-badge)
![Status](https://img.shields.io/badge/Projects-100%25%20Completed-brightgreen.svg?style=for-the-badge)
![University](https://img.shields.io/badge/University-University%20of%20Tehran-gold.svg?style=for-the-badge)

A comprehensive suite of **four major digital hardware design projects** implemented in Verilog / SystemVerilog, covering neuromorphic spiking neural networks and single-cycle, multi-cycle, and pipelined RISC-V processor architectures.

---

> 👨‍💻 **Authors:** **Amirali Dehghani** (`810102443`) · **Nazhin Nikkhahbahrami** (`810102530`)  
> 🎓 **Course:** Computer Architecture — Dr. Safari | **University of Tehran**

</div>

---

## 🚀 Projects Overview

| Project | Topic | Target Architecture & Highlights | Reports & Schematics | Full Documentation |
|---|---|---|---|---|
| **CA1** | **LIF Neuron** | Neuromorphic computing, Q4.8 signed fixed-point, 19-state FSM, Euler leakage ($\alpha=0.25$) | [CA01-Report.pdf](CA1/CA01-810102443-810102530.pdf) | [CA1 Documentation ➔](CA1/README.md) |
| **CA2** | **Single-Cycle RISC-V** | 32-bit RV32I core ($CPI=1.0$), 16 instructions, Bubble Sort Python assembler | [CA02-Report.pdf](CA2/ComputerArchitecture-CA2-810102443-810102530.pdf) | [CA2 Documentation ➔](CA2/README.md) |
| **CA3** | **Multi-Cycle RISC-V** | 16-bit core, 14-state FSM controller, shared ALU & Memory, Array Sum benchmark | [CA03-Report.pdf](CA3/Report.pdf) | [CA3 Documentation ➔](CA3/README.md) |
| **CA4** | **5-Stage Pipelined RISC-V** | RV32I core with Hazard Unit (EX & MEM forwarding, load-use stalls, branch flushes) | [CA04-Report.pdf](CA4/ComputerArchitecture-CA4-810102443-810102530.pdf) | [CA4 Documentation ➔](CA4/README.md) |

---

## 🧠 CA1: Leaky Integrate-and-Fire (LIF) Neuron Model

Hardware implementation of a biological **Leaky Integrate-and-Fire (LIF)** neuron model in SystemVerilog. This module simulates biological spiking neuron behavior by integrating input currents over time using Euler discretization ($V[n+1] = V[n] - (V[n] \gg 2) + (V_{rest} \gg 2) + I[n]$), applying a leakage factor, and generating output spikes when the membrane potential exceeds a predefined threshold. It features a 19-state Huffman FSM controller, signed Q4.8 fixed-point arithmetic, and full ModelSim & MATLAB simulation tracing.

👉 **[Explore CA1 Detailed Specifications & RTL Modules ➔](CA1/README.md)**

---

## ⚙️ CA2: Single-Cycle RISC-V Processor Core

A fully functional **32-bit single-cycle RISC-V (RV32I) processor core** where every instruction executes within one clock cycle ($CPI = 1.0$). This design integrates a Register File ($x0$ write-locked), 32-bit ALU, Data & Instruction Memory, Immediate Extension unit, and combinational decoder supporting 16 core instructions (`add`, `sub`, `and`, `or`, `slt`, `addi`, `xori`, `ori`, `slti`, `lw`, `sw`, `beq`, `bne`, `jal`, `jalr`, `lui`). It includes a custom Python toolchain and a hand-crafted assembly benchmark implementing a Bubble Sort algorithm on 10 integers in memory.

👉 **[Explore CA2 Full Datapath & Decoder Control Matrix ➔](CA2/README.md)**

---

## 🔄 CA3: Multi-Cycle RISC-V Processor Core

An optimized **16-bit multi-cycle RISC-V processor core** that breaks instruction execution into multiple clock cycles using a 14-state Finite State Machine (FSM). By sharing hardware resources across execution states (a single shared 16-bit ALU for PC increments and data calculations, and a single unified memory for instructions and data) and utilizing intermediate registers (`IR`, `MDR`, `A`, `B`, `ALUOut`), this design achieves high area efficiency while executing complex control flows and array summation algorithms.

👉 **[Explore CA3 Full FSM State Machine & Control Matrix ➔](CA3/README.md)**

---

## 🚀 CA4: 5-Stage Pipelined RISC-V Processor with Hazard Unit

A high-performance **32-bit 5-stage pipelined RISC-V processor core** featuring Instruction Fetch (IF), Decode (ID), Execute (EX), Memory (MEM), and Write-Back (WB) stages. It includes a dedicated **Hazard Handling Unit** with EX-to-EX and MEM-to-EX data forwarding to eliminate RAW stalls, load-use interlocking stall mechanisms, and branch misprediction flushing logic. Verified via ModelSim waveforms executing an array minimum search algorithm ($\text{min\_val} = -2$).

👉 **[Explore CA4 Full Pipelined Datapath & Hazard Handling Architecture ➔](CA4/README.md)**

---

## 🛠️ Toolchain Stack

- **Languages:** SystemVerilog (IEEE 1800-2017) & Verilog HDL
- **Simulator:** ModelSim / QuestaSim EDA Simulator
- **Mathematical Modeling:** MATLAB (LIF Neuron potential tracing)
- **Assembly Toolchain:** Custom Python Assemblers (`assembly_to_machine.py`)

---

## 📂 Repository Directory Structure

```
Computer-Architecture-Course-Projects-Fall04/
├── README.md                                # Root Repository Landing Page
├── CA1/                                     # CA1: Leaky Integrate-and-Fire (LIF) Neuron
│   ├── README.md                            # CA1 Detailed Documentation
│   ├── LIF.sv / datapath.sv / controller.sv  # SystemVerilog RTL Modules
│   └── CA01-810102443-810102530.pdf         # Project Report & Schematics
├── CA2/                                     # CA2: Single-Cycle RISC-V Processor
│   ├── README.md                            # CA2 Detailed Documentation
│   ├── RiscV.sv / Datapath.sv / ControlUnit.sv # Processor Source Code
│   ├── datapath_diagram.png                 # Datapath Schematic Image
│   └── Assembly/                            # Bubble Sort C/Assembly/Python Toolchain
├── CA3/                                     # CA3: Multi-Cycle RISC-V Processor
│   ├── README.md                            # CA3 Detailed Documentation
│   ├── MultiCycle.sv / Datapath.sv / ControlUnit.sv # Processor Source Code
│   ├── datapath_diagram.png / fsm_diagram.png # Hardware & FSM Schematics
│   └── Report.pdf                           # Project Report & FSM Tables
└── CA4/                                     # CA4: 5-Stage Pipelined RISC-V Processor
    ├── README.md                            # CA4 Detailed Documentation
    ├── datapath_diagram.png / waveform.png # Pipelined Schematic & Simulation Waveforms
    └── src/                                 # Pipelined Datapath & Hazard Handling Unit
```

---

<div align="center">

**🎓 Computer Architecture Course — Fall 1404 (2025–2026)**  
*Department of Electrical and Computer Engineering — University of Tehran*

⭐ **If you found this repository helpful, please consider giving it a star!**

</div>
