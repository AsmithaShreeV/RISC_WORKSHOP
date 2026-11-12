module tb_mux_2x1_clk;

reg I0, I1, sel, clk;
wire Y;

mux_2x1_clk uut(
    .I0(I0),
    .I1(I1),
    .sel(sel),
    .clk(clk),
    .Y(Y)
);

// Clock generation
initial
begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Test inputs
initial
begin
    $monitor("Time=%0t | clk=%b | I0=%b | I1=%b | sel=%b | Y=%b",
              $time, clk, I0, I1, sel, Y);

    I0 = 0; I1 = 1; sel = 0;

    #10 sel = 1;

    #10 I0 = 1; I1 = 0; sel = 0;

    #10 sel = 1;

    #10 I0 = 1; I1 = 1; sel = 0;

    #10 $finish;
end

endmodule