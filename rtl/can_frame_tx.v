`timescale 1ns/1ps

module can_frame_tx (
    input clk,
    input rst_n,
    input tx_start,
    input [10:0] can_id,
    input [3:0] dlc,
    input [7:0] data_byte,
    output reg tx_busy,
    output reg tx_done,
    output reg tx_serial
);

    localparam IDLE  = 2'd0;
    localparam SOF   = 2'd1;
    localparam FRAME = 2'd2;
    localparam DONE  = 2'd3;

    reg [1:0] state;
    reg [5:0] bit_count;
    reg [23:0] frame_data;
    reg [5:0] frame_length;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state        <= IDLE;
            bit_count    <= 0;
            frame_data   <= 0;
            frame_length <= 0;
            tx_busy      <= 0;
            tx_done      <= 0;
            tx_serial    <= 1;
        end else begin
            tx_done <= 0;

            case (state)
                IDLE: begin
                    tx_busy   <= 0;
                    tx_serial <= 1;

                    if (tx_start) begin
                        frame_data <= {can_id, 1'b0, dlc, data_byte};
                        frame_length <= 24;
                        bit_count <= 0;
                        tx_busy <= 1;
                        state <= SOF;
                    end
                end

                SOF: begin
                    tx_serial <= 0;
                    state <= FRAME;
                end

                FRAME: begin
                    tx_serial <= frame_data[23-bit_count];

                    if (bit_count == frame_length - 1'b1) begin
                        state <= DONE;
                    end else begin
                        bit_count <= bit_count + 1'b1;
                    end
                end

                DONE: begin
                    tx_serial <= 1;
                    tx_busy <= 0;
                    tx_done <= 1;
                    state <= IDLE;
                end

                default: begin
                    state <= IDLE;
                    tx_serial <= 1;
                    tx_busy <= 0;
                end
            endcase
        end
    end

endmodule