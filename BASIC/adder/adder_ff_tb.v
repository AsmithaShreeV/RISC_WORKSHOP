module tb_fulladder_dff;

reg [3:0] A, B;
reg Cin, clk;

wire [3:0] Q;
wire Cout;

fulladder_dff uut(
    .A(A),
    .B(B),
    .Cin(Cin),
    .clk(clk),
    .Q(Q),
    .Cout(Cout)
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
    $monitor("Time=%0t | A=%d | B=%d | Cin=%b | Cout=%b | Q=%d",
              $time, A, B, Cin, Cout, Q);

    A = 4'd3; B = 4'd2; Cin = 0;

    #10 A = 4'd5; B = 4'd4; Cin = 1;

    #10 A = 4'd7; B = 4'd6; Cin = 0;

    #10 A = 4'd9; B = 4'd3; Cin = 1;

    #10 A = 4'd2; B = 4'd1; Cin = 0;

    #10 $finish;
end

endmodule