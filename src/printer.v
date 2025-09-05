module printer(
    input str_id,
    input enable,

    output tx
);

localparam NUM_OF_STRINGS = 8;
localparam STRING_LENGTH = 256;

reg [7:0] strings [NUM_OF_STRINGS-1:0] [STRING_LENGTH-1:0];


// [[10, 10 10]]
// [0][0]

endmodule