module loopback (
    input clk,
    input reset,

    // private
    input enable,

    // rx
    input rx_done,
    input [2:0] rx_state,
    input [7:0] data_in,

    // tx
    output tx_enable,
    output [7:0] data_out
);

  // when active just takes in rx and puts it in tx.
  // need to make sure that its done before continueing with the states

  localparam IDLE = 1'd0;
  localparam WORKING = 1'd0;

  reg tx_enable_reg;

  assign tx_enable = tx_enable_reg;

  assign data_out  = data_in;

  always @(posedge clk) begin
    if (reset) begin
      tx_enable_reg <= 0;
    end else begin

      if (enable & rx_done) begin
        tx_enable_reg <= 1;
      end else begin
        tx_enable_reg <= 0;
      end
    end
  end

endmodule
