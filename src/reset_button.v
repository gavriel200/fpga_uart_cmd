module reset_button (
    input  clk,
    input  rst_btn,
    output reset
);

  reg [25:0] timer = 0;
  reg reset_reg = 0;

  assign reset = reset_reg;

  always @(posedge clk) begin
    if (!rst_btn) begin
      if (timer < 54000000 - 1) begin
        timer <= timer + 1;
      end else begin
        reset_reg <= 1;
      end
    end else begin
      timer <= 0;
      reset_reg <= 0;
    end
  end

endmodule
