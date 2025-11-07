module no_cmd (
    input [8*32-1:0] cmd,
    output valid
);
  localparam [8*32-1:0] no_cmd_data = 0;
  assign valid = cmd == no_cmd_data;
endmodule
