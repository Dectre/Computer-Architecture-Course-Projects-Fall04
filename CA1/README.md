# CA1: Leaky Integrate-and-Fire (LIF) Neuron — Hardware Implementation 🧠

A fully structural, RTL-level implementation of a **Leaky Integrate-and-Fire (LIF)** spiking neuron model in **SystemVerilog**, verified with a comprehensive testbench and validated against MATLAB-generated reference outputs.

> **Authors:** Amirali Dehghani (`810102443`) · Nazhin Nikkhahbahrami (`810102530`)
>
> **Course:** Computer Architecture — Fall 1404 (2025)

---

## 📖 Overview

The LIF neuron is a foundational model in **neuromorphic computing**. It simulates biological neuron behavior through three core mechanisms:

1. **Integration** — Accumulates weighted input currents into a membrane potential
2. **Leakage** — Applies an exponential decay to the membrane potential every timestep
3. **Fire & Reset** — When the membrane potential exceeds a threshold (`Vth`), the neuron fires a spike and resets to a resting potential (`Vrest`)

This project implements the LIF model as a **digital hardware circuit** using a controller–datapath architecture with fixed-point arithmetic (**Q4.8** format — 4 integer bits, 8 fractional bits, 12-bit signed total).

### LIF Neuron Equation

```
V[n] = V[n-1] - V[n-1]/4 + Vrest/4 + I[n]

where:
    I[n] = Σ (spike[i] × w[i])    for i = 0..7

if V[n] ≥ Vth  →  spike_out = 1, V[n] = Vrest
else           →  spike_out = 0, V[n] = V[n] (unchanged)
```

---

## 🏗️ Architecture

The design follows a classic **Controller–Datapath** decomposition:

```
                    ┌──────────────────────────────────┐
                    │           LIF (Top Module)        │
                    │                                    │
  input_spikes ────►│   ┌────────────┐  ┌────────────┐  │───► spike_out
  Vth, Vrest   ────►│   │  Datapath  │◄─┤ Controller │  │───► valid
  start        ────►│   │            │──►│   (FSM)    │  │
  clk, rst     ────►│   └────────────┘  └────────────┘  │
                    └──────────────────────────────────┘
```

### Controller (FSM)

A **19-state** Finite State Machine (`S0`–`S18`) orchestrates the entire computation sequence:

| State(s) | Operation |
|---|---|
| `S0` | **Idle** — Waits for `start` signal; asserts `valid` |
| `S1` | **Load Inputs** — Loads `Vrest`, `Vth` (if enabled), and input spike vector |
| `S2` | **Conditional Load V** — Loads `V[n-1]` or `Vrest` based on previous spike output |
| `S3`–`S4` | **Leakage Subtraction** — Computes `V[n-1] >> 2` then `V[n-1] - V[n-1]/4` |
| `S5` | **Store Leaky V** — Updates `V[n]` with the leaked value |
| `S6`–`S7` | **Rest Addition** — Computes `Vrest >> 2` then `V[n] + Vrest/4` |
| `S8` | **Store Updated V** — Updates `V[n]` again |
| `S9` | **Initialize Accumulation** — Resets counter `i` and accumulator `I[n]` to zero |
| `S10` | **Weighted Accumulation** — Computes `I[n] + w[i]` via ALU |
| `S11` | **Conditional Accumulate** — If `spike[i] == 1`, stores result in `I[n]`; increments `i` |
| `S18` | **Loop/Continue** — Bridges accumulation loop (back to `S10` if `co == 0`) |
| `S12`–`S13` | **Add Current** — `V[n] = V[n] + I[n]` |
| `S14` | **Threshold Compare** — `V[n] >= Vth ?` |
| `S16` | **Latch Spike** — Records comparison result as spike output |
| `S17` | **Conditional Reset** — If spiked, resets `V[n]` to `Vrest` |

### Datapath Components

| Module | File | Description |
|---|---|---|
| `register_12` | `reg12.sv` | 12-bit signed register with load and init |
| `register_8` | `reg8.sv` | 8-bit register for input spike vector |
| `dff` | `dff.sv` | D flip-flop for spike output latch |
| `counter_3` | `counter3.sv` | 3-bit counter with carry (iterates over 8 weights) |
| `rom` | `rom.sv` | 8-entry ROM for synaptic weights (loaded from `Weights.mif`) |
| `alu12` | `alu.sv` | 12-bit signed ALU (add, subtract, arithmetic shift right ×2, compare) |
| `mux4to1` | `mux4to1.sv` | 4-to-1 multiplexer (×3 instances for operand selection) |
| `mux2to1` | `mux2to1.sv` | 2-to-1 multiplexer |

### Datapath Register Map

| Register | Width | Purpose |
|---|---|---|
| `v_n` | 12-bit signed | Membrane potential V[n] |
| `v_rest` | 12-bit signed | Resting potential |
| `v_th` | 12-bit signed | Threshold potential |
| `i_n` | 12-bit signed | Accumulated weighted input current |
| `aluOut` | 12-bit signed | ALU output buffer |
| `spike` | 8-bit | Input spike vector |
| `spike_out_reg` | 1-bit | Output spike latch |
| `i_counter` | 3-bit | Weight/synapse index counter |

### ALU Operations

| `sel` | Operation | Usage |
|---|---|---|
| `00` | `A + B` | Addition (current accumulation, voltage update) |
| `01` | `A - B` | Subtraction (leakage) |
| `10` | `A >>> 2` | Arithmetic right shift by 2 (÷4 for decay factor) |
| `11` | `A ≥ B ? 1 : 0` | Comparison (threshold check) |

---

## 📁 File Structure

```
CA1/
├── LIF.sv                  # Top-level module (wires controller + datapath)
├── datapath.sv             # Datapath with all registers, MUXes, ALU, ROM, counter
├── controller.sv           # 19-state FSM controller
├── alu.sv                  # 12-bit signed ALU (add/sub/shift/compare)
├── rom.sv                  # 8-entry weight ROM (reads Weights.mif)
├── counter3.sv             # 3-bit counter with carry
├── reg12.sv                # 12-bit signed register with load/init
├── reg8.sv                 # 8-bit register
├── dff.sv                  # D flip-flop
├── mux4to1.sv              # 4-to-1 multiplexer (12-bit signed)
├── mux2to1.sv              # 2-to-1 multiplexer (12-bit signed)
├── LIF_tb.sv               # Testbench — feeds 20 timesteps, logs V[n] and spikes
├── Weights.mif             # Synaptic weight values (8 × 12-bit binary)
├── Test_Config_New.csv     # Test configuration (Vth, Vrest values)
├── Test_New.csv            # Expected test results (input_spikes, spike_out, membrane_potential)
├── v_n_log.txt             # Simulation output — membrane potential per timestep
├── spike_log.txt           # Simulation output — spike events with timestamps
├── coded.m                 # MATLAB script for parsing logs and plotting results
├── Figure_1.png            # Plot: Membrane Voltage vs Sample Index (Q4.8)
├── Figure_2.png            # Plot: Output Spike vs Sample Index
├── CA#01.pdf               # Project specification / assignment description
└── CA01-810102443-810102530.pdf  # Handwritten report with diagrams and analysis
```

---

## ⚙️ Configuration

### Fixed-Point Format: Q4.8

All voltage and weight values use **Q4.8 signed fixed-point** representation:
- **12 bits total** — 1 sign + 3 integer + 8 fractional
- To convert to real value: `real_value = signed_integer / 256`

### Test Parameters

| Parameter | Binary (12-bit) | Decimal (Q4.8) |
|---|---|---|
| **Vth** (threshold) | `000100000000` | +1.0 |
| **Vrest** (resting) | `111111100110` | −0.1015625 |

### Synaptic Weights (from `Weights.mif`)

| Index | Binary | Decimal (Q4.8) |
|---|---|---|
| w[0] | `000000000110` | 0.0234 |
| w[1] | `000000011111` | 0.1211 |
| w[2] | `000000000111` | 0.0273 |
| w[3] | `000000001100` | 0.0469 |
| w[4] | `000000010001` | 0.0664 |
| w[5] | `000000101100` | 0.1719 |
| w[6] | `000000100010` | 0.1328 |
| w[7] | `000000011100` | 0.1094 |

---

## 🧪 Simulation & Verification

### Running the Simulation

The testbench (`LIF_tb.sv`) is designed for **ModelSim / QuestaSim**:

```tcl
# Compile all sources
vlog *.sv

# Run simulation
vsim work.LIF_tb
run -all
```

### Testbench Behavior

The testbench:
1. Applies a reset pulse
2. Sets `Vth = 1.0` and `Vrest = -0.1015625` (Q4.8)
3. Feeds **20 consecutive input spike vectors** (8-bit each), pulsing `start` for each
4. Logs membrane potential (`v_n_log.txt`) and output spikes (`spike_log.txt`) at each timestep

### Test Vectors (20 timesteps)

| Step | Input Spikes | Expected Spike | Expected V[n] |
|---|---|---|---|
| 1 | `11111011` | 0 | `000010010010` |
| 2 | `00011010` | 0 | `000010100011` |
| 3 | `00010001` | 0 | `000010001011` |
| 4 | `00000010` | 0 | `000010000001` |
| 5 | `01010111` | 0 | `000010111001` |
| 6 | `00111101` | 0 | `000011011010` |
| 7 | `10011100` | 0 | `000011011101` |
| 8 | `01011110` | **1** 🔥 | `111111100110` (reset to Vrest) |
| 9 | `01110000` | 0 | `000001000101` |
| 10 | `10101010` | 0 | `000010100000` |
| 11 | `10101110` | 0 | `000011101011` |
| 12 | `00000101` | 0 | `000010110111` |
| 13 | `11110111` | **1** 🔥 | `111111100110` (reset to Vrest) |
| 14 | `10100111` | 0 | `000001011010` |
| 15 | `11110000` | 0 | `000010111000` |
| 16 | `10100010` | 0 | `000011101010` |
| 17 | `10101010` | **1** 🔥 | `111111100110` (reset to Vrest) |
| 18 | `10110110` | 0 | `000001100101` |
| 19 | `00010000` | 0 | `000001010110` |
| 20 | `00001100` | 0 | `000001001101` |

> The neuron fires at timesteps **8, 13, and 17** — exactly when `V[n]` crosses the threshold of 1.0.

### MATLAB Visualization

The `coded.m` script parses simulation outputs and generates two plots:

- **Figure 1** — Membrane voltage over time (shows the integrate-leak-fire-reset pattern)
- **Figure 2** — Output spike train (impulses at firing moments)

---

## 📊 Results

### Membrane Potential (V[n]) Over Time

The voltage builds up as weighted input currents are accumulated, leaks slightly each cycle, and drops sharply to `Vrest` whenever a spike fires:

<p align="center">
  <img src="Figure_1.png" alt="Membrane Voltage vs Sample Index" width="700"/>
</p>

### Output Spike Train

Spikes occur at timesteps **8**, **13**, and **17** — corresponding to the moments the membrane potential crosses the threshold:

<p align="center">
  <img src="Figure_2.png" alt="Output Spike vs Sample Index" width="700"/>
</p>

---

## 🔧 Tools Used

| Tool | Purpose |
|---|---|
| **ModelSim / QuestaSim** | RTL simulation & waveform verification |
| **MATLAB** | Post-processing simulation logs & generating plots |
| **SystemVerilog** | Hardware description language |

---

## 📝 Key Design Decisions

- **Structural decomposition** — Every component (registers, MUXes, ALU, ROM, counter) is a separate module; no behavioral shortcuts in the datapath
- **Arithmetic right shift (`>>>`)** — Used for divide-by-4 in the decay calculation, preserving the sign bit for negative voltages
- **Conditional accumulation** — Weights are only added to `I[n]` when the corresponding input spike bit is `1`, implemented via the `s` signal from the spike register
- **Q4.8 fixed-point** — Provides 8 bits of fractional precision (resolution of ~0.0039) while keeping the total width at 12 bits for area efficiency
- **Separate enable signals** — `Vth_en` and `Vrest_en` allow dynamic configuration of threshold and resting potentials without modifying the design
