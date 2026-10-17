
`timescale 1ns/1ps

module can_frame_builder_tb;

    reg [10:0] can_id;
    reg [3:0] dlc;
    reg [63:0] data;

    wire [82:0] frame;
    wire [6:0] frame_length;

    integer errors;

    can_frame_builder dut (
        .can_id(can_id),
        .dlc(dlc),
        .data(data),
        .frame(frame),
        .frame_length(frame_length)
    );

    initial begin
        errors = 0;
        can_id = 11'h123;
        data = 64'h1122334455667788;

        // Test 1: DLC = 1
        dlc = 1;
        #10;
        if (frame[81:71] !== 11'h123 ||
            frame[70:68] !== 3'b000 ||
            frame[67:64] !== 4'd1 ||
            frame[63:56] !== 8'h11 ||
            frame_length !== 7'd26) begin
            $display("FAIL: DLC=1");
            errors = errors + 1;
        end else begin
            $display("PASS: DLC=1");
        end

        // Test 2: DLC = 4
        dlc = 4;
        #10;
        if (frame[67:64] !== 4'd4 ||
            frame[63:32] !== 32'h11223344 ||
            frame_length !== 7'd50) begin
            $display("FAIL: DLC=4");
            errors = errors + 1;
        end else begin
            $display("PASS: DLC=4");
        end

        // Test 3: DLC = 8
        dlc = 8;
        #10;
        if (frame[67:64] !== 4'd8 ||
            frame[63:0] !== 64'h1122334455667788 ||
            frame_length !== 7'd82) begin
            $display("FAIL: DLC=8");
            errors = errors + 1;
        end else begin
            $display("PASS: DLC=8");
        end

        // Test 4: DLC above 8 is capped at 8
        dlc = 9;
        #10;
        if (frame[67:64] !== 4'd8 ||
            frame_length !== 7'd82) begin
            $display("FAIL: DLC=9 handling");
            errors = errors + 1;
        end else begin
            $display("PASS: DLC=9 handling");
        end

        if (errors == 0)
            $display("ALL FRAME BUILDER TESTS PASSED");
        else
            $display("FRAME BUILDER TESTS FAILED: %0d error(s)", errors);

        $finish;
    end

endmodule
