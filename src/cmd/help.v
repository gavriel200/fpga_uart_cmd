module help (
    input clk,
    input reset,

    // private
    input  enable,
    output help_done,

    // cmd validation
    input [8*32-1:0] cmd,
    input [8*32-1:0] arg_1,
    input [8*32-1:0] arg_2,
    output valid,

    // printer
    input printer_done,
    output [3:0] printer_str_id,
    output printer_enable
);
  localparam [8*32-1:0] help_data = "help";
  localparam [8*32-1:0] help_arg = "--help";
  localparam [8*32-1:0] no_cmd_data = 0;
  assign valid = cmd == help_data && (arg_1 == no_cmd_data || arg_1 == help_arg) && arg_2 == no_cmd_data;

  localparam IDLE = 4'd0;
  localparam SET_STR = 4'd1;
  localparam RUN = 4'd2;
  localparam DONE = 4'd3;

  reg [1:0] state = IDLE;

  reg help_done_reg = 0;
  assign help_done = help_done_reg;

  reg printer_enable_r = 0;
  assign printer_enable = printer_enable_r;

  reg [3:0] help_str_id = 8'd4;
  reg [3:0] help_help_str_id = 8'd5;
  assign printer_str_id = arg_1 == help_arg ? help_help_str_id : help_str_id;

  always @(posedge clk) begin
    if (reset) begin
      state <= IDLE;
      help_done_reg <= 0;
      printer_enable_r <= 0;
    end else begin
      case (state)
        IDLE: begin
          help_done_reg <= 0;

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
            help_done_reg <= 1;
          end
        end
      endcase
    end
  end
endmodule
