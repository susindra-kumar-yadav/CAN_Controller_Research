
`timescale 1ns/1ps

module can_frame_builder (
    input  [10:0] can_id,
    input  [3:0]  dlc,
    input  [63:0] data,
    output reg [82:0] frame,
    output reg [6:0]  frame_length
);

    integer i;
    reg [3:0] safe_dlc;

    always @(*) begin
        frame = 83'd0;
        frame_length = 7'd0;
        safe_dlc = (dlc <= 8) ? dlc : 4'd8;

        // Field layout:
        // Identifier (11) + RTR (1) + IDE (1) +
        // r0 (1) + DLC (4) + Data (64) = 82 bits.
        // The frame bus is 83 bits; unused leading bit is zero.
        frame[82]    = 1'b0;
        frame[81:71] = can_id;
        frame[70]    = 1'b0;       // RTR: data frame
        frame[69]    = 1'b0;       // IDE: standard frame
        frame[68]    = 1'b0;       // Reserved bit r0
        frame[67:64] = safe_dlc;

        // Pack requested data bytes from the most-significant end.
        for (i = 0; i < 8; i = i + 1) begin
            if (i < safe_dlc)
                frame[63-i*8 -: 8] = data[63-i*8 -: 8];
        end

        // Identifier + control + DLC = 18 bits.
        // Add the number of requested data bits.
        frame_length = 7'd18 + (safe_dlc * 8);
    end

endmodule

