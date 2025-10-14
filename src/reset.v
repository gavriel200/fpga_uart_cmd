module reset (
    input  clk,
    input  rst_btn,
    output reset_reset
);

  reg [27:0] timer = 0;
  reg reset = 0;

  assign reset_reset = reset;

  always @(posedge clk) begin
    if (!rst_btn) begin
      if (timer < 135000000 - 1) begin
        timer <= timer + 1;
      end else begin
        reset <= 1;
      end
    end else begin
      timer <= 0;
      reset <= 0;
    end
  end

endmodule
