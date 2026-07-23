`timescale 1ns / 1ps

module data_path(

    input clk,
    input rst,

    input [4:0] read_reg_num1,
    input [4:0] read_reg_num2,
    input [4:0] write_reg_num1,

    input [5:0] alu_control,

    input jump,
    input beq_control,
    input bne_control,

    input [31:0] imm_val,
    input [3:0] shamt,

    input lb,
    input sw,

    input reg_write,     // ✅ NEW

    input bgeq_control,
    input blt_control,

    input lui_control,
    input [31:0] imm_val_lui,

    output [4:0] read_data_addr_dm,

    output beq,
    output bneq,
    output bge,
    output blt,

    // debug
    output [31:0] x1,
output [31:0] x2,
output [31:0] x3,
output [31:0] x4,
output [31:0] x5,
output [31:0] x6,
output [31:0] x7,
output [31:0] x8,
output [31:0] x9,
output [31:0] x10,
output [31:0] x11,
output [31:0] x12,
output [31:0] x13
);

//////////////////////////////////////////////////////////
// INTERNAL WIRES
//////////////////////////////////////////////////////////

wire [31:0] read_data1;
wire [31:0] read_data2;

wire [4:0] read_data_addr_dm_2;

wire [31:0] alu_result;

wire [31:0] data_out;
wire [31:0] data_out_2_dm;

wire [31:0] write_back_data;

//////////////////////////////////////////////////////////
// WRITEBACK MUX
//////////////////////////////////////////////////////////

assign write_back_data =
    (lb) ? data_out : alu_result;

//////////////////////////////////////////////////////////
// REGISTER FILE
//////////////////////////////////////////////////////////

register_file rfu(

    .clk(clk),
    .rst(rst),

    .read_reg_num1(read_reg_num1),
    .read_reg_num2(read_reg_num2),

    .write_reg_num1(write_reg_num1),

    .write_data_dm(write_back_data),

    .reg_write(reg_write),

    .lb(lb),

    .lui_control(lui_control),

    .lui_imm_val(imm_val_lui),

    .jump(jump),

    .sw(sw),

    .read_data1(read_data1),
    .read_data2(read_data2),

    .read_data_addr_dm(read_data_addr_dm_2),

    .data_out_2_dm(data_out_2_dm),

    .x1(x1),
    .x2(x2),
    .x3(x3),
    .x4(x4),
    .x5(x5),
    .x6(x6),
    .x7(x7),
    .x8(x8),
.x9(x9),
.x10(x10),
.x11(x11),
.x12(x12),
.x13(x13)

);

//////////////////////////////////////////////////////////
// ALU
//////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////
// ALU
//////////////////////////////////////////////////////////

alu alu_unit(

    .clk(clk),
    .rst(rst),

    .src1(read_data1),
    .src2(read_data2),

    .acc_val(x4),

    .alu_control(alu_control),

    .imm_val_r(imm_val),

    .shamt(shamt),

    .result(alu_result)

);
//////////////////////////////////////////////////////////
// DATA MEMORY
//////////////////////////////////////////////////////////

data_memory dmu(

    .clk(clk),

    .rst(rst),

    .wr_addr(alu_result[12:0]),

    .wr_data(data_out_2_dm),

    .sw(sw),

    .rd_addr(alu_result[12:0]),

    .data_out(data_out)

);



//////////////////////////////////////////////////////////
// MEMORY ADDRESS OUTPUT
//////////////////////////////////////////////////////////

assign read_data_addr_dm = read_data_addr_dm_2;

//////////////////////////////////////////////////////////
// BRANCH LOGIC
//////////////////////////////////////////////////////////

assign beq  = (alu_result == 1 && beq_control);

assign bneq = (alu_result == 1 && bne_control);

assign bge  = (alu_result == 1 && bgeq_control);

assign blt  = (alu_result == 1 && blt_control);

//////////////////////////////////////////////////////////
// STORE ADDRESS DEBUG
//////////////////////////////////////////////////////////

integer store_debug_count = 0;

always @(posedge clk)
begin
    if(sw)
    begin
        $display(
            "STORE_DEBUG #%0d FULL_ALU=%0d HEX=%h MEM_ADDR=%0d DATA=%0d",
            store_debug_count,
            $signed(alu_result),
            alu_result,
            alu_result[12:0],
            $signed(data_out_2_dm)
        );

        store_debug_count = store_debug_count + 1;
    end
end

endmodule