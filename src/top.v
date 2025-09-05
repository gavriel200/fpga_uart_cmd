module top(
    input clk,

    input rx,
    output tx
);

localparam START = 2'd0;
localparam CMD_READ = 2'd1;
localparam CMD_RUN = 2'd2;
localparam ERROR = 2'd3;

reg [1:0] status = START;
reg [7:0] cmd_buffer;
reg [2:0] cmd_buffer_ptr;

// tx
reg [7:0] data_out;
wire [1:0] tx_state

tx _tx(.clk(clk), .data_out(data_out), .rx(rx), .tx(tx), .state_out(tx_state))

always @(posedge clk) begin
    case (status)
    START: begin
        
    end

    CMD_READ: begin

    end

    CMD_RUN: begin

    end

    ERROR: begin
        
    end

    endcase
    
end

    
endmodule