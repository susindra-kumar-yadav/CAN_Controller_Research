`timescale 1ns/1ps

module can_tx_fsm_selfcheck_tb;

    reg clk;
    reg rst_n;
    reg tx_start;
    wire tx_busy;
    integer errors;

    can_tx_fsm dut (
        .clk(clk),
        .rst_n(rst_n),
        .tx_start(tx_start),
        .tx_busy(tx_busy)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("waveforms/can_tx_fsm_selfcheck.vcd");
        $dumpvars(0, can_tx_fsm_selfcheck_tb);
    end

    initial begin
        $monitor("Time=%0t | rst_n=%b | tx_start=%b | tx_busy=%b",
                 $time, rst_n, tx_start, tx_busy);
    end

    initial begin
        clk = 0;
        rst_n = 0;
        tx_start = 0;
        errors = 0;

        // Test 1: Reset
        repeat (2) @(negedge clk);
        if (tx_busy !== 1'b0) begin
            $display("FAIL: tx_busy should be 0 during reset");
            errors = errors + 1;
        end

        rst_n = 1;

        // Test 2: Start transmission
        @(negedge clk);
        tx_start = 1;
        @(posedge clk);
        #1;
        if (tx_busy !== 1'b1) begin
            $display("FAIL: tx_busy should become 1 after start");
            errors = errors + 1;
        end

        // Remove start request; transmission should continue
        @(negedge clk);
        tx_start = 0;

        // Test 3: Busy must remain high during transmission
        repeat (4) begin
            @(posedge clk);
            #1;
            if (tx_busy !== 1'b1) begin
                $display("FAIL: tx_busy dropped too early");
                errors = errors + 1;
            end
        end

        // Test 4: Wait for transmission completion
        wait (tx_busy === 1'b0);
        @(posedge clk);
        #1;

        if (tx_busy !== 1'b0) begin
            $display("FAIL: tx_busy should be 0 after completion");
            errors = errors + 1;
        end

        if (errors == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED: %0d error(s)", errors);

        $finish;
    end

endmodule