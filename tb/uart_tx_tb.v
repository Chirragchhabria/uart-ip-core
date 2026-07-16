`timescale 1ns / 1ps

module uart_tx_tb;

parameter CLOCK_FREQ = 50000000;
parameter BAUD_RATE  = 115200;

reg clk;
reg reset;
reg tx_start;
reg [7:0] tx_data;

wire tx;
wire busy;

uart_tx #(

    .CLOCK_FREQ(CLOCK_FREQ),
    .BAUD_RATE(BAUD_RATE)

) DUT (

    .clk(clk),
    .reset(reset),
    .tx_start(tx_start),
    .tx_data(tx_data),

    .tx(tx),
    .busy(busy)

);
//----------------------------------------------------
// Clock Generation
//----------------------------------------------------

always #10 clk = ~clk;
//----------------------------------------------------
// Test Sequence
//----------------------------------------------------

initial begin

    clk = 0;
    reset = 1;

    tx_start = 0;
    tx_data = 8'h00;

    #100;

    reset = 0;

    #100;

    tx_data = 8'hA5;

    tx_start = 1;

    #20;

    tx_start = 0;

    wait(busy == 0);

    #1000;

    $finish;

end

//----------------------------------------------------
// Waveform Dump
//----------------------------------------------------

initial begin

    $dumpfile("uart_tx.vcd");
    $dumpvars(0, uart_tx_tb);

end

endmodule