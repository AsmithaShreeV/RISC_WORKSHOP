module shiftreg(input clk,reset, input [1:0] mode,
                input [7:0] parallel_in, input serial_in,
                output reg [7:0] q);
    // mode: 00 hold, 01 shift left, 10 shift right, 11 parallel load
    always @(posedge clk) begin
        if(reset) q<=0;
        else case(mode)
            2'b00: q<=q;
            2'b01: q<={q[6:0],serial_in};
            2'b10: q<={serial_in,q[7:1]};
            2'b11: q<=parallel_in;
        endcase
    end
endmodule
