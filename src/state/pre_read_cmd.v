module pre_read_cmd (
    input clk,
    input reset,

    input enable,

    input printer_done,

    output pre_read_cmd_done,

    output [1:0] printer_str_id,
    output printer_enable
);

  localparam INIT = 4'd0;
  localparam SENDING = 4'd1;
  localparam DONE = 4'd2;

  reg [1:0] state = INIT;

  assign pre_read_cmd_done = state == DONE;

  reg [1:0] shell_str_id;
  assign printer_str_id = shell_str_id;

  reg printer_enable_r = 0;
  assign printer_enable = printer_enable_r;

  always @(posedge clk) begin
    if (reset) begin
      state <= INIT;
    end else begin
      case (state)
        INIT: begin
          if (enable) begin
            state <= SENDING;
            printer_enable_r <= 1;
            shell_str_id <= 4'd1;
          end
        end

        SENDING: begin
          printer_enable_r <= 0;

          if (printer_done == 1) begin
            state <= DONE;
          end
        end

        DONE: begin
          state <= INIT;
          shell_str_id <= 4'd0;
        end
      endcase
    end
  end


endmodule
