//uart:  115200 baud    
//clock: 27000000 Hz
//Clocks per bit: 27000000 / 115200 = 234.375 ≈ 234

module tx(
    input clk, 
    input [7:0] data_out,
    input enable,

    output tx,
    output [1:0] tx_state,
    output tx_done
);

localparam CLKS_PER_BIT = 234;

localparam STATE_IDLE  = 2'd0;
localparam STATE_START = 2'd1;
localparam STATE_DATA  = 2'd2;
localparam STATE_STOP  = 2'd3;

reg [7:0] clk_count = 0;
reg [7:0] data_reg;

reg [1:0] state = STATE_IDLE;
reg [1:0] prev_state = STATE_IDLE;

reg [2:0] bit_index = 0;
reg tx_reg = 1;

assign tx = tx_reg;
assign tx_state = state;
assign tx_done = prev_state == STATE_STOP && state == STATE_IDLE;

always @(posedge clk) begin
    prev_state <= state;

    case (state)
        STATE_IDLE: begin
            tx_reg <= 1;           // Keep line high when idle
            clk_count <= 0;
            bit_index <= 0;
            
            if (enable) begin
                state <= STATE_START;
                data_reg <= data_out;
            end
        end
        
        STATE_START: begin
            tx_reg <= 0;          // Send start bit (low)
            
            if (clk_count < CLKS_PER_BIT - 1) begin
                clk_count <= clk_count + 1;
            end else begin
                state <= STATE_DATA;
                clk_count <= 0;
            end
        end
        
        STATE_DATA: begin
            tx_reg <= data_reg[bit_index];  // Send current data bit
            
            if (clk_count < CLKS_PER_BIT - 1) begin
                clk_count <= clk_count + 1;
            end else begin
                clk_count <= 0;
                
                if (bit_index < 7) begin
                    bit_index <= bit_index + 1;
                end else begin
                    state <= STATE_STOP;
                    bit_index <= 0;
                end
            end
        end
        
        STATE_STOP: begin
            tx_reg <= 1;          // Send stop bit (high)
            
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
