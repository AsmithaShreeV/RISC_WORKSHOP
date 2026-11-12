module adder_sub #(parameter WIDTH=8) (
    input [WIDTH-1:0] a,b,
    input mode, // 0 add, 1 subtract
    output [WIDTH-1:0] result,
    output carry_out,
    output overflow
);
    wire [WIDTH-1:0] bx;
    wire [WIDTH:0] c;
    assign bx = b ^ {WIDTH{mode}};
    assign c[0] = mode;
    genvar i;
    generate
        for(i=0;i<WIDTH;i=i+1) begin: FA_CHAIN
            full_adder fa(.a(a[i]),.b(bx[i]),.cin(c[i]),
                          .sum(result[i]),.cout(c[i+1]));
        end
    endgenerate
    assign carry_out = c[WIDTH];
    assign overflow = c[WIDTH] ^ c[WIDTH-1];
endmodule
