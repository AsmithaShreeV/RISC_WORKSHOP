module fulladder_dff(
    input [3:0] A, B,
    input Cin,
    input clk,
    output reg [3:0] Q,
    output Cout
);

wire [4:0] result;

// 4-bit Full Adder
assign result = A + B + Cin;

// 4 D Flip-Flops
always @(posedge clk)
begin
    Q <= result[3:0];
end

assign Cout = result[4];

endmodule