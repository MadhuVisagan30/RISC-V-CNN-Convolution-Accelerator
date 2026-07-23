`timescale 1ns / 1ps

module conv_pixel;

//////////////////////////////////////////////////////////
// MEMORY
//////////////////////////////////////////////////////////

reg signed [31:0] mem [0:241000];

integer outfile;

integer row;
integer col;

reg signed [31:0] p0,p1,p2;
reg signed [31:0] p3,p4,p5;
reg signed [31:0] p6,p7,p8;

wire signed [31:0] k0,k1,k2;
wire signed [31:0] k3,k4,k5;
wire signed [31:0] k6,k7,k8;

assign k0 = mem[240100];
assign k1 = mem[240101];
assign k2 = mem[240102];

assign k3 = mem[240103];
assign k4 = mem[240104];
assign k5 = mem[240105];

assign k6 = mem[240106];
assign k7 = mem[240107];
assign k8 = mem[240108];

//////////////////////////////////////////////////////////
// MAC CHAIN
//////////////////////////////////////////////////////////

wire signed [31:0] s1,s2,s3,s4,s5,s6,s7,s8;
wire signed [31:0] conv_result;

mac_pp m0(.a(p0), .b(k0), .acc(32'd0), .result(s1));
mac_pp m1(.a(p1), .b(k1), .acc(s1),    .result(s2));
mac_pp m2(.a(p2), .b(k2), .acc(s2),    .result(s3));
mac_pp m3(.a(p3), .b(k3), .acc(s3),    .result(s4));
mac_pp m4(.a(p4), .b(k4), .acc(s4),    .result(s5));
mac_pp m5(.a(p5), .b(k5), .acc(s5),    .result(s6));
mac_pp m6(.a(p6), .b(k6), .acc(s6),    .result(s7));
mac_pp m7(.a(p7), .b(k7), .acc(s7),    .result(s8));
mac_pp m8(.a(p8), .b(k8), .acc(s8),    .result(conv_result));

//////////////////////////////////////////////////////////
// OUTPUT PIXEL
//////////////////////////////////////////////////////////

integer blur_pixel;

//////////////////////////////////////////////////////////
// MAIN
//////////////////////////////////////////////////////////

initial
begin

    $readmemh("dog_original.mem", mem);
$display("Pixel0    = %d", mem[0]);
$display("Pixel1    = %d", mem[1]);
$display("Pixel239999 = %d", mem[239999]);

$display("Kernel0 = %d", mem[240100]);
$display("Kernel1 = %d", mem[240101]);
$display("Kernel2 = %d", mem[240102]);

    outfile = $fopen("DOG_y_490.mem","w");
    if(outfile == 0)
begin
    $display("ERROR: Cannot open output file!");
    $finish;
end
else
    $display("Output file opened successfully.");

    for(row=0; row<488; row=row+1)
    begin
        for(col=0; col<488; col=col+1)
        begin
        if(row==0 && col==0)
            $display("Loop started");

            p0 = mem[(row*490)+col];
            p1 = mem[(row*490)+col+1];
            p2 = mem[(row*490)+col+2];

            p3 = mem[((row+1)*490)+col];
            p4 = mem[((row+1)*490)+col+1];
            p5 = mem[((row+1)*490)+col+2];

            p6 = mem[((row+2)*490)+col];
            p7 = mem[((row+2)*490)+col+1];
            p8 = mem[((row+2)*490)+col+2];

            #1;
//////////////////////////////////////////////////////////
// DEBUG WINDOW (Center of Image)
//////////////////////////////////////////////////////////

if(row==15 && col==15)
begin
    $display("==========================================");
    $display("DEBUG WINDOW @ row=%0d col=%0d",row,col);

    $display("p0=%0d  p1=%0d  p2=%0d",p0,p1,p2);
    $display("p3=%0d  p4=%0d  p5=%0d",p3,p4,p5);
    $display("p6=%0d  p7=%0d  p8=%0d",p6,p7,p8);

    $display("");

    $display("k0=%0d  k1=%0d  k2=%0d",k0,k1,k2);
    $display("k3=%0d  k4=%0d  k5=%0d",k3,k4,k5);
    $display("k6=%0d  k7=%0d  k8=%0d",k6,k7,k8);

    $display("");

    $display("conv_result = %0d",conv_result);

    if(conv_result < 0)
        $display("abs(conv) = %0d",-conv_result);
    else
        $display("abs(conv) = %0d",conv_result);

    $display("==========================================");
end

           // Absolute value for edge magnitude

if(conv_result < 0)
    blur_pixel = -conv_result;
else
    blur_pixel = conv_result;


// Clamp

if(blur_pixel > 255)
    blur_pixel = 255;

            $fdisplay(outfile,"%02h", blur_pixel[7:0]);

        end
    end

    $fclose(outfile);

    $display("--------------------------------");
    $display("CNN COMPLETE");
    $display("output_image.mem generated");
    $display("--------------------------------");

    $finish;

end

endmodule