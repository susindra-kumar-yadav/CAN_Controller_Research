
`timescale 1ns/1ps

module can_crc15 (
    input  [81:0] crc_input,
    input         crc_enable,
    output reg [14:0] crc
);

    integer i;
    reg feedback;
    reg [14:0] crc_temp;

    // CAN CRC-15 polynomial:
    // x^15 + x^14 + x^10 + x^8 + x^7
    // + x^4 + x^3 + 1
    //
    // This combinational implementation processes
    // bits from MSB to LSB, starting from zero.

    always @(*) begin
        crc_temp = 15'h0000;
        feedback = 1'b0;

        if (crc_enable) begin
            for (i = 81; i >= 0; i = i - 1) begin
                feedback = crc_temp[14] ^ crc_input[i];

                crc_temp = {crc_temp[13:0], 1'b0};

                if (feedback) begin
                    crc_temp = crc_temp ^ 15'h4599;
                end
            end
        end

        crc = crc_temp;
    end

endmodule
