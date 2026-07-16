`timescale 1ns/1ps

module uart_rx_tb;

parameter CLOCK_FREQ = 50000000;
parameter BAUD_RATE  = 115200;

localparam BAUD_DIV = CLOCK_FREQ / BAUD_RATE;

reg clk;
reg reset;
reg rx;

wire [7:0] rx_data;
wire rx_done;
wire busy;

uart_rx #(
    .CLOCK_FREQ(CLOCK_FREQ),
    .BAUD_RATE(BAUD_RATE)
) DUT (
    .clk(clk),
    .reset(reset),
    .rx(rx),
    .rx_data(rx_data),
    .rx_done(rx_done),
    .busy(busy)
);
//-----------------------------------------------------
// Clock Generator
//-----------------------------------------------------

always #10 clk = ~clk;
//-----------------------------------------------------
// Waveforms
//-----------------------------------------------------

initial begin
    $dumpfile("waveforms/uart_rx.vcd");
    $dumpvars(0, uart_rx_tb);
end
//-----------------------------------------------------
// Initial values
//-----------------------------------------------------

initial begin

    clk = 0;
    reset = 1;
    rx = 1;

    #100;

    reset = 0;

    #1000;

    $finish;

end
endmodule