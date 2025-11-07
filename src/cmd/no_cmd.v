module no_cmd (
    input [8*32-1:0] cmd,
    input [8*32-1:0] arg_1,
    input [8*32-1:0] arg_2,
    output valid
);
  localparam [8*32-1:0] no_cmd_data = 0;
  assign valid = cmd == no_cmd_data && arg_1 == no_cmd_data && arg_2 == no_cmd_data;
endmodule
