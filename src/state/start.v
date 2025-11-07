module start (
    input clk,
    input reset,

    input enable,

    input printer_done,

    output [1:0] start_state,
    output start_done,

    output [3:0] printer_str_id,
    output printer_enable
);

  localparam INIT = 4'd0;
  localparam SET_STR = 4'd1;
  localparam SENDING = 4'd2;
  localparam DONE = 4'd3;

  reg [1:0] state = INIT;
  assign start_state = state;

  assign start_done  = state == DONE;

  reg [3:0] start_str_id = 8'd0;
  assign printer_str_id = start_str_id;

  reg printer_enable_r = 0;
  assign printer_enable = printer_enable_r;

  always @(posedge clk) begin
    if (reset) begin
      state <= INIT;
    end else begin
      case (state)
        INIT: begin
          if (enable) begin
            state <= SET_STR;
            printer_enable_r <= 1;
          end
        end


        SET_STR: begin
          state <= SENDING;
        end

        SENDING: begin
          printer_enable_r <= 0;

          if (printer_done == 1) begin
            state <= DONE;
          end
        end

        DONE: begin
          state <= INIT;
        end
      endcase
    end
  end


endmodule
