
`timescale 1ns/1ps

module can_frame_tx_tb;

    reg clk;
    reg rst_n;
    reg tx_start;
    reg [10:0] can_id;
    reg [3:0] dlc;
    reg [7:0] data_byte;

    wire tx_busy;
    wire tx_done;
    wire tx_serial;

    reg [23:0] expected_frame;
    integer errors;
    integer i;

    can_frame_tx dut (
        .clk(clk),
        .rst_n(rst_n),
        .tx_start(tx_start),
        .can_id(can_id),
        .dlc(dlc),
        .data_byte(data_byte),
        .tx_busy(tx_busy),
        .tx_done(tx_done),
        .tx_serial(tx_serial)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("waveforms/can_frame_tx.vcd");
        $dumpvars(0, can_frame_tx_tb);
    end

    initial begin
        clk = 0;
        rst_n = 0;
        tx_start = 0;
        can_id = 11'h123;
        dlc = 4'd1;
        data_byte = 8'hA5;
        errors = 0;
        expected_frame = {11'h123, 1'b0, 4'd1, 8'hA5};

        repeat (2) @(negedge clk);

        if (tx_busy !== 1'b0 || tx_serial !== 1'b1) begin
            $display("FAIL: Reset/idle check");
            errors = errors + 1;
        end

        rst_n = 1;
        @(negedge clk);
        tx_start = 1;
        @(negedge clk);
        tx_start = 0;

        // Wait until the payload transmission begins.
        wait (dut.state == 2'd2);

        // Sample after each rising edge and allow RTL updates to settle.
        for (i = 0; i < 24; i = i + 1) begin
            @(posedge clk);
            #1;

            if (tx_serial !== expected_frame[23-i]) begin
                $display("FAIL: Bit %0d expected=%b actual=%b",
                         i, expected_frame[23-i], tx_serial);
                errors = errors + 1;
            end
        end

        wait (tx_done === 1'b1);
        #1;

        if (tx_busy !== 1'b0) begin
            $display("FAIL: tx_busy should be low at completion");
            errors = errors + 1;
        end

        if (errors == 0)
            $display("CAN FRAME BIT CHECK PASSED");
        else
            $display("CAN FRAME BIT CHECK FAILED: %0d error(s)", errors);

        $finish;
    end

endmodule
