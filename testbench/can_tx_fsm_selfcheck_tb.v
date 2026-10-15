`timescale 1ns/1ps

module can_tx_fsm_selfcheck_tb;

    reg  clk;
    reg  rst_n;
    reg  tx_start;
    wire tx_busy;
    integer errors;

    can_tx_fsm dut (
        .clk(clk),
        .rst_n(rst_n),
        .tx_start(tx_start),
        .tx_busy(tx_busy)
    );

    // 10 ns clock period
    always #5 clk = ~clk;

    // Waveform file
    initial begin
        $dumpfile("waveforms/can_tx_fsm_selfcheck.vcd");
        $dumpvars(0, can_tx_fsm_selfcheck_tb);
    end

    // Print signal changes
    initial begin
        $monitor("Time=%0t | clk=%b | rst_n=%b | tx_start=%b | tx_busy=%b",
                 $time, clk, rst_n, tx_start, tx_busy);
    end

    // Stimulus and self-checking
    initial begin
        clk = 0; rst_n = 0; tx_start = 0; errors = 0;

        // Reset
        repeat (2) @(negedge clk);
        rst_n = 1;
        @(negedge clk);

        // Test 1: idle after reset
        if (tx_busy !== 1'b0) begin
            $display("FAIL 1: tx_busy should be 0 after reset");
            errors = errors + 1;
        end

        // Test 2: start request makes tx_busy go high
        tx_start = 1;
        @(posedge clk); #1;
        if (tx_busy !== 1'b1) begin
            $display("FAIL 2: tx_busy did not go high after tx_start");
            errors = errors + 1;
        end

        // Test 3: tx_busy returns to 0 after tx_start is removed
        @(negedge clk);
        tx_start = 0;
        @(posedge clk); #1;
        if (tx_busy !== 1'b0) begin
            $display("FAIL 3: tx_busy did not return to 0");
            errors = errors + 1;
        end

        // Test 4: holding tx_start keeps tx_busy high
        @(negedge clk);
        tx_start = 1;
        repeat (3) begin
            @(posedge clk); #1;
            if (tx_busy !== 1'b1) begin
                $display("FAIL 4: tx_busy dropped while tx_start was held");
                errors = errors + 1;
            end
        end
        @(negedge clk);
        tx_start = 0;

        repeat (2) @(posedge clk);

        // Result
        if (errors == 0) $display("TEST PASSED");
        else             $display("TEST FAILED: %0d error(s)", errors);

        $finish;
    end

endmodule