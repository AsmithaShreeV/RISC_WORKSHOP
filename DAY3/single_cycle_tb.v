
`timescale 1ns/1ps

module day3_tb;

reg clk = 0;
reg reset = 1;

wire [31:0] pc;
wire [31:0] instruction;
wire [31:0] alu_result;
wire reg_write;
wire [4:0] rd;
wire [31:0] writeback_data;

day3_single_cycle dut(
    .clk(clk),
    .reset(reset),
    .pc(pc),
    .instruction(instruction),
    .alu_result(alu_result),
    .reg_write(reg_write),
    .rd(rd),
    .writeback_data(writeback_data)
);

always #5 clk = ~clk;

// ADDI instruction
function [31:0] I;
input [11:0] im;
input [4:0] s1,d;
input [2:0] f;
input [6:0] op;
begin
    I = {im,s1,f,d,op};
end
endfunction

// R-type instruction
function [31:0] R;
input [6:0] f7;
input [4:0] s2,s1,d;
input [2:0] f3;
begin
    R = {f7,s2,s1,f3,d,7'h33};
end
endfunction

// SW instruction
function [31:0] S;
input [11:0] im;
input [4:0] s2,s1;
begin
    S = {im[11:5],s2,s1,3'b010,im[4:0],7'h23};
end
endfunction

// Branch instruction
function [31:0] B;
input integer off;
input [4:0] s2,s1;
input [2:0] f3;
reg [12:0] x;
begin
    x = off;
    B = {x[12],x[10:5],s2,s1,f3,
         x[4:1],x[11],7'h63};
end
endfunction

integer cycles;
integer k;

// Clear memories and registers
task clear_prog;
begin
    for(k=0;k<256;k=k+1) begin
        dut.imem[k] = 32'h00000013;
        dut.dmem[k] = 0;
    end

    for(k=0;k<32;k=k+1)
        dut.regs[k] = 0;

    dut.pc = 0;
end
endtask

initial begin

    $dumpfile("day3.vcd");
    $dumpvars(0,day3_tb);

    // --------------------------------
    // PROGRAM 1: SUM OF 1 TO 10
    // --------------------------------

    reset = 1;
    #12;
    clear_prog;

    dut.imem[0] = I(10,0,0,1,7'h13);
    dut.imem[1] = I(1,0,0,2,7'h13);
    dut.imem[2] = I(0,0,0,3,7'h13);
    dut.imem[3] = R(0,2,3,3,0);
    dut.imem[4] = I(-1,1,0,1,7'h13);
    dut.imem[5] = B(-8,0,1,1);
    dut.imem[6] = S(0,3,0);

    reset = 0;

    repeat(15) @(posedge clk);
    @(negedge clk);

    if(dut.dmem[0] == 55)
        $display("PROGRAM 1 PASS: SUM = %0d",
                  dut.dmem[0]);
    else
        $display("PROGRAM 1 FAIL: SUM = %0d",
                  dut.dmem[0]);


    // --------------------------------
    // PROGRAM 2: FIBONACCI SEQUENCE
    // --------------------------------

    reset = 1;
    #10;
    clear_prog;

    dut.imem[0] = I(0,0,0,1,7'h13);
    dut.imem[1] = I(1,0,0,2,7'h13);

    dut.imem[2] = S(0,1,0);
    dut.imem[3] = S(4,2,0);

    dut.imem[4] = R(0,1,2,3,0);
    dut.imem[5] = S(8,3,0);

    dut.imem[6] = I(0,2,0,1,7'h13);
    dut.imem[7] = I(0,3,0,2,7'h13);
    dut.imem[8] = R(0,1,2,3,0);
    dut.imem[9] = S(12,3,0);

    dut.imem[10] = I(0,2,0,1,7'h13);
    dut.imem[11] = I(0,3,0,2,7'h13);
    dut.imem[12] = R(0,1,2,3,0);
    dut.imem[13] = S(16,3,0);

    dut.imem[14] = I(0,2,0,1,7'h13);
    dut.imem[15] = I(0,3,0,2,7'h13);
    dut.imem[16] = R(0,1,2,3,0);
    dut.imem[17] = S(20,3,0);

    dut.imem[18] = I(0,2,0,1,7'h13);
    dut.imem[19] = I(0,3,0,2,7'h13);
    dut.imem[20] = R(0,1,2,3,0);
    dut.imem[21] = S(24,3,0);

    dut.imem[22] = I(0,2,0,1,7'h13);
    dut.imem[23] = I(0,3,0,2,7'h13);
    dut.imem[24] = R(0,1,2,3,0);
    dut.imem[25] = S(28,3,0);

    reset = 0;

    repeat(30) @(posedge clk);
    @(negedge clk);

    if(dut.dmem[0] == 0 &&
       dut.dmem[1] == 1 &&
       dut.dmem[2] == 1 &&
       dut.dmem[3] == 2 &&
       dut.dmem[4] == 3 &&
       dut.dmem[5] == 5 &&
       dut.dmem[6] == 8 &&
       dut.dmem[7] == 13)

        $display("PROGRAM 2 PASS: FIBONACCI");

    else
        $display("PROGRAM 2 FAIL: FIBONACCI");


    // --------------------------------
    // PROGRAM 3: FIND MAXIMUM VALUE
    // --------------------------------

    reset = 1;
    #10;
    clear_prog;

    dut.dmem[0] = 12;
    dut.dmem[1] = 45;
    dut.dmem[2] = 7;
    dut.dmem[3] = 91;
    dut.dmem[4] = 33;
    dut.dmem[5] = 18;
    dut.dmem[6] = 64;
    dut.dmem[7] = 2;

    dut.imem[0] = I(0,0,0,1,7'h03);
    dut.imem[1] = I(4,0,0,2,7'h03);
    dut.imem[2] = R(0,2,1,3,2);
    dut.imem[3] = B(8,0,3,0);
    dut.imem[4] = I(0,2,0,1,7'h13);

    dut.imem[5] = I(8,0,0,2,7'h03);
    dut.imem[6] = R(0,2,1,3,2);
    dut.imem[7] = B(8,0,3,0);
    dut.imem[8] = I(0,2,0,1,7'h13);

    dut.imem[9] = I(12,0,0,2,7'h03);
    dut.imem[10] = R(0,2,1,3,2);
    dut.imem[11] = B(8,0,3,0);
    dut.imem[12] = I(0,2,0,1,7'h13);

    dut.imem[13] = I(16,0,0,2,7'h03);
    dut.imem[14] = R(0,2,1,3,2);
    dut.imem[15] = B(8,0,3,0);
    dut.imem[16] = I(0,2,0,1,7'h13);

    dut.imem[17] = I(20,0,0,2,7'h03);
    dut.imem[18] = R(0,2,1,3,2);
    dut.imem[19] = B(8,0,3,0);
    dut.imem[20] = I(0,2,0,1,7'h13);

    dut.imem[21] = I(24,0,0,2,7'h03);
    dut.imem[22] = R(0,2,1,3,2);
    dut.imem[23] = B(8,0,3,0);
    dut.imem[24] = I(0,2,0,1,7'h13);

    dut.imem[25] = I(28,0,0,2,7'h03);
    dut.imem[26] = R(0,2,1,3,2);
    dut.imem[27] = B(8,0,3,0);
    dut.imem[28] = I(0,2,0,1,7'h13);

    dut.imem[29] = S(32,1,0);

    reset = 0;

    repeat(40) @(posedge clk);
    @(negedge clk);

    if(dut.dmem[8] == 91)
        $display("PROGRAM 3 PASS: MAX = %0d",
                  dut.dmem[8]);
    else
        $display("PROGRAM 3 FAIL: MAX = %0d",
                  dut.dmem[8]);

    $display("--------------------------------");
    $display("DAY 3 TESTING COMPLETED");
    $display("--------------------------------");

    $finish;

end

endmodule
