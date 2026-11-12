module tb_d_flipflop;

reg D, clk;
wire Q;

d_flipflop uut(
    .D(D),
    .clk(clk),
    .Q(Q)
);

// Clock generation
initial
begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Input generation
initial
begin
    $monitor("Time=%0t | clk=%b | D=%b | Q=%b", $time, clk, D, Q);

    D = 0;
    #10 D = 1;
    #10 D = 0;
    #10 D = 1;
    #10 D = 1;
    #10 D = 0;

    #10 $finish;
end

endmodule
