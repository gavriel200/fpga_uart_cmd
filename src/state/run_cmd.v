module run_cmd (
    input clk,
    input reset,

    // prive
    input  enable,
    output run_cmd_done,

    // ping
    output ping_enable,
    input  ping_done,
    input  ping_valid,

    // help
    output help_enable,
    input  help_done,
    input  help_valid,

    // error
    output error_enable,
    input  error_done,

    // no_cmd
    input no_cmd_valid,

    // debug
    output valid_cmd_debug
);
  localparam IDLE = 4'd0;
  localparam CMD = 4'd1;
  localparam WAIT = 4'd2;

  localparam [8*32-1:0] NO_CMD = 0;

  reg [1:0] state = IDLE;
  reg run_cmd_done_reg = 0;
  assign run_cmd_done = run_cmd_done_reg;

  reg error_valid = 0;

  reg enable_cmd_reg = 0;
  assign ping_enable  = ping_valid ? enable_cmd_reg : 0;
  assign help_enable  = help_valid ? enable_cmd_reg : 0;
  assign error_enable = error_valid ? enable_cmd_reg : 0;

  wire valid_cmd;
  assign valid_cmd = ping_valid | help_valid | no_cmd_valid;
  assign valid_cmd_debug = valid_cmd;

  wire cmd_done;
  assign cmd_done = ping_done | help_done | error_done;

  always @(posedge clk) begin
    if (reset) begin
      state <= IDLE;
      run_cmd_done_reg <= 0;

      enable_cmd_reg <= 0;
      error_valid <= 0;
    end else begin
      case (state)
        IDLE: begin
          run_cmd_done_reg <= 0;

          if (enable) begin
            state <= WAIT;
            enable_cmd_reg <= 1;
            if (!valid_cmd) begin
              error_valid <= 1;
            end
          end
        end

        WAIT: begin
          enable_cmd_reg <= 0;
          error_valid <= 0;

          if (cmd_done | no_cmd_valid) begin
            state <= IDLE;
            run_cmd_done_reg <= 1;
          end

        end
      endcase
    end
  end
endmodule
