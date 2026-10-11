# CAN 2.0A Controller: Research Notebook



## Day 1: CAN Fundamentals and Project Definition



### 1. Project and paper



**Project:** RTL Design and Functional Verification of a CAN 2.0A Controller for Inter-ECU Communication in Electric Vehicles



**Paper:** An RTL-Based Study of Area, Timing, and Verification Trade-offs in CAN 2.0A Controllers for Automotive ECUs



### 2. Motivation



An electric vehicle contains many Electronic Control Units (ECUs): battery management (BMS), motor control, thermal management and charging. They must exchange data reliably over shared wiring. The Controller Area Network (CAN) is the protocol that lets them do this on a single two-wire bus.



This project designs the digital CAN 2.0A controller in Verilog and verifies it with SystemVerilog testbenches. Fig. 1 shows where it sits in the vehicle.



### 3. Key ideas of CAN



- **Multi-master, no central controller.** Every node is equal and any node may transmit when the bus is idle.

- **Message-based.** Frames carry an identifier (ID), not a destination address. Every node receives every frame and decides whether it needs it.

- **Priority comes from the ID.** A lower ID number means higher priority.

- **Differential bus (CAN_H / CAN_L)**, with 120 Ω termination at the two ends of the bus only.

- **Dominant (logic 0) beats recessive (logic 1)** when nodes drive the bus at once (wired-AND behavior).

- Classic CAN carries 0 to 8 data bytes per frame.



### 4. Controller vs transceiver



| | CAN controller (this project) | CAN transceiver (out of scope) |

|---|---|---|

| Nature | Digital protocol hardware | Interface to the physical bus |

| Job | Frames, CRC, stuffing, arbitration, ACK, timing | Digital TX/RX signals to and from differential bus levels |

| Signals | MCU interface, CAN_TX, CAN_RX | CAN_TX, CAN_RX, CAN_H, CAN_L |



### 5. CAN 2.0A standard data frame



| Field | Bits | Notes |

|---|---|---|

| SOF | 1 | Dominant; starts the frame |

| Identifier | 11 | Used for arbitration |

| RTR | 1 | Dominant for a data frame |

| IDE | 1 | Dominant for the standard 11-bit format |

| r0 | 1 | Reserved |

| DLC | 4 | Number of data bytes (0 to 8) |

| Data | 0 to 64 | 0 to 8 bytes |

| CRC | 15 | CRC-15 sequence |

| CRC delimiter | 1 | Recessive |

| ACK slot | 1 | Transmitter sends recessive; receivers drive dominant |

| ACK delimiter | 1 | Recessive |

| EOF | 7 | Recessive |

| IFS | 3 | Interframe space |



The longest frame is 108 bits before stuffing (excluding IFS).



### 6. Three protocol mechanisms



**Arbitration.** Each transmitter sends its ID MSB first and compares every sent bit with the bit it reads back. A node that sends recessive but reads dominant has lost: it stops transmitting and becomes a receiver. The winning frame is never corrupted.



**Bit stuffing.** After 5 identical consecutive bits, the transmitter inserts one opposite bit. Stuffing applies from SOF through the CRC sequence, and not to the CRC delimiter, ACK field or EOF. The receiver removes the stuff bits (destuffing). Six identical bits in a row on the stuffed region is a stuff error.



**CRC-15.** The polynomial is x^15 + x^14 + x^10 + x^8 + x^7 + x^4 + x^3 + 1 (0x4599). It is computed over SOF through the data field, before stuffing. The receiver recomputes it and compares.



### 7. Controller architecture (Fig. 2)



- **MCU interface:** message in, received data out, status.

- **TX engine:** frame assembly, CRC generation, stuffing.

- **RX engine:** destuffing, frame decode, CRC check.

- **Arbitration and ACK:** compares the sent bit with the bus bit, and handles the ACK slot.

- **Bit timing (shared):** baud divider and sample point, used by TX, RX and arbitration.

- **Transceiver interface:** CAN_TX out, CAN_RX in.

- **Error handling:** stuff, CRC, form and ACK errors; counters are an extension.



### 8. Objectives



1. Design a CAN 2.0A controller in Verilog HDL.

2. Implement the transmit and receive paths.

3. Implement CRC-15 generation and checking.

4. Implement bit stuffing and destuffing.

5. Implement arbitration, ACK handling and configurable bit timing.

6. Build SystemVerilog testbenches, including a two-node bus model.

7. Verify with simulation, waveform analysis and coverage.

8. Synthesize and record area and timing.

9. Compare design variants under equal synthesis conditions.



### 9. Research direction



Question: how do architecture choices change area and timing of a CAN controller, and what does it cost to verify them?



Planned comparison:

- Bit-serial CRC vs parallel CRC.

- Optional: different message-buffer architectures.



Rules for a fair result:

- Same protocol behavior, same constraints, same tool and device.

- Claim an improvement only if the measurements show it.

- Verification coverage shows quality of testing, not hardware efficiency.



### 10. Scope



**Included:** 11-bit standard frames, TX and RX, CRC-15, stuffing and destuffing, arbitration, ACK, configurable bit timing, basic error detection, functional verification, synthesis evaluation.



**Extension:** error counters and recovery, additional buffer variants.



**Excluded:** CAN 2.0B (29-bit IDs), CAN FD, analog transceiver design, automotive qualification.



### 11. Tools



- **Verilog HDL:** RTL design

- **SystemVerilog testbenches:** a simulator with good SystemVerilog support (ModelSim/Questa or Vivado xsim). Icarus Verilog has limited SystemVerilog support, so use it for plain Verilog testbenches.

- **GTKWave or the simulator's viewer:** waveform inspection

- **Vivado:** synthesis and timing reports

- **Git and GitHub:** version control and documentation



### 12. Planned build order



1. Bit timing

2. CRC-15 module

3. Stuffer and destuffer

4. TX FSM

5. RX FSM

6. Arbitration, then ACK

7. Two-node testbench

8. Synthesis runs and the paper experiment



### 13. Day 1 self-check



- [ ] Draw one standard frame from memory with bit widths.

- [ ] Explain why the lowest ID wins arbitration.

- [ ] Mark where stuffing starts and stops.

- [ ] Explain controller vs transceiver in one sentence.



### 14. Day 1 conclusion



I learned how CAN lets ECUs share one bus, the structure of a 2.0A data frame, and how arbitration, stuffing and CRC work. I defined the scope, architecture, tools and research question.



**Day 2:** define the controller's ports (MCU side, CAN_TX, CAN_RX, configuration), then start the bit timing module.

