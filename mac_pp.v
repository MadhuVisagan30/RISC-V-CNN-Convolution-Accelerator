`timescale 1ns / 1ps


module mac_pp(

    input signed [31:0] a,
    input signed [31:0] b,
    input signed [31:0] acc,

    output signed [31:0] result

);

assign result = (a * b) + acc;

endmodule