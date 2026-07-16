`timescale 1ns / 1ps

module uart_loopback_tb;

parameter CLOCK_FREQ = 50000000;
parameter BAUD_RATE  = 115200;

//-----------------------------------------------------
// Clock / Reset
//-----------------------------------------------------

reg clk;
reg reset;

//-----------------------------------------------------
// TX Interface
//-----------------------------------------------------

reg tx_start;
reg [7:0] tx_data;

wire tx_busy;
wire tx;

//-----------------------------------------------------
// RX Interface
//-----------------------------------------------------

wire [7:0] rx_data;
wire rx_done;
wire rx_busy;

//-----------------------------------------------------
// Instantiate UART TX
//-----------------------------------------------------

uart_tx #(

    .CLOCK_FREQ(CLOCK_FREQ),
    .BAUD_RATE(BAUD_RATE)

) TX (

    .clk(clk),
    .reset(reset),

    .tx_start(tx_start),
    .tx_data(tx_data),

    .tx(tx),
    .busy(tx_busy)

);

//-----------------------------------------------------
// Instantiate UART RX
//-----------------------------------------------------

uart_rx #(

    .CLOCK_FREQ(CLOCK_FREQ),
    .BAUD_RATE(BAUD_RATE)

) RX (

    .clk(clk),
    .reset(reset),

    .rx(tx),

    .rx_data(rx_data),
    .rx_done(rx_done),
    .busy(rx_busy)

);

//-----------------------------------------------------
// Clock Generator
//-----------------------------------------------------

always #10 clk = ~clk;

//-----------------------------------------------------
// Test Sequence
//-----------------------------------------------------

initial begin

    clk = 0;
    reset = 1;

    tx_start = 0;
    tx_data  = 8'h00;

    #100;

    reset = 0;

    #100;

    //-------------------------------------------------
    // Test 1
    //-------------------------------------------------

    tx_data = 8'hA5;

    $display("-----------------------------------");
    $display("Sending  : %h", tx_data);

    tx_start = 1;

    #20;

    tx_start = 0;

    wait(rx_done);

    $display("Received : %h", rx_data);

    if(rx_data == tx_data)

        $display("TEST PASSED");

    else

        $display("TEST FAILED");

    //-------------------------------------------------

    #1000;

    $finish;

end

//-----------------------------------------------------
// Waveforms
//-----------------------------------------------------

initial begin

    $dumpfile("uart_loopback.vcd");
    $dumpvars(0, uart_loopback_tb);

end

endmodule