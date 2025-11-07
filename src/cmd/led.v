module led (
    input clk,
    input reset,

    // private
    input  enable,
    output led_done,

    // cmd validation
    input [8*32-1:0] cmd,
    input [8*32-1:0] arg_1,
    input [8*32-1:0] arg_2,
    output valid,

    // printer
    input printer_done,
    output [3:0] printer_str_id,
    output printer_enable,

    // leds
    output led_1,
    output led_2,
    output led_3,
    output led_4
);

  localparam [8*32-1:0] led_cmd = "led";
  localparam [8*32-1:0] led_on_arg = "on";
  localparam [8*32-1:0] led_off_arg = "off";
  localparam [8*32-1:0] led_1_arg = "1";
  localparam [8*32-1:0] led_2_arg = "2";
  localparam [8*32-1:0] led_3_arg = "3";
  localparam [8*32-1:0] led_4_arg = "4";
  localparam [8*32-1:0] help_arg = "--help";
  localparam [8*32-1:0] no_cmd_data = 0;
  assign valid = cmd == led_cmd && 
    ( ( arg_1 == help_arg && arg_2 == no_cmd_data ) || 
    ( ( arg_1 == led_on_arg || arg_1 == led_off_arg ) && 
    ( arg_2 == led_1_arg || 
    arg_2 == led_2_arg ||
    arg_2 == led_3_arg ||
    arg_2 == led_4_arg ) ) );


  localparam IDLE = 4'd0;
  localparam SET_STR = 4'd1;
  localparam RUN = 4'd2;
  localparam DONE = 4'd3;

  reg [1:0] state = IDLE;


  reg led_done_reg = 0;
  assign led_done = led_done_reg;

  reg printer_enable_r = 0;
  assign printer_enable = printer_enable_r;

  reg [3:0] led_help_str_id = 8'd7;
  assign printer_str_id = led_help_str_id;

  reg led_1_reg = 0;
  assign led_1 = !led_1_reg;
  reg led_2_reg = 0;
  assign led_2 = !led_2_reg;
  reg led_3_reg = 0;
  assign led_3 = !led_3_reg;
  reg led_4_reg = 0;
  assign led_4 = !led_4_reg;

  always @(posedge clk) begin
    if (reset) begin
      state <= IDLE;
      led_done_reg <= 0;
      printer_enable_r <= 0;
      led_1_reg <= 0;
      led_2_reg <= 0;
      led_3_reg <= 0;
      led_4_reg <= 0;
    end else begin
      case (state)
        IDLE: begin
          led_done_reg <= 0;

          if (enable) begin
            if (arg_1 == help_arg) begin
              state <= SET_STR;
              printer_enable_r <= 1;
            end else begin
              case (arg_2)
                led_1_arg: begin
                  led_1_reg <= arg_1 == led_on_arg ? 1 : 0;
                end
                led_2_arg: begin
                  led_2_reg <= arg_1 == led_on_arg ? 1 : 0;
                end
                led_3_arg: begin
                  led_3_reg <= arg_1 == led_on_arg ? 1 : 0;
                end
                led_4_arg: begin
                  led_4_reg <= arg_1 == led_on_arg ? 1 : 0;
                end
              endcase
              state <= IDLE;
              led_done_reg <= 1;
            end
          end
        end

        SET_STR: begin
          state <= RUN;
        end

        RUN: begin
          printer_enable_r <= 0;

          if (printer_done) begin
            state <= IDLE;
            led_done_reg <= 1;
          end
        end
      endcase
    end
  end
endmodule
