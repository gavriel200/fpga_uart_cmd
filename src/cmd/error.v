module error (
    input clk,
    input reset,

    // private
    input  enable,
    output error_done,

    // printer
    input printer_done,
    output [1:0] printer_str_id,
    output printer_enable
);

  localparam IDLE = 4'd0;
  localparam SET_STR = 4'd1;
  localparam RUN = 4'd2;
  localparam DONE = 4'd3;

  reg [1:0] state = IDLE;

  reg error_done_reg = 0;
  assign error_done = error_done_reg;

  reg printer_enable_r = 0;
  assign printer_enable = printer_enable_r;

  reg [1:0] error_str_id = 4'd2;
  assign printer_str_id = error_str_id;

  always @(posedge clk) begin
    if (reset) begin
      state <= IDLE;
      error_done_reg <= 0;
      printer_enable_r <= 0;
    end else begin
      case (state)
        IDLE: begin
          error_done_reg <= 0;

          if (enable) begin
            state <= SET_STR;
            printer_enable_r <= 1;
          end
        end

        SET_STR: begin
          state <= RUN;
        end

        RUN: begin
          printer_enable_r <= 0;

          if (printer_done) begin
            state <= IDLE;
            error_done_reg <= 1;
          end
        end
      endcase
    end
  end
endmodule
