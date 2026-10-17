
module can_tx_fsm (
    input clk,
    input rst_n,
    input tx_start,
    output reg tx_busy
);

    localparam IDLE = 2'd0;
    localparam START = 2'd1;
    localparam TRANSMIT = 2'd2;
    localparam DONE = 2'd3;

    reg [1:0] state;
    reg [2:0] bit_count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            bit_count <= 3'd0;
        end else begin
            case (state)
                IDLE: begin
                    bit_count <= 3'd0;
                    if (tx_start)
                        state <= START;
                end

                START: begin
                    state <= TRANSMIT;
                    bit_count <= 3'd0;
                end

                TRANSMIT: begin
                    if (bit_count == 3'd4)
                        state <= DONE;
                    else
                        bit_count <= bit_count + 1'b1;
                end

                DONE: begin
                    state <= IDLE;
                end

                default: begin
                    state <= IDLE;
                    bit_count <= 3'd0;
                end
            endcase
        end
    end

    always @(*) begin
        tx_busy = (state == START) || 
                  (state == TRANSMIT);
    end

endmodule
