
`timescale 1ns/1ps

module can_bit_stuff_tb;

    reg [127:0] data_in;
    reg [6:0] input_length;

    wire [159:0] data_out;
    wire [7:0] output_length;

    integer errors;

    can_bit_stuff dut (
        .data_in(data_in),
        .input_length(input_length),
        .data_out(data_out),
        .output_length(output_length)
    );

    initial begin
        errors = 0;

        // Test 1: Five zeros should insert a one.
        data_in = 128'd0;
        data_in[127:123] = 5'b00000;
        input_length = 5;
        #10;

        if (output_length !== 6 ||
            data_out[159:154] !== 6'b000001) begin
            $display("FAIL: Five-zero stuffing");
            errors = errors + 1;
        end else begin
            $display("PASS: Five-zero stuffing");
        end

        // Test 2: Five ones should insert a zero.
        data_in = 128'd0;
        data_in[127:123] = 5'b11111;
        input_length = 5;
        #10;

        if (output_length !== 6 ||
            data_out[159:154] !== 6'b111110) begin
            $display("FAIL: Five-one stuffing");
            errors = errors + 1;
        end else begin
            $display("PASS: Five-one stuffing");
        end

        // Test 3: Alternating bits need no stuffing.
        data_in = 128'd0;
        data_in[127:120] = 8'b10101010;
        input_length = 8;
        #10;

        if (output_length !== 8 ||
            data_out[159:152] !== 8'b10101010) begin
            $display("FAIL: Alternating-bit sequence");
            errors = errors + 1;
        end else begin
            $display("PASS: Alternating-bit sequence");
        end

        if (errors == 0)
            $display("ALL BIT-STUFFING TESTS PASSED");
        else
            $display("BIT-STUFFING TESTS FAILED: %0d error(s)", errors);

        $finish;
    end

endmodule
