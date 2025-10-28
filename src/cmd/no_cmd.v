module no_cmd (
    input [32*8-1:0] cmd,
    output valid
);
  localparam [32*8-1:0] no_cmd_data = 0;
  assign valid = cmd == no_cmd_data;
endmodule
