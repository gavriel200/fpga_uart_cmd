
module string_rom (
    input [3:0] id,
    output reg [8*32-1:0] string_val,
    output reg [4:0] length
);

  localparam START = 8'd0;
  localparam SHELL = 8'd1;
  localparam ERROR = 8'd2;
  localparam PONG = 8'd3;
  localparam HELP = 8'd4;
  localparam HELP_HELP = 8'd5;
  localparam PING_HELP = 8'd6;
  localparam LED_HELP = 8'd7;

  always @(*) begin
    case (id)
      START: begin
        string_val = {8'h0D, 8'h0A, 8'h0D, 8'h0D, 8'h0A, 8'h0D, "starting program"};
        length = 24;
      end
      SHELL: begin
        string_val = {8'h0D, 8'h0A, 8'h0D, 8'h24, 8'h3E};  // /n/r/n$>
        length = 4;
      end
      ERROR: begin
        string_val = {8'h0D, 8'h0A, 8'h0D, "error: invalid command"};
        length = 25;
      end
      PONG: begin
        string_val = {8'h0D, 8'h0A, 8'h0D, "PONG"};
        length = 7;
      end
      HELP: begin
        string_val = {
          8'h0D,
          8'h0A,
          8'h0D,
          "commands:",
          8'h0D,
          8'h0A,
          8'h0D,
          "- help",
          8'h0D,
          8'h0A,
          8'h0D,
          "- ping"
        };
        length = 30;
      end
      HELP_HELP: begin
        string_val = {8'h0D, 8'h0A, 8'h0D, "help: prints all the cmd"};
        length = 27;
      end
      PING_HELP: begin
        string_val = {8'h0D, 8'h0A, 8'h0D, "ping: returns pong"};
        length = 21;
      end
      LED_HELP: begin
        string_val = {8'h0D, 8'h0A, 8'h0D, "led [on/off] [1/2/3/4]"};
        length = 25;
      end
    endcase
  end

endmodule
