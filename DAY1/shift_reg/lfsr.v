module lfsr(input clk,reset,seed_load, input [7:0] seed,
            output reg [7:0] q);
    wire feedback;
    // Fibonacci LFSR: x^8 + x^6 + x^5 + x^4 + 1 (maximal length).
    assign feedback = q[7] ^ q[5] ^ q[4] ^ q[3];
    always @(posedge clk) begin
        if(reset) q<=8'h01;
        else if(seed_load) q <= (seed==0) ? 8'h01 : seed;
        else q <= {q[6:0],feedback};
    end
endmodule
