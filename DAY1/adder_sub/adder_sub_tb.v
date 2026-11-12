`timescale 1ns/1ps
module adder_sub_tb;
    reg [7:0] a,b;
    reg mode;
    wire [7:0] result;
    wire carry_out,overflow;
    reg [8:0] expected_ext;
    reg [7:0] expected;
    reg expected_overflow;
    integer i,j,m;
    adder_sub dut(.*);
    initial begin
        for(m=0;m<2;m=m+1)
            for(i=0;i<256;i=i+1)
                for(j=0;j<256;j=j+1) begin
                    a=i; b=j; mode=m; #1;
                    if(m==0) begin
                        expected_ext={1'b0,a}+{1'b0,b};
                        expected_overflow=(~(a[7]^b[7])) & (expected_ext[7]^a[7]);
                    end else begin
                        expected_ext={1'b0,a}+{1'b0,(~b)}+9'd1;
                        expected_overflow=(a[7]^b[7]) & (expected_ext[7]^a[7]);
                    end
                    expected=expected_ext[7:0];
                    if(result !== expected)
                        $display("RESULT ERROR mode=%b a=%h b=%h got=%h exp=%h",mode,a,b,result,expected);
                    if(carry_out !== expected_ext[8])
                        $display("CARRY ERROR mode=%b a=%h b=%h got=%b exp=%b",mode,a,b,carry_out,expected_ext[8]);
                    if(overflow !== expected_overflow)
                        $display("OVERFLOW ERROR mode=%b a=%h b=%h got=%b exp=%b",mode,a,b,overflow,expected_overflow);
                end
        $display("Exhaustive adder/subtractor test completed.");
        $finish;
    end
endmodule
