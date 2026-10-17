
`timescale 1ns/1ps

module can_controller_top_tb;

    reg clk;
    reg rst_n;
    reg tx_start;
    reg [10:0] can_id;
    reg [3:0] dlc;
    reg [63:0] data;

    wire tx_busy;
    wire tx_done;
    wire tx_serial;

    can_controller_top dut (
        .clk(clk),
        .rst_n(rst_n),
        .tx_start(tx_start),
        .can_id(can_id),
        .dlc(dlc),
        .data(data),
        .tx_busy(tx_busy),
        .tx_done(tx_done),
        .tx_serial(tx_serial)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        tx_start = 1'b0;
        can_id = 11'h123;
        dlc = 4'd1;
        data = 64'hA500000000000000;

        // Apply reset
        #12;
        rst_n = 1'b1;

        // Request transmission
        @(negedge clk);
        tx_start = 1'b1;

        @(negedge clk);
        tx_start = 1'b0;

        // Wait until frame construction completes
        repeat (3) @(negedge clk);

        // Check SOF
        if (dut.frame_bits[82] !== 1'b0)
            $fatal(1, "FAIL: SOF bit incorrect");

        // Check 11-bit identifier
        if (dut.frame_bits[81:71] !== 11'h123)
            $fatal(1, "FAIL: Identifier incorrect");

        // Check RTR, IDE and reserved bit
        if (dut.frame_bits[70:68] !== 3'b000)
            $fatal(1, "FAIL: Control fields incorrect");

        // Check DLC
        if (dut.frame_bits[67:64] !== 4'd1)
            $fatal(1, "FAIL: DLC incorrect");

        // Check first payload byte
        if (dut.frame_bits[63:56] !== 8'hA5)
            $fatal(1, "FAIL: Payload incorrect");

        // Check valid logical frame length
        if (dut.frame_length !== 7'd27)
            $fatal(1, "FAIL: Frame length incorrect");

        $display("PASS: SOF check");
        $display("PASS: Identifier check");
        $display("PASS: Control field check");
        $display("PASS: DLC check");
        $display("PASS: Payload check");
        $display("PASS: Frame length check");
        $display("ALL FRAME STORAGE TESTS PASSED");

        $finish;
    end

endmodule
