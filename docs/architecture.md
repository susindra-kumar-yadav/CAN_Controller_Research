# CAN 2.0A Controller — Architecture



## 1. Design Scope



* Protocol: Classic CAN 2.0A

* Identifier: 11-bit standard identifier

* Payload: 0–8 bytes

* RTL language: Verilog HDL

* Verification: SystemVerilog testbench

* Physical CAN transceiver: Out of scope



## 2. Top-Level Interface — To Be Finalized



### Clock and Reset



* `clk` — system clock

* `rst_n` — active-low reset



### CAN Bus Interface



* `can_tx` — digital transmit signal to the external transceiver

* `can_rx` — digital receive signal from the external transceiver



### Transmit Request



* `tx_id` — 11-bit identifier

* `tx_dlc` — 4-bit data length code

* `tx_data` — 64-bit payload storage for up to 8 bytes

* `tx_valid` — indicates a transmit request is available

* `tx_ready` — indicates the controller can accept a request



### Receive Output



* `rx_id` — received 11-bit identifier

* `rx_dlc` — received data length code

* `rx_data` — received payload

* `rx_valid` — indicates a received frame is available



### Status



* `busy` — controller is transmitting or receiving

* `tx_done` — transmission completed

* `error_flag` — indicates a detected protocol error



### Bit Timing Configuration



* `prescaler` — clock division setting

* `sample_point` — sampling configuration, to be finalized during design



## 3. Planned Internal Modules



1. Bit timing generator

2. CRC-15 generator/checker

3. Bit stuffer

4. Bit destuffer

5. Transmit state machine

6. Receive state machine

7. Arbitration and ACK handling

8. Error detection and status



## 4. Design Decisions to Resolve



* Exact bit timing and sample-point behavior

* CRC module interface

* TX/RX state-machine boundaries

* Message buffering and handshake behavior

* Error reporting and recovery policy



## 5. Implementation Status



Architecture specification started. No implementation or synthesis results are claimed yet.



