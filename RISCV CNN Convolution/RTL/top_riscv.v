`timescale 1ns / 1ps

module top_riscv(

    input clk,
    input reset,

    output debug_out,

    output [31:0] x1_out,
    output [31:0] x2_out,
    output [31:0] x3_out,
    output [31:0] x4_out

);

//////////////////////////////////////////////////////////
// WIRES
//////////////////////////////////////////////////////////

wire [31:0] pc;
wire [31:0] instruction_out;
wire [31:0] store_imm;

//////////////////////////////////////////////////////////
// CONTROL SIGNALS
//////////////////////////////////////////////////////////

wire [5:0] alu_control;

wire lb;
wire sw;

wire reg_write;

wire mem_to_reg;

wire bneq_control;
wire beq_control;

wire bgeq_control;
wire blt_control;

wire jump;

wire lui_control;

//////////////////////////////////////////////////////////
// IMMEDIATE VALUES
//////////////////////////////////////////////////////////

wire [31:0] imm_val;

wire [31:0] imm_val_branch_top;

wire [31:0] imm_val_lui;

wire [31:0] imm_val_jump;

//////////////////////////////////////////////////////////
// BRANCH FLAGS
//////////////////////////////////////////////////////////

wire beq;
wire bneq;

wire bge;
wire blt;

//////////////////////////////////////////////////////////
// DATA MEMORY
//////////////////////////////////////////////////////////

wire [4:0] read_data_addr_dm;

//////////////////////////////////////////////////////////
// CURRENT PC
//////////////////////////////////////////////////////////

wire [31:0] current_pc;

//////////////////////////////////////////////////////////
// DEBUG REGISTERS
//////////////////////////////////////////////////////////

wire [31:0] x1;
wire [31:0] x2;
wire [31:0] x3;
wire [31:0] x4;
wire [31:0] x5;
wire [31:0] x6;
wire [31:0] x7;
wire [31:0] x8;
wire [31:0] x9;
wire [31:0] x10;
wire [31:0] x11;
wire [31:0] x12;
wire [31:0] x13;

//////////////////////////////////////////////////////////
// INSTRUCTION FETCH UNIT
//////////////////////////////////////////////////////////

instruction_fetch_unit ifu(

    .clk(clk),

    .reset(reset),

    .imm_address(imm_val_branch_top),

    .imm_address_jump(imm_val_jump),

    .beq(beq),

    .bneq(bneq),

    .bge(bge),

    .blt(blt),

    .jump(jump),

    .pc(pc),

    .current_pc(current_pc)

);

//////////////////////////////////////////////////////////
// INSTRUCTION MEMORY
//////////////////////////////////////////////////////////

instruction_memory imu(

    .pc(pc),

    .instruction_code(instruction_out)

);

//////////////////////////////////////////////////////////
// CONTROL UNIT
//////////////////////////////////////////////////////////

control_unit cu(

    .reset(reset),

    .funct7(instruction_out[31:25]),

    .funct3(instruction_out[14:12]),

    .opcode(instruction_out[6:0]),

    .alu_control(alu_control),

    .lb(lb),

    .mem_to_reg(mem_to_reg),

    .bneq_control(bneq_control),

    .beq_control(beq_control),

    .bgeq_control(bgeq_control),

    .blt_control(blt_control),

    .jump(jump),

    .sw(sw),

    .lui_control(lui_control),

    .reg_write(reg_write)

);

//////////////////////////////////////////////////////////
// DATA PATH
//////////////////////////////////////////////////////////

data_path dpu(

    .clk(clk),

    .rst(reset),

    .read_reg_num1(instruction_out[19:15]),

    .read_reg_num2(instruction_out[24:20]),

    .write_reg_num1(instruction_out[11:7]),

    .alu_control(alu_control),

    .jump(jump),

    .beq_control(beq_control),

    .bne_control(bneq_control),

    .imm_val(sw ? store_imm : imm_val),

    .shamt(imm_val[4:0]),

    .lb(lb),

    .sw(sw),

    .reg_write(reg_write),

    .bgeq_control(bgeq_control),

    .blt_control(blt_control),

    .lui_control(lui_control),

    .imm_val_lui(imm_val_lui),

    .read_data_addr_dm(read_data_addr_dm),

    .beq(beq),

    .bneq(bneq),

    .bge(bge),

    .blt(blt),

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
// IMMEDIATE GENERATION
//////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////
// I-TYPE IMMEDIATE
//////////////////////////////////////////////////////////

assign imm_val =
{
    {20{instruction_out[31]}},
    instruction_out[31:20]
};

//////////////////////////////////////////////////////////
// BRANCH IMMEDIATE
//////////////////////////////////////////////////////////

assign imm_val_branch_top =
{
    {19{instruction_out[31]}},
    instruction_out[31],
    instruction_out[7],
    instruction_out[30:25],
    instruction_out[11:8],
    1'b0
};

//////////////////////////////////////////////////////////
// LUI IMMEDIATE
//////////////////////////////////////////////////////////

assign imm_val_lui =
{
    instruction_out[31:12],
    12'b0
};

//////////////////////////////////////////////////////////
// JAL IMMEDIATE
//////////////////////////////////////////////////////////

assign imm_val_jump =
{
    {11{instruction_out[31]}},
    instruction_out[31],
    instruction_out[19:12],
    instruction_out[20],
    instruction_out[30:21],
    1'b0
};

//////////////////////////////////////////////////////////
// STORE IMMEDIATE
//////////////////////////////////////////////////////////

assign store_imm =
{
    {20{instruction_out[31]}},
    instruction_out[31:25],
    instruction_out[11:7]
};

//////////////////////////////////////////////////////////
// DEBUG OUTPUT
//////////////////////////////////////////////////////////

assign debug_out = x4[0];

assign x1_out = x1;
assign x2_out = x2;
assign x3_out = x3;
assign x4_out = x4;

//////////////////////////////////////////////////////////
// DEBUG MONITOR
//////////////////////////////////////////////////////////

always @(posedge clk)
begin

    $display("================================");

    $display("PC   = %0d", pc);
    $display("INST = %h", instruction_out);

    $display("x1  = %0d", x1);
    $display("x2  = %0d", x2);
    $display("x3  = %0d", x3);
    $display("x4  = %0d", x4);
    $display("x5  = %0d", x5);
    $display("x6  = %0d", x6);
    $display("x7  = %0d", x7);
    $display("x8  = %0d", x8);
    $display("x9  = %0d", x9);
    $display("x10 = %0d", x10);
    $display("x11 = %0d", x11);
    $display("x12 = %0d", x12);
    $display("x13 = %0d", x13);

    $display(
        "lb=%b sw=%b reg_write=%b",
        lb,
        sw,
        reg_write
    );

    $display("alu_control = %b", alu_control);

    //////////////////////////////////////////////////////
    // STORE DEBUG
    //////////////////////////////////////////////////////

    if(sw)
    begin

        $display("");
        $display(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
        $display("STORE DEBUG");
        $display("PC          = %0d", pc);
        $display("Instruction = %h", instruction_out);

        // S-type immediate after decoding
        $display(
            "Store IMM   = %0d",
            $signed(store_imm)
        );

        // ALU result is the actual data-memory address
        $display(
            "Store ADDR  = %0d",
            dpu.alu_result
        );

        // rs2 contains the value being stored
        $display(
            "Store DATA  = %h",
            dpu.data_out_2_dm
        );

        $display(
            "Store DATA decimal = %0d",
            $signed(dpu.data_out_2_dm)
        );

        $display("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
        $display("");

    end

    $display("================================");

end

endmodule