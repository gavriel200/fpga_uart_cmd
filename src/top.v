module top (
    input clk,

    input  rst_btn,
    output led,

    input  rx,
    output tx
);

  localparam START = 3'd0;
  localparam CMD_PRE_READ = 3'd2;
  localparam CMD_READ = 3'd3;
  localparam CMD_RUN = 3'd4;
  localparam ERROR = 3'd5;

  reg [2:0] state = START;
  reg [7:0] cmd_buffer;
  reg [2:0] cmd_buffer_ptr;

  // reset button
  wire reset;

  reset_button(
      .clk(clk), .rst_btn(rst_btn), .reset(reset)
  );

  // reset debug
  assign led = !reset;

  // tx
  wire printer_tx_enable;
  wire loopback_tx_enable;
  wire read_cmd_tx_enable;  //
  wire tx_enable;

  assign tx_enable = printer_tx_enable | loopback_tx_enable | read_cmd_tx_enable;

  wire [7:0] printer_data_out;
  wire [7:0] loopback_data_out;
  wire [7:0] read_cmd_data_out;  //
  wire [7:0] data_out;

  assign data_out = printer_data_out | loopback_data_out | read_cmd_data_out;

  wire [1:0] tx_state;
  wire tx_done;

  tx(
      .clk(clk), .reset(reset), .data_out(data_out), .enable(tx_enable), .tx(tx), .tx_done(tx_done)
  );

  // rx
  wire [7:0] data_in;
  wire rx_done;
  wire [2:0] rx_state;

  rx(
      .clk(clk), .reset(reset), .rx(rx), .data_in(data_in), .rx_done(rx_done), .rx_state(rx_state)
  );

  // printer
  wire [1:0] start_printer_str_id;
  wire [1:0] pre_read_cmd_printer_str_id;
  wire [1:0] read_cmd_printer_str_id;  //
  wire [1:0] printer_str_id;

  assign printer_str_id = start_printer_str_id | pre_read_cmd_printer_str_id|read_cmd_printer_str_id;

  wire start_printer_enable;
  wire pre_read_cmd_printer_enable;
  wire read_cmd_printer_enable;  //
  wire printer_enable;

  assign printer_enable = start_printer_enable | pre_read_cmd_printer_enable | read_cmd_printer_enable;

  wire [1:0] printer_state;
  wire printer_done;

  printer(
      .clk(clk),
      .reset(reset),
      .str_id(printer_str_id),
      .enable(printer_enable),
      .tx_state(tx_state),
      .tx_done(tx_done),
      .printer_state(printer_state),
      .printer_done(printer_done),
      .data_out(printer_data_out),
      .tx_enable(printer_tx_enable)
  );

  // ========================================
  // ================ states ================
  // ========================================

  // start
  reg start_enable = 1;
  wire [1:0] start_state;
  wire start_done;
  start(
      .clk(clk),
      .reset(reset),
      .enable(start_enable),
      .printer_done(printer_done),
      .start_state(start_state),
      .start_done(start_done),
      .printer_str_id(start_printer_str_id),
      .printer_enable(start_printer_enable)
  );

  // pre_read_cmd
  reg  pre_read_cmd_enable = 0;
  wire pre_read_cmd_done;
  pre_read_cmd(
      .clk(clk),
      .reset(reset),
      .enable(pre_read_cmd_enable),
      .printer_done(printer_done),
      .pre_read_cmd_done(pre_read_cmd_done),
      .printer_str_id(pre_read_cmd_printer_str_id),
      .printer_enable(pre_read_cmd_printer_enable)
  );

  // read_cmd
  reg  read_cmd_enable = 0;
  wire read_cmd_done;
  read_cmd(
      .clk(clk),
      .reset(reset),
      // private
      .enable(read_cmd_enable),
      .read_cmd_done(read_cmd_done),
      // rx
      .rx_done(rx_done),
      .rx_state(rx_state),
      .data_in(data_in),
      // tx
      .tx_enable(read_cmd_tx_enable),
      .data_out(read_cmd_data_out)
  );


  always @(posedge clk) begin
    if (reset) begin
      state <= START;
      start_enable <= 1;
      read_cmd_enable <= 0;
    end else begin
      case (state)
        START: begin
          start_enable <= 0;

          if (start_done) begin
            state <= CMD_PRE_READ;
            pre_read_cmd_enable <= 1;
          end
        end

        CMD_PRE_READ: begin
          pre_read_cmd_enable <= 0;

          if (pre_read_cmd_done) begin
            state <= CMD_READ;
            read_cmd_enable <= 1;
          end
        end

        CMD_READ: begin
          read_cmd_enable <= 0;

          if (read_cmd_done) begin
            state <= CMD_PRE_READ;
            pre_read_cmd_enable <= 1;
          end
          // loopback enable
          // cmd_handler takes in all the data from loopback
          // once enter is pressed state changes to run if valid command
          // if invalid error
          // if empty just go back to CMP_PRE_READ
        end

        CMD_RUN: begin
          // cmd_handler takes the command and checkes what needs to be run
          // it prints or does what is needed
        end

        ERROR: begin
          // simple print error + help
          // return to cmd read
        end

      endcase
    end

  end


endmodule
