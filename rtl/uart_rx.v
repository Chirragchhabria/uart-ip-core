module uart_rx #(

    parameter CLOCK_FREQ = 50_000_000,
    parameter BAUD_RATE  = 115200

)(

    input  wire       clk,
    input  wire       reset,
    input  wire       rx,

    output reg [7:0]  rx_data,
    output reg        rx_done,
    output reg        busy

);

localparam BAUD_DIV  = CLOCK_FREQ / BAUD_RATE;
localparam HALF_BAUD = BAUD_DIV / 2;

localparam IDLE   = 3'd0;
localparam START  = 3'd1;
localparam DATA   = 3'd2;
localparam STOP   = 3'd3;
localparam DONE   = 3'd4;

reg [2:0] state;

reg [15:0] baud_counter;
reg [2:0]  bit_index;

reg [7:0] shift_reg;

always @(posedge clk or posedge reset) begin

    if (reset) begin

        state        <= IDLE;
        baud_counter <= 16'd0;
        bit_index    <= 3'd0;
        shift_reg    <= 8'd0;

        rx_data      <= 8'd0;
        rx_done      <= 1'b0;
        busy         <= 1'b0;

    end

    else begin

        rx_done <= 1'b0;

        case(state)

        //------------------------------------------------
        // IDLE
        //------------------------------------------------

        IDLE: begin

            busy <= 1'b0;
            baud_counter <= 16'd0;
            bit_index <= 3'd0;

            if(rx == 1'b0) begin

                state <= START;
                busy  <= 1'b1;

            end

        end

        //------------------------------------------------
        // VERIFY START BIT
        //------------------------------------------------

        START: begin

            if(baud_counter == HALF_BAUD-1) begin

                baud_counter <= 16'd0;

                if(rx == 1'b0)

                    state <= DATA;

                else

                    state <= IDLE;

            end

            else begin

                baud_counter <= baud_counter + 1;

            end

        end

        //------------------------------------------------
        // RECEIVE DATA
        //------------------------------------------------

        DATA: begin

            if(baud_counter == BAUD_DIV-1) begin

                baud_counter <= 16'd0;

                shift_reg[bit_index] <= rx;

                if(bit_index == 3'd7) begin

                    bit_index <= 3'd0;
                    state <= STOP;

                end

                else begin

                    bit_index <= bit_index + 1;

                end

            end

            else begin

                baud_counter <= baud_counter + 1;

            end

        end

        //------------------------------------------------
        // STOP BIT
        //------------------------------------------------

        STOP: begin

            if(baud_counter == BAUD_DIV-1) begin

                baud_counter <= 16'd0;

                if(rx == 1'b1) begin

                    rx_data <= shift_reg;
                    state <= DONE;

                end

                else begin

                    state <= IDLE;

                end

            end

            else begin

                baud_counter <= baud_counter + 1;

            end

        end

        //------------------------------------------------
        // DONE
        //------------------------------------------------

        DONE: begin

            rx_done <= 1'b1;
            busy <= 1'b0;
            state <= IDLE;

        end

        default:

            state <= IDLE;

        endcase

    end

end

endmodule