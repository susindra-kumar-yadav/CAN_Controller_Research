`timescale 1ns/1ps

module can_tx_fsm_tb;

    reg clk;
    reg rst_n;
    reg tx_start;
    wire tx_busy;

    can_tx_fsm dut (
        .clk(clk),
        .rst_n(rst_n),
        .tx_start(tx_start),
        .tx_busy(tx_busy)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("waveforms/can_tx_fsm.vcd");
        $dumpvars(0, can_tx_fsm_tb);
    end

    initial begin
        $monitor("Time=%0t | rst_n=%b | tx_start=%b | tx_busy=%b",
                 $time, rst_n, tx_start, tx_busy);
    end

    initial begin
        clk = 0;
        rst_n = 0;
        tx_start = 0;

        #20;
        rst_n = 1;

        @(negedge clk);
        tx_start = 1;

        @(negedge clk);
        tx_start = 0;

        wait (tx_busy == 0);
        #10;

        $display("BASIC TEST COMPLETED");
        $finish;
    end

endmodule