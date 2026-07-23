`timescale 1ns / 1ps

module alu(
    input clk,
    input rst,

    input [31:0] src1,
    input [31:0] src2,
    input [31:0] acc_val,
    input [5:0] alu_control,
    input [31:0] imm_val_r,
    input [3:0] shamt,

    output reg [31:0] result
);


//////////////////////////////////////////////////////////
// PIPELINED MAC
//////////////////////////////////////////////////////////

wire [31:0] mac_result;

mac_pp mac_unit_inst(
    .a(src1),
    .b(src2),
    .acc(acc_val),
    .result(mac_result)
);

//////////////////////////////////////////////////////////
// MULTIPLICATION
//////////////////////////////////////////////////////////

reg [63:0] mul_result;

//////////////////////////////////////////////////////////
// ALU LOGIC
//////////////////////////////////////////////////////////

always @(*)
begin

    result = 32'b0;
    mul_result = 64'b0;

    case(alu_control)

    //////////////////////////////////////////////////
    // R-TYPE
    //////////////////////////////////////////////////

    6'b000001:
        result = src1 + src2;

    6'b000010:
        result = src1 - src2;

    6'b000011:
        result = src1 << src2[4:0];

    6'b000100:
        result = ($signed(src1) < $signed(src2)) ? 1 : 0;

    6'b000101:
        result = ($unsigned(src1) < $unsigned(src2)) ? 1 : 0;

    6'b000110:
        result = src1 ^ src2;

    6'b000111:
        result = src1 >> src2[4:0];

    6'b001000:
        result = $signed(src1) >>> src2[4:0];

    6'b001001:
        result = src1 | src2;

    6'b001010:
        result = src1 & src2;

    //////////////////////////////////////////////////
    // MUL FAMILY
    //////////////////////////////////////////////////

    6'b100001:
        result = src1 * src2;

    6'b100010:
    begin
        mul_result = $signed(src1) * $signed(src2);
        result = mul_result[63:32];
    end

    6'b100011:
    begin
        mul_result = $signed(src1) * $unsigned(src2);
        result = mul_result[63:32];
    end

    6'b100100:
    begin
        mul_result = $unsigned(src1) * $unsigned(src2);
        result = mul_result[63:32];
    end

    //////////////////////////////////////////////////
    // MAC
    //////////////////////////////////////////////////

    6'b101000:
        result = mac_result;

    //////////////////////////////////////////////////
    // I-TYPE
    //////////////////////////////////////////////////

    6'b001011:
        result = src1 + imm_val_r;

    6'b001100:
        result = src1 << shamt;

    6'b001101:
        result = ($signed(src1) < $signed(imm_val_r)) ? 1 : 0;

    6'b001111:
        result = src1 ^ imm_val_r;

    6'b010000:
        result = src1 >> imm_val_r[4:0];

    6'b010011:
        result = $signed(src1) >>> imm_val_r[4:0];

    6'b010001:
        result = src1 | imm_val_r;

    6'b010010:
        result = src1 & imm_val_r;

    //////////////////////////////////////////////////
    // BRANCH
    //////////////////////////////////////////////////

    6'b011011:
        result = (src1 == src2) ? 1 : 0;

    6'b011100:
        result = (src1 != src2) ? 1 : 0;

    6'b011111:
        result = ($signed(src2) >= $signed(src1)) ? 1 : 0;

    6'b100000:
        result = ($signed(src1) < $signed(src2)) ? 1 : 0;

    default:
        result = 32'b0;

    endcase
end

endmodule