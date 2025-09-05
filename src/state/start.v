module start(
    input clk,

    input printer_done,

    output [1:0] start_state,
    output start_done,

    output printer_str_id,
    output printer_enable
);

localparam INIT = 4'd0;
localparam SENDING = 4'd1;
localparam DONE = 4'd2;

reg [1:0] state = INIT;
assign start_state = state;

assign start_done = state == DONE;

reg [1:0] start_str_id = 4'd0;
assign printer_str_id = start_str_id;

reg printer_enable_r = 0;
assign printer_enable = printer_enable_r;

always @(posedge clk) begin

    case (state)
    INIT: begin
        printer_enable_r <= 1;
        state <= SENDING;
    end

    SENDING: begin
        printer_enable_r <= 0;

        if (printer_done == 1) begin
            state <= DONE;
        end
    end
    
//    DONE: begin
//    end
    endcase

    
end

    
endmodule