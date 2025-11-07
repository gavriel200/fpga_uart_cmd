module arg_cmd (
    input clk,
    input reset,

    // prive
    input  enable,
    output arg_cmd_done,

    // cmd
    input [8*32-1:0] raw_cmd,

    output [8*32-1:0] cmd,
    output [8*32-1:0] arg_1,
    output [8*32-1:0] arg_2
);
  localparam STATE_CMD = 0;
  localparam STATE_ARG1 = 1;
  localparam STATE_ARG2 = 2;

  reg [1:0] state;

  reg [7:0] cmd_ptr;
  reg [7:0] arg_1_ptr;
  reg [7:0] arg_2_ptr;

  reg arg_cmd_done_reg = 0;
  assign arg_cmd_done = arg_cmd_done_reg;

  reg [7:0] ch;

  reg [8*32-1:0] cmd_reg = 0;
  assign cmd = cmd_reg;

  reg [8*32-1:0] arg_1_reg = 0;
  assign arg_1 = arg_1_reg;

  reg [8*32-1:0] arg_2_reg = 0;
  assign arg_2 = arg_2_reg;

  reg [5:0] index;  // counts up to 32 bytes (0–31)
  reg busy;

  always @(posedge clk) begin
    if (reset) begin
      cmd_reg          <= 0;
      arg_1_reg        <= 0;
      arg_2_reg        <= 0;
      cmd_ptr          <= 0;
      arg_1_ptr        <= 0;
      arg_2_ptr        <= 0;
      state            <= STATE_CMD;
      arg_cmd_done_reg <= 0;
      busy             <= 0;
      index            <= 0;
    end else begin
      arg_cmd_done_reg <= 0;

      // Start parsing
      if (enable && !busy) begin
        busy <= 1;
        state <= STATE_CMD;
        cmd_reg <= 0;
        arg_1_reg <= 0;
        arg_2_reg <= 0;
        cmd_ptr <= 0;
        arg_1_ptr <= 0;
        arg_2_ptr <= 0;
        index <= 0;
      end else if (busy) begin
        // Extract current char
        ch = raw_cmd[(8*(31-index))+:8];  // assuming MSB is first char

        if (ch != " ") begin
          case (state)
            STATE_CMD: begin
              cmd_reg <= {cmd_reg[8*31-1:0], ch};
              cmd_ptr <= cmd_ptr + 1;
            end
            STATE_ARG1: begin
              arg_1_reg <= {arg_1_reg[8*32-1 : 0], ch};
              arg_1_ptr <= arg_1_ptr + 1;
            end
            STATE_ARG2: begin
              arg_2_reg <= {arg_2_reg[8*32-1 : 0], ch};
              arg_2_ptr <= arg_2_ptr + 1;
            end
          endcase
        end else begin
          if (state == STATE_CMD && cmd_ptr != 0) state <= STATE_ARG1;
          else if (state == STATE_ARG1 && arg_1_ptr != 0) state <= STATE_ARG2;
        end

        // Advance byte index
        index <= index + 1;

        // Finished parsing all bytes?
        if (index == 31) begin
          busy <= 0;
          arg_cmd_done_reg <= 1;
        end
      end
    end
  end

endmodule
