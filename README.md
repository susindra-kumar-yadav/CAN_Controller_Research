# CAN 2.0A Controller for Automotive ECUs



## Project Overview



A research-oriented RTL design and functional verification project for a Classic CAN 2.0A controller used for communication between electronic control units (ECUs) in electric vehicles.



## Research Objective



Study how CAN controller architecture choices affect hardware area, timing, and verification effort under consistent experimental conditions.



## Planned Features



* 11-bit standard CAN identifiers

* Transmit and receive engines

* CRC-15 generation and checking

* Bit stuffing and destuffing

* Bus arbitration and ACK handling

* Configurable bit timing

* Basic protocol error detection

* SystemVerilog verification with assertions, randomized tests, and fault injection

* Synthesis-based area and timing evaluation



## Research Experiments



* Compare bit-serial and parallel CRC implementations.

* Record area and timing using consistent synthesis settings.

* Measure verification coverage and document limitations.



## Technology Stack



* Verilog HDL

* SystemVerilog

* Vivado or another suitable synthesis/simulation tool

* Waveform viewer

* Git and GitHub



## Repository Structure



* `rtl/` — synthesizable hardware modules

* `testbench/` — testbenches and verification components

* `docs/` — architecture, research notebook, and documentation

* `experiments/` — synthesis results and experiment records

* `waveforms/` — selected simulation waveforms



## Project Status



**Phase 1:** CAN fundamentals and project definition.



The controller is planned work; implementation and performance results will be documented after they are completed and tested.



## Research Paper — Working Title



*An RTL-Based Study of Area, Timing, and Verification Trade-offs in CAN 2.0A Controllers for Automotive ECUs*



