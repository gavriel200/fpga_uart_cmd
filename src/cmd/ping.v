module ping (
    input clk,
    input reset,

    // private
    input  enable,
    output ping_done,

    // cmd validation
    input [32*8-1:0] cmd,
    output valid,

    // printer
    input printer_done,
    output [2:0] printer_str_id,
    output printer_enable
);
  localparam [32*8-1:0] ping_data = "gnip";  // ping
  assign valid = cmd == ping_data;

  localparam IDLE = 4'd0;
  localparam SET_STR = 4'd1;
  localparam RUN = 4'd2;
  localparam DONE = 4'd3;

  reg [1:0] state = IDLE;

  reg ping_done_reg = 0;
  assign ping_done = ping_done_reg;

  reg printer_enable_r = 0;
  assign printer_enable = printer_enable_r;

  reg [2:0] ping_str_id = 8'd3;
  assign printer_str_id = ping_str_id;

  always @(posedge clk) begin
    if (reset) begin
      state <= IDLE;
      ping_done_reg <= 0;
      printer_enable_r <= 0;
    end else begin
      case (state)
        IDLE: begin
          ping_done_reg <= 0;

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
            ping_done_reg <= 1;
          end
        end
      endcase
    end
  end
endmodule
