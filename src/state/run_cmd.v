module run_cmd (
    input clk,
    input reset,

    // prive
    input  enable,
    output run_cmd_done,

    // read_cmd
    input [32*8-1:0] cmd,

    // ping
    output ping_enable,
    input  ping_done,

    // help
    output help_enable,
    input  help_done,

    // error
    output error_enable,
    input  error_done,

    // test
    output [1:0] run_cmd_state,
    output [32*8-1:0] test_test
);
  localparam IDLE = 4'd0;
  localparam CMD = 4'd1;
  localparam WAIT = 4'd2;

  localparam [32*8-1:0] PING_CMD = "gnip";
  localparam [32*8-1:0] HELP_CMD = "pleh";
  reg [32*8-1:0] test = "gnip";
  localparam [32*8-1:0] NO_CMD = 0;

  assign test_test = test;

  reg [1:0] state = IDLE;
  reg run_cmd_done_reg = 0;
  assign run_cmd_done  = run_cmd_done_reg;

  assign run_cmd_state = state;

  reg ping_enable_reg = 0;
  assign ping_enable = ping_enable_reg;

  reg help_enable_reg = 0;
  assign help_enable = help_enable_reg;

  reg error_enable_reg = 0;
  assign error_enable = error_enable_reg;

  wire cmd_done;
  reg  no_cmd_done = 0;
  assign cmd_done = no_cmd_done | ping_done | help_done | error_done;

  always @(posedge clk) begin
    if (reset) begin
      state <= IDLE;
      run_cmd_done_reg <= 0;
      ping_enable_reg <= 0;
      help_enable_reg <= 0;
      error_enable_reg <= 0;
    end else begin
      case (state)
        IDLE: begin
          run_cmd_done_reg <= 0;

          if (enable) begin
            state <= CMD;
          end
        end

        CMD: begin

          if (cmd == NO_CMD) begin
            no_cmd_done <= 1;
            state <= WAIT;
          end else if (cmd == PING_CMD) begin
            ping_enable_reg <= 1;
            state <= WAIT;
          end else if (cmd == HELP_CMD) begin
            help_enable_reg <= 1;
            state <= WAIT;
          end else begin
            error_enable_reg <= 1;
            state <= WAIT;
          end
        end

        WAIT: begin
          no_cmd_done <= 0;

          ping_enable_reg <= 0;
          help_enable_reg <= 0;
          error_enable_reg <= 0;

          if (cmd_done) begin
            state <= IDLE;
            run_cmd_done_reg <= 1;
          end

        end
      endcase
    end

  end

endmodule
