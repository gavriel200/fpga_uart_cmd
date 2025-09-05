module top(
    input clk,

    input rx,
    output tx
);



localparam WAIT = 2'd0;

// testing
localparam START = 2'd1;
 localparam CMD_READ = 2'd2;

// localparam CMD_READ = 2'd1;
// localparam CMD_RUN = 2'd2;
// localparam ERROR = 2'd3;

reg [1:0] state = WAIT;
reg [7:0] cmd_buffer;
reg [2:0] cmd_buffer_ptr;

// tx
wire tx_enable;
wire [7:0] data_out;
wire [1:0] tx_state;

tx _tx(
    .clk(clk), 
    .data_out(data_out), 
    .enable(tx_enable), 
    .tx(tx), 
    .tx_state(tx_state)
);

// printer
wire [1:0] printer_str_id;
wire printer_enable;
wire [1:0] printer_state;
wire printer_done;

printer _printer(
    .clk(clk), 
    .str_id(printer_str_id), 
    .enable(printer_enable), 
    .tx_state(tx_state),
    .printer_state(printer_state), 
    .printer_done(printer_done), 
    .data_out(data_out), 
    .tx_enable(tx_enable)
);

// states
wire [1:0] start_state;
wire start_done;
start _start(
    .clk(clk),
    .printer_done(printer_done),
    .start_state(start_state),
    .start_done(start_done),
    .printer_str_id(printer_str_id),
    .printer_enable(printer_enable)
);

reg [27:0] timer = 0;

always @ (posedge clk) begin
    case (state)
    WAIT: begin
        if (timer < 135000000 - 1) begin
            timer <= timer + 1;
        end else begin
            state <= START;
        end
    end
    START: begin
        if (start_done == 1) begin
            state <= CMD_READ;
        end
    end

//    CMD_READ: begin

//    end

//    CMD_RUN: begin

//    end

//    ERROR: begin
//        
//    end

    endcase
    
end

    
endmodule