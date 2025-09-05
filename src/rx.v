//uart:  115200 baud    
//clock: 27000000 Hz
//Clocks per bit: 27000000 / 115200 = 234.375 ≈ 234


module rx(
    input clk,
    input rx,

    output [7:0] data_in,
    output [2:0] state_out
);

localparam CLKS_PER_BIT = 234;
localparam CLKS_PER_BIT_HALF = CLKS_PER_BIT / 2;

localparam STATE_IDLE  = 3'd0;
localparam STATE_WAIT_START = 3'd1;
localparam STATE_START = 3'd2;
localparam STATE_DATA  = 3'd3;
localparam STATE_STOP  = 3'd4;

reg [7:0] clk_count = 0;
reg [7:0] data;
reg [2:0] state = STATE_IDLE;
reg [2:0] bit_index = 0;

assign data_in = data;
assign state_out = state;

always @ (posedge clk) begin
    case (state)
        STATE_IDLE: begin
            clk_count <= 0;
            bit_index <= 0;

            if (!rx) begin
                state <= STATE_WAIT_START;
            end
        end

        STATE_WAIT_START: begin
            if (clk_count < CLKS_PER_BIT_HALF - 1) begin
                clk_count <= clk_count + 1;
            end else begin
                state <= STATE_START;
                clk_count <= 0;
            end
        end

        STATE_START: begin
            if (clk_count < CLKS_PER_BIT - 1) begin
                clk_count <= clk_count + 1;
            end else begin
                state <= STATE_DATA;
                clk_count <= 0;
                data <= {rx, data[7:1]};
            end
        end

        STATE_DATA: begin
            if (clk_count < CLKS_PER_BIT - 1) begin
                clk_count <= clk_count + 1;
            end else begin
                clk_count <= 0;
               
                if (bit_index < 7) begin
                    bit_index <= bit_index + 1;
                    data <= {rx, data[7:1]};
                end else begin
                    state <= STATE_STOP;
                    bit_index <= 0;
                end
            end
        end

        STATE_STOP: begin
            if (clk_count < CLKS_PER_BIT - 1) begin
                clk_count <= clk_count + 1;
            end else begin
                state <= STATE_IDLE;
                clk_count <= 0;
            end
        end
    endcase
end

endmodule
