module string_rom (
    input [1:0] id,
    output reg [32*8-1:0] string_val,
    output reg [4:0] length
);

  localparam START = 4'd0;
  localparam SHELL = 4'd1;
  localparam ERROR = 4'd2;
  localparam PONG = 4'd3;

  always @(*) begin
    case (id)
      START: begin
        string_val = "starting program";
        length = 16;
      end
      SHELL: begin
        string_val = {8'h0D, 8'h0A, 8'h24, 8'h3E};  // /n/r$>
        length = 3;
      end
      ERROR: begin
        string_val = "error: invalid command";
        length = 22;
      end
      PONG: begin
        string_val = "PONG";
        length = 4;
      end
    endcase
  end

endmodule
