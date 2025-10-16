module read_cmd (
    input clk,
    input reset,

    // private
    input  enable,
    output read_cmd_done,

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

  reg tx_enable_reg;
  assign tx_enable = tx_enable_reg;

  reg [7:0] data_out_reg = 0;
  assign data_out = data_out_reg;

  reg [1:0] state = IDLE;
  reg [31:0] pointer = 0;
  reg read_cmd_done_reg = 0;

  assign read_cmd_done = read_cmd_done_reg;

  always @(posedge clk) begin
    if (reset) begin
      state             <= IDLE;
      tx_enable_reg     <= 0;
      data_out_reg      <= 0;
      pointer           <= 0;
      read_cmd_done_reg <= 0;
    end else begin
      case (state)
        IDLE: begin
          read_cmd_done_reg <= 0;

          if (enable) begin
            state <= READ;
          end
        end

        READ: begin
          tx_enable_reg <= 0;
          data_out_reg  <= 0;

          if (rx_done) begin
            if (data_in == enter) begin
              // run cmd (add later)
              // set done
              read_cmd_done_reg <= 1;
              pointer <= 0;
              state <= IDLE;

            end else if (data_in == backspace) begin
              if (pointer > 0) begin
                tx_enable_reg <= 1;
                data_out_reg <= data_in;
                pointer <= pointer - 1;
              end

            end else begin
              if (pointer < 31) begin
                pointer <= pointer + 1;
                tx_enable_reg <= 1;
                data_out_reg <= data_in;
              end
            end
          end
        end
      endcase
    end
  end

endmodule
