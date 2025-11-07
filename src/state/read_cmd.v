module read_cmd (
    input clk,
    input reset,

    // private
    input enable,
    output read_cmd_done,
    output [8*32-1:0] cmd,

    // rx
    input rx_done,
    input [2:0] rx_state,
    input [7:0] data_in,

    // tx
    output tx_enable,
    output [7:0] data_out
);
  localparam IDLE = 4'd0;
  localparam READ = 4'd1;
  localparam CMD = 4'd2;
  localparam DONE = 4'd3;

  localparam enter = 8'h0D;
  localparam backspace = 8'h7f;

  reg [ 1:0] state = IDLE;

  reg [31:0] pointer_reg = 0;
  assign pointer = pointer_reg;

  reg [8*32-1:0] cmd_reg = 0;
  assign cmd = cmd_reg;

  reg read_cmd_done_reg = 0;
  assign read_cmd_done = read_cmd_done_reg;

  reg [7:0] data_out_reg = 0;
  assign data_out = data_out_reg;

  reg tx_enable_reg;
  assign tx_enable = tx_enable_reg;


  always @(posedge clk) begin
    if (reset) begin
      state             <= IDLE;
      pointer_reg       <= 0;
      cmd_reg           <= 0;
      read_cmd_done_reg <= 0;
      data_out_reg      <= 0;
      tx_enable_reg     <= 0;
    end else begin
      case (state)
        IDLE: begin
          read_cmd_done_reg <= 0;
          pointer_reg <= 0;

          if (enable) begin
            state   <= READ;
            cmd_reg <= 0;
          end
        end

        READ: begin
          tx_enable_reg <= 0;
          data_out_reg  <= 0;

          if (rx_done) begin
            if (data_in == enter) begin
              read_cmd_done_reg <= 1;
              state <= IDLE;

            end else if (data_in == backspace) begin
              if (pointer_reg > 0) begin
                tx_enable_reg <= 1;
                data_out_reg <= data_in;
                pointer_reg <= pointer_reg - 1;
                cmd_reg <= {8'b0, cmd_reg[8*32-1:8]};
              end

            end else if (
                // Uppercase letters
                (data_in >= 8'h41 && data_in <= 8'h5A) ||

                // Lowercase letters
                (data_in >= 8'h61 && data_in <= 8'h7A) ||

                // Numbers
                (data_in >= 8'h30 && data_in <= 8'h39) ||

                // Symbols
                (data_in >= 8'h21 && data_in <= 8'h2F) ||  // !"#$%&'()*+,-./
                (data_in >= 8'h3A && data_in <= 8'h40) ||  // :;<=>?@
                (data_in >= 8'h5B && data_in <= 8'h60) ||  // [\]^_`
                (data_in >= 8'h7B && data_in <= 8'h7E) ||  // {|}~

                // Space
                (data_in == 8'h20) ||

                // Enter (LF)
                (data_in == 8'h0A) ||

                // Backspace
                (data_in == 8'h08)) begin
              if (pointer_reg < 31) begin
                pointer_reg <= pointer_reg + 1;
                tx_enable_reg <= 1;
                data_out_reg <= data_in;

                cmd_reg <= {cmd_reg[8*31-1:0], data_in};
              end
            end
          end
        end
      endcase
    end
  end

endmodule
