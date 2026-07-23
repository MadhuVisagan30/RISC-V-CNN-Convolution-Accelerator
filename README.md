# RISC-V CNN Convolution Accelerator

A custom **32-bit RISC-V processor implemented in Verilog HDL** for image convolution and Sobel edge detection.

The project demonstrates the execution of a **3×3 Sobel convolution on a 32×32 grayscale image using a custom RISC-V processor**. Python scripts generate the RISC-V instruction stream for Sobel-X and Sobel-Y processing, while the processor executes the required load, multiplication, addition, and store operations.

The repository also contains earlier non-RISC-V convolution experiments performed on larger 64×64 and 490×490 images using a direct Verilog convolution module.

---

## Project Overview

The main implementation processes a **32×32 grayscale image** using a custom 32-bit RISC-V processor.

A valid 3×3 convolution is performed without padding. Therefore:

```text
Input image  : 32 × 32
Kernel       : 3 × 3
Output image : 30 × 30
Output pixels: 900
```

The overall processing flow is:

```text
Input Image
     ↓
Convert Image to Memory Data
     ↓
DOG_32.mem
     ↓
Python RISC-V Instruction Generator
     ↓
program.mem
     ↓
Instruction Memory
     ↓
Custom 32-bit RISC-V Processor
     ↓
Load Pixels → Multiply → Accumulate → Store
     ↓
Sobel-X / Sobel-Y Results
     ↓
output_x_30.mem / output_y_30.mem
     ↓
Python Post-Processing
     ↓
DOG_30_output.png
```

---

## Repository Structure

```text
RISC-V-CNN-Convolution-Accelerator/
│
├── Documents/
│   ├── MAC_architecture.png
│   ├── RISC-V_architecture.png
│   └── WORKFLOW.png
│
├── Memory/
│   ├── DOG_32.mem
│   ├── output_x_30.mem
│   └── output_y_30.mem
│
├── NON RISCV based Previous Experiments/
│   ├── DOG_490.png
│   ├── DOG_64.png
│   ├── DOG_SOBEL_488.png
│   ├── DOG_SOBEL_62.png
│   ├── conv_pixel.v
│   └── conv_pixel_tb.v
│
├── PYTHON/
│   ├── generate_program_sobel_x.py
│   ├── generate_program_sobel_y.py
│   └── mem_to_pngg.py
│
├── RESULTS/
│   ├── DOG_30_output.png
│   └── DOG_32_input.png
│
├── RTL/
│   ├── alu.v
│   ├── control_unit.v
│   ├── data_memory.v
│   ├── data_path.v
│   ├── instruction_fetch_unit.v
│   ├── instruction_memory.v
│   ├── mac_pp.v
│   ├── register_file.v
│   ├── simd_alu.v
│   └── top_riscv.v
│
├── TESTBENCH/
│   └── top_riscv_tb.v
│
└── README.md
```

---

## Custom RISC-V Processor

The processor is a custom **32-bit RISC-V architecture written in Verilog HDL**.

The main processor modules are located in the `RTL` directory.

### `top_riscv.v`

Top-level module connecting the major processor components.

### `instruction_fetch_unit.v`

Contains the Program Counter and instruction-fetch control logic.

### `instruction_memory.v`

Stores the RISC-V machine instructions generated for the convolution operation.

### `control_unit.v`

Decodes the RISC-V instruction opcode, `funct3`, and `funct7` fields and generates the required control signals.

### `register_file.v`

Implements the 32-entry RISC-V register file.

### `alu.v`

Performs arithmetic and logical operations including:

- Addition
- Subtraction
- Shift operations
- Logical operations
- Comparisons
- Multiplication
- MAC operation

### `data_memory.v`

Stores the grayscale input image and convolution results.

### `data_path.v`

Connects the register file, ALU, data memory, and control signals to form the processor datapath.

### `mac_pp.v`

Implements the Multiply-Accumulate operation:

```text
result = (a × b) + acc
```

### `simd_alu.v`

Contains the experimental SIMD arithmetic unit for parallel 8-bit operations.

---

## Sobel Convolution

Sobel edge detection is used as the convolution workload.

Two 3×3 kernels are used.

### Sobel-X

```text
-1   0   1
-2   0   2
-1   0   1
```

Sobel-X primarily detects changes in the horizontal intensity direction, highlighting vertical edges.

### Sobel-Y

```text
-1  -2  -1
 0   0   0
 1   2   1
```

Sobel-Y detects changes in the vertical intensity direction, highlighting horizontal edges.

The two results are subsequently combined during Python post-processing to generate the final edge-detected image.

---

## RISC-V Based 32×32 Convolution

The input image is stored in:

```text
Memory/DOG_32.mem
```

The image contains:

```text
32 × 32 = 1024 pixels
```

For every valid 3×3 window, the processor performs the equivalent of:

```text
Load pixels
    ↓
Multiply pixels by Sobel coefficients
    ↓
Add partial convolution results
    ↓
Store convolution result
```

Because no padding is used:

```text
32 - 3 + 1 = 30
```

Therefore the convolution generates a **30×30 output containing 900 pixels**.

---

## Automatic RISC-V Instruction Generation

Manually writing the instruction sequence for all 900 convolution windows would require thousands of instructions.

Python scripts are therefore used to automatically generate the required RISC-V machine instructions.

### Sobel-X Generator

```text
PYTHON/generate_program_sobel_x.py
```

Generates the RISC-V instructions required for Sobel-X convolution.

### Sobel-Y Generator

```text
PYTHON/generate_program_sobel_y.py
```

Generates the corresponding instruction sequence for Sobel-Y convolution.

The generated instructions are loaded into the processor's Instruction Memory and executed sequentially.

For each convolution window, the generated program performs approximately:

```text
LB
LB
LB
LB
LB
LB
 ↓
MUL operations
 ↓
ADD operations
 ↓
SW
```

The zero-valued Sobel coefficients do not require multiplication, reducing the number of operations required for each window.

---

## Convolution Output

The processor-generated convolution outputs are stored as:

```text
Memory/output_x_30.mem
Memory/output_y_30.mem
```

Each file represents a **30×30 convolution result**.

The Python script:

```text
PYTHON/mem_to_pngg.py
```

processes the memory results and reconstructs the final edge-detected image.

The final result is available at:

```text
RESULTS/DOG_30_output.png
```

The original 32×32 input image is:

```text
RESULTS/DOG_32_input.png
```

---

## Simulation

The processor is verified using:

```text
TESTBENCH/top_riscv_tb.v
```

The testbench provides the processor clock and reset and allows the execution of the generated convolution program to be observed.

During simulation, the processor performs the complete sequence of RISC-V instructions required for convolution and writes the resulting pixels into Data Memory.

The stored output values can then be exported and processed using Python.

---

## Previous Non-RISC-V Experiments

Before integrating convolution with the RISC-V processor, convolution was tested directly using Verilog.

These experiments are preserved in:

```text
NON RISCV based Previous Experiments/
```

The convolution implementation is contained in:

```text
conv_pixel.v
conv_pixel_tb.v
```

### 64×64 Experiment

```text
Input:
DOG_64.png

Output:
DOG_SOBEL_62.png
```

A 3×3 valid convolution produces:

```text
64 - 3 + 1 = 62
```

Therefore:

```text
64×64 input → 62×62 output
```

### 490×490 Experiment

```text
Input:
DOG_490.png

Output:
DOG_SOBEL_488.png
```

Similarly:

```text
490 - 3 + 1 = 488
```

Therefore:

```text
490×490 input → 488×488 output
```

The `conv_pixel.v` implementation extracts each 3×3 image window and passes the nine pixel/kernel pairs through a chain of `mac_pp` modules.

These experiments were performed independently of the RISC-V processor and served as earlier validation of the convolution operation.

---

## Architecture Diagrams

Architecture and workflow diagrams are provided in the `Documents` directory.

### RISC-V Architecture

```text
Documents/RISC-V_architecture.png
```

Shows the organization of the custom RISC-V processor and its major hardware modules.

### MAC Architecture

```text
Documents/MAC_architecture.png
```

Shows the Multiply-Accumulate architecture used by `mac_pp.v`.

### Processing Workflow

```text
Documents/WORKFLOW.png
```

Shows the overall image-to-memory, RISC-V convolution, and output-image reconstruction workflow.

---

## Tools and Technologies

- Verilog HDL
- RISC-V
- Xilinx Vivado
- Python
- FPGA
- Digital Image Processing
- Sobel Edge Detection
- Multiply-Accumulate Arithmetic
- Visual Studio Code

The processor design is intended for FPGA implementation and experimentation with hardware acceleration of CNN-style convolution operations.

---

## Current Project Status

The repository currently demonstrates:

- Custom 32-bit RISC-V processor implementation
- RISC-V instruction execution
- Image storage in processor Data Memory
- Automatic convolution instruction generation using Python
- 3×3 Sobel-X convolution
- 3×3 Sobel-Y convolution
- 32×32 input image processing
- 30×30 convolution output generation
- Reconstruction of processor output into an image
- Direct Verilog convolution experiments for 64×64 and 490×490 images
- MAC-based convolution experimentation

The current implementation focuses on the **convolution stage** rather than a complete trained CNN inference network.

---

## Future Work

Future development can extend the current processor toward a complete CNN accelerator through:

- Dedicated MAC acceleration instructions
- SIMD-based convolution
- Pipelined MAC architecture
- Dadda multiplier integration
- ReLU activation
- Pooling
- Fully connected layers
- CNN model parameter storage
- Complete CNN inference on the custom RISC-V processor
- FPGA performance and resource analysis

---

## Project Evolution

```text
Direct Verilog Convolution
        │
        ├── 64×64 → 62×62
        │
        └── 490×490 → 488×488
                    ↓
           RISC-V Integration
                    ↓
             32×32 Input
                    ↓
        Python Instruction Generation
                    ↓
        Custom RISC-V Execution
                    ↓
             Sobel-X + Sobel-Y
                    ↓
              30×30 Output
                    ↓
          Edge-Detected Image
                    ↓
        Future Complete CNN System
```

---

## Author

**Madhu Visagan H T**

Electronics and Communication Engineering

---

## Note

This repository documents an ongoing hardware-acceleration project. The currently validated RISC-V image-processing implementation performs Sobel convolution. Additional CNN acceleration architectures and complete CNN inference support are planned as future extensions.
