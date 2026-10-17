
`timescale 1ns/1ps

module can_crc15_tb;

    reg [81:0] crc_input;
    reg crc_enable;
    wire [14:0] crc;

    integer errors;

    can_crc15 dut (
        .crc_input(crc_input),
        .crc_enable(crc_enable),
        .crc(crc)
    );

    initial begin
        errors = 0;
        crc_input = 82'd0;
        crc_enable = 1'b1;

        // Test 1: All-zero input
        #10;
        if (crc !== 15'h0000) begin
            $display("FAIL: Zero input, CRC=%h", crc);
            errors = errors + 1;
        end else begin
            $display("PASS: Zero input");
        end

        // Test 2: Disable CRC calculation
        crc_input = {82{1'b1}};
        crc_enable = 1'b0;
        #10;
        if (crc !== 15'h0000) begin
            $display("FAIL: Disabled CRC, CRC=%h", crc);
            errors = errors + 1;
        end else begin
            $display("PASS: CRC disabled");
        end

        // Test 3: Nonzero input produces a deterministic result
        crc_enable = 1'b1;
        crc_input = 82'h123456789ABCDEF12345;
        #10;
        $display("INFO: CRC for test vector = %h", crc);

        if (errors == 0)
            $display("BASIC CRC TESTS PASSED");
        else
            $display("BASIC CRC TESTS FAILED: %0d error(s)", errors);

        $finish;
    end

endmodule
