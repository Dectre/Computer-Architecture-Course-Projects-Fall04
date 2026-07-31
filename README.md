# Computer Architecture Course - Spring 2026 (1405) 🎓

This repository contains the Computer Assignments for the **Computer Architecture** course, completed in Spring 1405 (2026). It features four major hardware design projects implemented in Verilog, covering neural networks and RISC-V processor architectures.

---

### 🧠 CA1: LIF Neuron
Hardware implementation of a **Leaky Integrate-and-Fire (LIF)** neuron model. This module simulates biological neuron behavior by integrating input currents over time, applying a leakage factor, and generating spikes when the membrane potential exceeds a threshold. It serves as a fundamental building block for neuromorphic computing systems.

---

### ⚙️ CA2: Single-Cycle RISC-V Processor
A fully functional **single-cycle RISC-V processor** where every instruction executes within one clock cycle. This design includes the datapath and control unit necessary to fetch, decode, execute, and write back instructions instantly. It supports the base integer instruction set (RV32I) and is ideal for understanding the basics of processor datapaths without pipeline complexities.

---

### 🔄 CA3: Multi-Cycle RISC-V Processor
An optimized **multi-cycle RISC-V processor** that breaks down instruction execution into multiple clock cycles using a Finite State Machine (FSM). By sharing hardware resources across different stages, this design improves area efficiency compared to the single-cycle approach while maintaining correct execution flow for all supported instructions.

---

### 🚀 CA4: Pipelined RISC-V Processor
A high-performance **5-stage pipelined RISC-V processor** featuring Instruction Fetch, Decode, Execute, Memory, and Write-Back stages. This implementation includes advanced mechanisms such as **hazard detection units**, **data forwarding paths**, and **control hazard handling** to maximize instruction throughput and minimize stalls.

---

## 👨‍💻 Authors
- **Amirali Dehghani** | Student ID: 810102443
- **Nazhin Nikkhahbahrami** | Student ID: 810102530

---

<div align="center">

**⭐ If you found this repository helpful, please give it a star!**

</div>
