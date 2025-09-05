module string_rom(
    input [1:0] id,
    output reg [32*8-1:0] string,
    output reg [4:0] length
);

localparam START = 4'd0;
localparam SHELL = 4'd1;
localparam ERROR = 4'd2;
localparam PONG = 4'd3;

always @(*) begin
    case (id)
    START: begin
        string = "strting program";
        length = 15;
    end
    SHELL: begin
        string = "\n$>";
        length = 3;
    end
    ERROR: begin
        string = "error: invalid command";
        length = 22;
    end
    PONG: begin
        string = "PONG";
        length = 4;
    end
    endcase
end

endmodule