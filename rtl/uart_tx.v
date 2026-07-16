module uart_tx #(

    parameter CLOCK_FREQ = 50_000_000,
    parameter BAUD_RATE  = 115200

)(

    input  wire       clk,
    input  wire       reset,

    input  wire       tx_start,
    input  wire [7:0] tx_data,

    output reg        tx,
    output reg        busy

);

localparam BAUD_DIV = CLOCK_FREQ / BAUD_RATE;

localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam STOP  = 2'b11;

reg [1:0] state;

reg [7:0] data_reg;

reg [2:0] bit_index;

reg [15:0] baud_counter;

always @(posedge clk or posedge reset) begin

    if (reset) begin

        state        <= IDLE;
        tx           <= 1'b1;
        busy         <= 1'b0;
        bit_index    <= 3'd0;
        baud_counter <= 16'd0;
        data_reg     <= 8'd0;

    end

    else begin

        case(state)

        //---------------------------------------------------
        // IDLE
        //---------------------------------------------------

        IDLE: begin

            tx   <= 1'b1;
            busy <= 1'b0;

            if(tx_start) begin

                data_reg     <= tx_data;
                bit_index    <= 3'd0;
                baud_counter <= 16'd0;

                busy <= 1'b1;

                state <= START;

            end

        end
                //---------------------------------------------------
        // START BIT
        //---------------------------------------------------

        START: begin

            tx <= 1'b0;

            if (baud_counter == BAUD_DIV - 1) begin

                baud_counter <= 16'd0;
                state <= DATA;

            end

            else begin

                baud_counter <= baud_counter + 1;

            end

        end


        //---------------------------------------------------
        // DATA BITS
        //---------------------------------------------------

        DATA: begin

            tx <= data_reg[bit_index];

            if (baud_counter == BAUD_DIV - 1) begin

                baud_counter <= 16'd0;

                if (bit_index == 3'd7) begin

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
                //---------------------------------------------------
        // STOP BIT
        //---------------------------------------------------

        STOP: begin

            tx <= 1'b1;

            if (baud_counter == BAUD_DIV - 1) begin

                baud_counter <= 16'd0;
                busy <= 1'b0;
                state <= IDLE;

            end

            else begin

                baud_counter <= baud_counter + 1;

            end

        end

        endcase

    end

end

endmodule