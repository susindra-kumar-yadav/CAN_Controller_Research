

# Day 3: CAN Transmitter State Machine and Error Handling

**Project Title:** RTL Design and Functional Verification of a CAN Bus Controller for Inter-ECU Communication in Electric Vehicle Systems

**Technology:** Verilog HDL  
**Application:** Automotive Electronics and Electric Vehicles  
**Learning Stage:** CAN Controller RTL Design — Day 3

---

## 1. Objective

The objective of this lesson is to understand how a CAN transmitter controls the sequence of operations required to transmit a CAN frame.

We will learn:
- What a Finite State Machine (FSM) is.
- The different states of a CAN transmitter.
- How a CAN frame is transmitted.
- How acknowledgment and errors are handled.
- How to prepare for implementing the state machine in Verilog.

## 2. What Is a Finite State Machine?

A **Finite State Machine (FSM)** is a digital circuit design technique in which a system moves between predefined states according to inputs and conditions.

For example, a CAN transmitter cannot send every part of a frame simultaneously. It must transmit the fields in the correct sequence.

Therefore, we can use an FSM to control the transmission process.

A simplified sequence is:

`IDLE → START → SEND_ID → SEND_CONTROL/DLC → SEND_DATA → SEND_CRC → WAIT_ACK → SEND_EOF → DONE`

After completion, the transmitter returns to `IDLE`.



## 3. States of the CAN Transmitter

| State | Description |
|---|---|
| `IDLE` | Waits for a transmission request. |
| `START` | Begins the frame by transmitting the Start of Frame (SOF). |
| `SEND_ID` | Transmits the CAN identifier. |
| `SEND_CONTROL` | Transmits the applicable control field. |
| `SEND_DLC` | Represents the data length information in our simplified design. |
| `SEND_DATA` | Transmits the payload data. |
| `SEND_CRC` | Transmits the calculated CRC sequence. |
| `WAIT_ACK` | Observes the acknowledgment slot. |
| `SEND_EOF` | Transmits the End of Frame sequence. |
| `DONE` | Indicates that the simplified transmission sequence has completed. |
| `ERROR_HANDLING` | Handles detected errors according to the controller's design and CAN protocol rules. |

**Important:** These are educational states, not a complete CAN 2.0A implementation. In an actual CAN controller, the control fields, CRC calculation, bit stuffing, arbitration, timing, ACK, EOF, and error handling must follow the protocol precisely.

## 4. CAN Transmitter State Machine Diagram

```text
             +-------------+
             |    IDLE     |
             +-------------+
                    |
             tx_start = 1
                    |
                    v
             +-------------+
             |    START    |
             |    Send SOF |
             +-------------+
                    |
                    v
             +-------------+
             |   SEND_ID   |
             +-------------+
                    |
                    v
          +-------------------+
          |  SEND_CONTROL/DLC |
          +-------------------+
                    |
                    v
             +-------------+
             |  SEND_DATA  |
             +-------------+
                    |
                    v
             +-------------+
             |   SEND_CRC  |
             +-------------+
                    |
                    v
             +-------------+
             |   WAIT_ACK  |
             +-------------+
                /       \
          ACK observed   ACK error
              /             \
             v               v
      +-------------+  +----------------+
      |   SEND_EOF  |  | ERROR_HANDLING |
      +-------------+  +----------------+
             |                |
             v                v
      +-------------+   Retry when
      |     DONE    |   permitted
      +-------------+
             |
             v
      +-------------+
      |    IDLE     |
      +-------------+
```

*The diagram shows a simplified learning model. A complete implementation must account for CAN protocol details, including retransmission rules and error states.*

## 5. Step-by-Step Working

### Step 1: IDLE

The transmitter waits for a request from the controlling logic.

For example, when `tx_start = 1`, the FSM can begin transmission if the controller is ready and the bus conditions permit it.

### Step 2: START

The transmitter begins the CAN frame by sending the Start of Frame bit.

For Classical CAN, SOF is a dominant bit.

### Step 3: SEND_ID

The transmitter sends the identifier.

In Classical CAN 2.0A, the base frame uses an 11-bit identifier.

The identifier also determines arbitration priority: **a lower numerical identifier has higher priority**, assuming the identifiers are competing under the same relevant arbitration conditions.

Example:

- Identifier `0x100`
- Identifier `0x200`

`0x100` has higher priority than `0x200`.

### Step 4: SEND_CONTROL/DLC

The controller transmits the applicable control fields, including the Data Length Code (DLC).

The DLC indicates the number of payload bytes in a Classical CAN data frame, from 0 to 8.

Example:

If DLC = 3, the payload contains 3 bytes.

Calculation:

`3 bytes × 8 bits = 24 bits`

### Step 5: SEND_DATA

The transmitter sends the payload one bit at a time.

If the payload contains 3 bytes, the controller transmits 24 payload bits.

### Step 6: SEND_CRC

The controller transmits the CRC sequence calculated for the frame.

CRC helps the receiver detect transmission errors. It does not guarantee that every possible error will be detected.

### Step 7: WAIT_ACK

The transmitter observes the acknowledgment slot.

If at least one receiver correctly receives the frame and participates in acknowledgment, it can drive the ACK slot dominant.

An ACK is a protocol-level acknowledgment. It does not prove that the receiving application's software has processed or permanently stored the message.

### Step 8: SEND_EOF

The transmitter sends the End of Frame sequence.

For Classical CAN, EOF consists of seven recessive bits.

### Step 9: DONE

The controller indicates that the transmission sequence is complete and returns to `IDLE` when appropriate.

A real implementation must coordinate completion with the actual protocol and controller status.

## 6. What Happens If No ACK Is Received?

If the transmitter does not observe a valid acknowledgment, it can detect an ACK error.

The controller must handle that error according to CAN protocol rules. Depending on the controller's error state and protocol conditions, retransmission may occur.

The simplified state machine does not implement the complete CAN error-management mechanism.

## 7. What Is Bit Stuffing?

CAN uses bit stuffing in specified frame regions to help maintain synchronization.

**Rule:** After five consecutive bits of the same value in a bit-stuffed region, the transmitter inserts a bit of the opposite value.

Example:

Original bit sequence:

`111110`

After stuffing:

`111110`

The fifth `1` is followed by an inserted `0`, so the actual transmitted sequence is:

`1111100`

The final `0` in this example is the original next bit.

The receiver removes the inserted stuff bits when decoding the frame.

*Note: Bit stuffing does not apply identically to every field or region of a CAN frame.*

## 8. Important Signals for Verilog Implementation

| Signal | Purpose |
|---|---|
| `clk` | Clock signal for synchronous logic. |
| `rst_n` | Active-low reset signal. |
| `tx_start` | Requests a transmission. |
| `tx_data` | Holds the payload data. |
| `tx_dlc` | Indicates payload length. |
| `busy` | Indicates that the transmitter is occupied. |
| `tx_done` | Indicates completion of transmission. |
| `error_flag` | Indicates a detected error. |
| `CANTX` | Digital transmit output toward the CAN transceiver. |
| `CANRX` | Digital receive input from the CAN transceiver. |
| `rx_data` | Holds received payload data in a controller with receive logic. |
| `rx_valid` | Indicates valid received data in a controller with receive logic. |

These are proposed RTL interface names for our project; they are not mandatory signal names defined by the CAN protocol.

## 9. Questions and Answers

**Q1. Which state waits for a transmission request?**

**Answer:** `IDLE`.

**Q2. Which state begins the CAN frame?**

**Answer:** `START`. It sends the Start of Frame (SOF).

**Q3. Which identifier has higher arbitration priority: `0x100` or `0x200`?**

**Answer:** `0x100`, because the lower numerical identifier has higher priority under the stated arbitration conditions.

**Q4. What happens after five consecutive identical bits in a bit-stuffed region?**

**Answer:** The transmitter inserts a bit of the opposite value.

**Q5. If DLC = 3, how much payload data is indicated?**

**Answer:** 3 bytes, or 24 bits.

**Q6. What may happen if no ACK is received?**

**Answer:** The transmitter detects an ACK error. Retransmission may occur according to the CAN protocol and the controller's error state.

**Q7. What does ACK mean?**

A. Protocol-level acknowledgment by at least one receiver.  
B. Proof that the application permanently stored the data.  
C. A command to delete the transmitted data.

**Correct answer: A.**

**Q8. What is the purpose of CRC?**

A. To save memory.  
B. To help detect transmission errors.  
C. To delete data.

**Correct answer: B.**

---
