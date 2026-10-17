
`timescale 1ns/1ps

module can_controller_top (
    input         clk,
    input         rst_n,
    input         tx_start,

    input  [10:0] can_id,
    input  [3:0]  dlc,
    input  [63:0] data,

    output reg    tx_busy,
    output reg    tx_done,
    output reg    tx_serial
);

    localparam IDLE = 2'd0;
    localparam BUILD = 2'd1;
    localparam SEND = 2'd2;
    localparam DONE = 2'd3;

    reg [1:0] state;

    reg [10:0] id_reg;
    reg [3:0]  dlc_reg;
    reg [63:0] data_reg;

    // SOF + ID + RTR + IDE + r0 + DLC + 64 data bits
    // Total capacity: 83 bits.
    reg [82:0] frame_bits;
    reg [6:0]  frame_length;
    reg [6:0]  bit_count;

    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state        <= IDLE;
            id_reg       <= 11'd0;
            dlc_reg      <= 4'd0;
            data_reg     <= 64'd0;
            frame_bits   <= 83'd0;
            frame_length <= 7'd0;
            bit_count    <= 7'd0;
            tx_busy      <= 1'b0;
            tx_done      <= 1'b0;
            tx_serial    <= 1'b1;
        end else begin
            tx_done <= 1'b0;

            case (state)

                IDLE: begin
                    tx_busy   <= 1'b0;
                    tx_serial <= 1'b1;
                    bit_count <= 7'd0;

                    if (tx_start && dlc <= 4'd8) begin
                        id_reg   <= can_id;
                        dlc_reg  <= dlc;
                        data_reg <= data;
                        tx_busy  <= 1'b1;
                        state    <= BUILD;
                    end
                end

                BUILD: begin
                    // Construct the logical frame fields.
                    // Data bytes are transmitted from the
                    // most-significant byte of data_reg first.
                    frame_bits <= {
                        1'b0,       // SOF
                        id_reg,     // 11-bit identifier
                        1'b0,       // RTR: data frame
                        1'b0,       // IDE: standard frame
                        1'b0,       // r0
                        dlc_reg,    // DLC
                        data_reg
                    };

                    frame_length <= 7'd19 + (dlc_reg * 8);
                    bit_count <= 7'd0;
                    state <= SEND;
                end

                SEND: begin
                    // Send only the valid fields, MSB first.
                    // The fixed prefix occupies bits [82:64].
                    if (bit_count < 7'd19) begin
                        tx_serial <= frame_bits[82 - bit_count];
                    end else begin
                        tx_serial <=
                            frame_bits[63 - (bit_count - 7'd19)];
                    end

                    if (bit_count == frame_length - 1'b1) begin
                        state <= DONE;
                    end else begin
                        bit_count <= bit_count + 1'b1;
                    end
                end

                DONE: begin
                    tx_serial <= 1'b1;
                    tx_busy   <= 1'b0;
                    tx_done   <= 1'b1;
                    state     <= IDLE;
                end

                default: begin
                    state     <= IDLE;
                    tx_busy   <= 1'b0;
                    tx_done   <= 1'b0;
                    tx_serial <= 1'b1;
                end

            endcase
        end
    end

endmodule
