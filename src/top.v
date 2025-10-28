module top (
    input clk,

    input  rst_btn,
    output led,

    input  rx,
    output tx
);

  localparam START = 3'd0;
  localparam CMD_PRE_READ = 3'd1;
  localparam CMD_READ = 3'd2;
  localparam CMD_RUN = 3'd3;

  reg [1:0] state = START;
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
  wire start_printer_enable;
  wire pre_read_cmd_printer_enable;
  wire ping_printer_enable;
  wire help_printer_enable;
  wire error_printer_enable;
  wire printer_enable;

  assign printer_enable = start_printer_enable | pre_read_cmd_printer_enable | ping_printer_enable | help_printer_enable |error_printer_enable ;

  wire [2:0] start_printer_str_id;
  wire [2:0] pre_read_cmd_printer_str_id;
  wire [2:0] ping_printer_str_id;
  wire [2:0] help_printer_str_id;
  wire [2:0] error_printer_str_id;
  wire [2:0] printer_str_id;
  assign printer_str_id = start_printer_enable ? start_printer_str_id :
                       pre_read_cmd_printer_enable ? pre_read_cmd_printer_str_id :
                       ping_printer_enable ? ping_printer_str_id :
                       help_printer_enable ? help_printer_str_id :
                       error_printer_enable ? error_printer_str_id :
                       2'b00;

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
  // ================= cmd ==================
  // ========================================

  // read_cmd - cmd validation
  wire [32*8-1:0] cmd;

  // ping
  wire ping_enable;
  wire ping_done;
  wire ping_valid;
  ping(
      .clk(clk),
      .reset(reset),
      .enable(ping_enable),
      .ping_done(ping_done),
      .cmd(cmd),
      .valid(ping_valid),
      .printer_done(printer_done),
      .printer_str_id(ping_printer_str_id),
      .printer_enable(ping_printer_enable)
  );

  // help
  wire help_enable;
  wire help_done;
  wire help_valid;
  help(
      .clk(clk),
      .reset(reset),
      .enable(help_enable),
      .help_done(help_done),
      .cmd(cmd),
      .valid(help_valid),
      .printer_done(printer_done),
      .printer_str_id(help_printer_str_id),
      .printer_enable(help_printer_enable)
  );

  // error
  wire error_enable;
  wire error_done;
  error(
      .clk(clk),
      .reset(reset),
      .enable(error_enable),
      .error_done(error_done),
      .printer_done(printer_done),
      .printer_str_id(error_printer_str_id),
      .printer_enable(error_printer_enable)
  );

  wire no_cmd_valid;
  no_cmd(
      .cmd(cmd), .valid(no_cmd_valid)
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
  reg pre_read_cmd_enable = 0;
  wire pre_read_cmd_done;
  wire [1:0] pre_read_cmd_state;
  pre_read_cmd(
      .clk(clk),
      .reset(reset),
      .enable(pre_read_cmd_enable),
      .printer_done(printer_done),
      .pre_read_cmd_done(pre_read_cmd_done),
      .printer_str_id(pre_read_cmd_printer_str_id),
      .printer_enable(pre_read_cmd_printer_enable),
      .pre_read_cmd_state(pre_read_cmd_state)
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
      .cmd(cmd),
      // rx
      .rx_done(rx_done),
      .rx_state(rx_state),
      .data_in(data_in),
      // tx
      .tx_enable(read_cmd_tx_enable),
      .data_out(read_cmd_data_out)
  );

  // run_cmd
  reg  run_cmd_enable = 0;
  wire run_cmd_done;
  wire run_cmd_state;

  wire valid_cmd_debug;

  run_cmd(
      .clk(clk),
      .reset(reset),
      // private
      .enable(run_cmd_enable),
      .run_cmd_done(run_cmd_done),
      // ping
      .ping_enable(ping_enable),
      .ping_done(ping_done),
      // ping
      .help_enable(help_enable),
      .help_done(help_done),
      // error
      .error_enable(error_enable),
      .error_done(error_done),
      // no_cmd
      .no_cmd_valid(no_cmd_valid),
      .valid_cmd_debug(valid_cmd_debug)
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
            state <= CMD_RUN;
            run_cmd_enable <= 1;
          end
        end

        CMD_RUN: begin
          run_cmd_enable <= 0;

          if (run_cmd_done) begin
            state <= CMD_PRE_READ;
            pre_read_cmd_enable <= 1;
          end
        end
      endcase
    end

  end


endmodule
