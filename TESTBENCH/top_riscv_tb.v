`timescale 1ns /1ps

module top_riscv_tb;

reg clk;
reg reset;

wire debug_out;

wire [31:0] x1_out;
wire [31:0] x2_out;
wire [31:0] x3_out;
wire [31:0] x4_out;

integer fp;
integer i;

//////////////////////////////////////////////////////
// DUT
//////////////////////////////////////////////////////

top_riscv dut(

    .clk(clk),
    .reset(reset),

    .debug_out(debug_out),

    .x1_out(x1_out),
    .x2_out(x2_out),
    .x3_out(x3_out),
    .x4_out(x4_out)

);

//////////////////////////////////////////////////////
// CLOCK
//////////////////////////////////////////////////////

always #5 clk = ~clk;

//////////////////////////////////////////////////////
// TEST
//////////////////////////////////////////////////////

initial
begin

    clk = 0;
    reset = 1;

    //////////////////////////////////////////////////////
    // RESET
    //////////////////////////////////////////////////////

    #20;
    reset = 0;

    //////////////////////////////////////////////////////
    // WAIT FOR COMPLETE CONVOLUTION
    //////////////////////////////////////////////////////

    #250000;

    //////////////////////////////////////////////////////
    // DEBUG
    //////////////////////////////////////////////////////

    $display("");
    $display("================================");
    $display("SIMULATION COMPLETE");
    $display("================================");

    $display("x1 = %0d", x1_out);
    $display("x2 = %0d", x2_out);
    $display("x3 = %0d", x3_out);
    $display("x4 = %0d", x4_out);

    //////////////////////////////////////////////////////
    // OPEN OUTPUT FILE
    //////////////////////////////////////////////////////

    fp = $fopen("output_y_30.mem","w");

    if(fp == 0)
    begin
        $display("ERROR: Cannot open output_x_30.mem");
        $finish;
    end

    //////////////////////////////////////////////////////
    // DUMP 30 x 30 SOBEL-X RESULTS
    //
    // First output address = 1984
    // Last output address  = 2883
    // Total outputs        = 900
    //////////////////////////////////////////////////////

    for(i = 1984; i < 2884; i = i + 1)
    begin

        $fdisplay(
            fp,
            "%08x",
            dut.dpu.dmu.data_mem[i]
        );

    end

    //////////////////////////////////////////////////////
    // CLOSE FILE
    //////////////////////////////////////////////////////

    $fclose(fp);

    $display("--------------------------------");
    $display("output_y_30.mem generated");
    $display("Output range = 1984 to 2883");
    $display("Pixels dumped = 900");
    $display("--------------------------------");

    $finish;

end

endmodule
