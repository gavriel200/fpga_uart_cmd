module pre_read_cmd (
    input clk,
    input reset,

    input enable,

    input printer_done,

    output pre_read_cmd_done,

    output [1:0] printer_str_id,
    output printer_enable,

    output [1:0] pre_read_cmd_state
);

  localparam IDLE = 4'd0;
  localparam SET_STR = 4'd1;
  localparam SENDING = 4'd2;

  reg [1:0] state = IDLE;

  reg pre_read_cmd_done_reg = 0;
  assign pre_read_cmd_done = pre_read_cmd_done_reg;

  reg [1:0] shell_str_id = 4'd1;
  assign printer_str_id = shell_str_id;

  reg printer_enable_r = 0;
  assign printer_enable = printer_enable_r;

  always @(posedge clk) begin
    if (reset) begin
      state <= IDLE;
      pre_read_cmd_done_reg <= 0;
      printer_enable_r <= 0;
    end else begin
      case (state)
        IDLE: begin
          pre_read_cmd_done_reg <= 0;

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

          if (printer_done) begin
            state <= IDLE;
            pre_read_cmd_done_reg <= 1;
          end
        end
      endcase
    end
  end


endmodule
