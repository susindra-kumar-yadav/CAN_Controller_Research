
`timescale 1ns/1ps

module can_tx_fsm_tb;

    // Testbench signals
    reg clk;
    reg rst_n;
    reg tx_start;

    wire tx_busy;

    // Instantiate the CAN transmitter FSM
    can_tx_fsm dut (
        .clk(clk),
        .rst_n(rst_n),
        .tx_start(tx_start),
        .tx_busy(tx_busy)
    );

    // Generate a 10 ns clock period
    always #5 clk = ~clk;

    // Apply reset and transmission stimulus
    initial begin
        clk      = 1'b0;
        rst_n    = 1'b0;
        tx_start = 1'b0;

        // Create waveform file
        $dumpfile("waveforms/can_tx_fsm.vcd");
        $dumpvars(0, can_tx_fsm_tb);

        // Release reset
        #10;
        rst_n = 1'b1;

        // Start transmission
        #10;
        tx_start = 1'b1;

        // Deassert transmission request
        #10;
        tx_start = 1'b0;

        // Wait for the FSM to return to idle
        #10;

        // End simulation
        $finish;
    end

    // Display signal changes
    initial begin
        $monitor(
            "Time=%0t | clk=%b | rst_n=%b | tx_start=%b | tx_busy=%b",
            $time, clk, rst_n, tx_start, tx_busy
        );
    end

endmodule
