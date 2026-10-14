
module can_tx_fsm (
    input clk,
    input rst_n,
    input tx_start,
    output reg tx_busy
);

    localparam IDLE = 1'b0;
    localparam START = 1'b1;

    reg state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else if (tx_start)
            state <= START;
        else
            state <= IDLE;
    end

    always @(*) begin
        tx_busy = (state == START);
    end

endmodule
