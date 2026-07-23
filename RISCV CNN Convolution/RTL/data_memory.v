`timescale 1ns / 1ps

module data_memory(

    input clk,
    input rst,

    input [12:0] wr_addr,
    input [31:0] wr_data,

    input sw,

    input [12:0] rd_addr,

    output [31:0] data_out

);

reg [31:0] data_mem [0:8191];

integer i;

//////////////////////////////////////////////////////////
// LOAD IMAGE
//////////////////////////////////////////////////////////

initial
begin
    $readmemh("DOG_32.mem", data_mem);
end

//////////////////////////////////////////////////////////
// WRITE LOGIC
//////////////////////////////////////////////////////////

always @(posedge clk)
begin

    if(sw)
    begin

        data_mem[wr_addr] <= wr_data;

        $display("STORE: PC? addr=%0d data=%h",
                 wr_addr,
                 wr_data);

    end

end

//////////////////////////////////////////////////////////
// READ LOGIC
//////////////////////////////////////////////////////////

assign data_out = data_mem[rd_addr];

//////////////////////////////////////////////////////////
// DUMP OUTPUT IMAGE
//////////////////////////////////////////////////////////

integer fp;
/*
final
begin

    fp = $fopen("output.mem","w");

    for(i=1984;i<2884;i=i+1)
        $fdisplay(fp,"%02x",data_mem[i][7:0]);

    $fclose(fp);

    $display("output.mem generated");

end
*/

endmodule