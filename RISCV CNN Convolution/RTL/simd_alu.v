`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.04.2026 22:55:18
// Design Name: 
// Module Name: simd_alu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module simd_alu(
    input [31:0] a,
    input [31:0] b,
    output [31:0] result
);

// 4x8-bit parallel addition
assign result[7:0]   = a[7:0]   + b[7:0];
assign result[15:8]  = a[15:8]  + b[15:8];
assign result[23:16] = a[23:16] + b[23:16];
assign result[31:24] = a[31:24] + b[31:24];

endmodule