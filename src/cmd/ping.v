module ping (
    input clk,
    input reset,

    // private
    input  enable,
    output ping_done,

    // printer
    input printer_done,
    output [1:0] printer_str_id,
    output printer_enable
);

  localparam IDLE = 4'd0;
  localparam RUN = 4'd1;
  localparam DONE = 4'd2;

  reg [1:0] state = IDLE;

  reg ping_done_reg = 0;
  assign ping_done = ping_done_reg;

  reg printer_enable_r = 0;
  assign printer_enable = printer_enable_r;

  reg [1:0] ping_str_id = 0;
  assign printer_str_id = ping_str_id;

  always @(posedge clk) begin
    if (reset) begin
      state <= IDLE;
      ping_done_reg <= 0;
      printer_enable_r <= 0;
      ping_str_id <= 0;
    end else begin
      case (state)
        IDLE: begin
          ping_done_reg <= 0;

          if (enable) begin
            state <= RUN;
            printer_enable_r <= 1;
            ping_str_id <= 4'd3;
          end
        end


        RUN: begin
          printer_enable_r <= 0;

          if (printer_done) begin
            state <= IDLE;
            ping_done_reg <= 1;
            ping_str_id <= 4'd0;
          end
        end
      endcase
    end
  end
endmodule
