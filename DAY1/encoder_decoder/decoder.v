module decoder(input [2:0] in, input enable, output reg [7:0] out);
    always @* begin
        out=8'b0;
        if(enable) out = 8'b00000001 << in;
    end
endmodule
