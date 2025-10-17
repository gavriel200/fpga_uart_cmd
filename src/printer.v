module printer (
    input clk,
    input reset,

    input [1:0] str_id,
    input enable,

    input [1:0] tx_state,
    input tx_done,

    output [1:0] printer_state,
    output printer_done,
    output [7:0] data_out,
    output tx_enable
);

  localparam IDLE = 4'd0;
  localparam SET_STRING = 4'd1;
  localparam SEND_TO_PRINT = 4'd2;
  localparam WAIT_PRINT = 4'd3;

  reg [1:0] state = IDLE;
  assign printer_state = state;

  reg done = 0;
  assign printer_done = done;

  // tx
  reg tx_enable_reg = 0;
  assign tx_enable = tx_enable_reg;
  reg [7:0] data_out_r;
  assign data_out = data_out_r;


  reg [4:0] pointer;
  reg [32*8-1:0] string_reg;

  // string_rom
  wire [32*8-1:0] string_val;
  wire [4:0] length;
  string_rom _string_rom (
      .id(str_id),
      .string_val(string_val),
      .length(length)
  );

  always @(posedge clk) begin
    if (reset) begin
      state <= IDLE;
      done <= 0;
      tx_enable_reg <= 0;
      data_out_r <= 0;
      pointer <= 0;
      string_reg <= 0;
    end else begin
      case (state)
        IDLE: begin
          done <= 0;
          pointer <= 0;
          string_reg <= 0;

          if (enable) begin
            state <= SET_STRING;
          end
        end
        SET_STRING: begin
          pointer <= length - 1;
          string_reg <= string_val;
          state <= SEND_TO_PRINT;
        end
        SEND_TO_PRINT: begin
          data_out_r <= string_reg[pointer*8+:8];
          tx_enable_reg <= 1;
          state <= WAIT_PRINT;
        end
        WAIT_PRINT: begin
          tx_enable_reg <= 0;

          if (tx_done) begin
            if (pointer == 0) begin
              done <= 1;
              pointer <= 0;
              state <= IDLE;
              data_out_r <= 0;
            end else begin
              pointer <= pointer - 1;
              state   <= SEND_TO_PRINT;
            end
          end
        end
      endcase
    end
  end

endmodule
