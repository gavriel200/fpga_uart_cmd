module start(
    input clk,
    input enable,
    
    output reg [1:0] state,
    output done
);

localparam INIT = 4'd0;
localparam SENDING = 4'd1;
localparam DONE 4'd2;

always @(posedge clk) begin
    
end

    
endmodule