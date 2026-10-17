
`timescale 1ns/1ps

module can_bit_stuff (
    input  [127:0] data_in,
    input  [6:0]   input_length,
    output reg [159:0] data_out,
    output reg [7:0]   output_length
);

    integer i;
    integer out_index;
    integer same_count;
    reg previous_bit;
    reg current_bit;

    always @(*) begin
        data_out = 160'd0;
        output_length = 0;
        out_index = 0;
        same_count = 0;
        previous_bit = 1'b0;
        current_bit = 1'b0;

        for (i = 0; i < 128; i = i + 1) begin
            if (i < input_length) begin
                current_bit = data_in[127-i];

                data_out[159-out_index] = current_bit;
                out_index = out_index + 1;

                if (same_count == 0) begin
                    same_count = 1;
                end else if (current_bit == previous_bit) begin
                    same_count = same_count + 1;
                end else begin
                    same_count = 1;
                end

                previous_bit = current_bit;

                if (same_count == 5) begin
                    data_out[159-out_index] = ~current_bit;
                    out_index = out_index + 1;
                    same_count = 0;
                    previous_bit = ~current_bit;
                end
            end
        end

        output_length = out_index;
    end

endmodule
