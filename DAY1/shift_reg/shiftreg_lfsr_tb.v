`timescale 1ns/1ps
module shiftreg_lfsr_tb;
    reg clk=0,reset,seed_load;
    reg [1:0] mode;
    reg [7:0] parallel_in;
    reg serial_in;
    reg [7:0] seed;
    wire [7:0] q_shift,q_lfsr;
    reg [7:0] seen [0:254];
    integer i,j;
    shiftreg sr(clk,reset,mode,parallel_in,serial_in,q_shift);
    lfsr lf(clk,reset,seed_load,seed,q_lfsr);
    always #5 clk=~clk;

    initial begin
        reset=1; mode=0; parallel_in=0; serial_in=0; seed=8'h01; seed_load=0;
        @(negedge clk); reset=0;
        mode=3; parallel_in=8'hA5; @(negedge clk);
        mode=1; serial_in=1; @(negedge clk);
        mode=2; serial_in=0; @(negedge clk);
        mode=0; @(negedge clk);

        // Restart LFSR from nonzero seed and record 255 states.
        seed_load=1; seed=8'h01; @(negedge clk); seed_load=0;
        for(i=0;i<255;i=i+1) begin
            seen[i]=q_lfsr;
            if(q_lfsr==0) $display("ERROR: LFSR entered zero state");
            for(j=0;j<i;j=j+1)
                if(seen[j]==q_lfsr) $display("ERROR: early LFSR repeat at %0d",i);
            @(negedge clk);
        end
        if(q_lfsr !== seen[0]) $display("ERROR: sequence did not repeat after 255 states");
        else $display("LFSR repeats after 255 states and avoids zero state.");
        $finish;
    end
endmodule
