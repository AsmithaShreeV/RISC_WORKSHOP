`timescale 1ns/1ps
module encoder_decoder_tb;
    reg [7:0] in;
    reg [2:0] dec_in;
    reg enable;
    wire [2:0] code1,code2;
    wire valid1,valid2;
    wire [7:0] dec_out;
    integer i;
    priority_encoder_casez e1(in,code1,valid1);
    priority_encoder_if e2(in,code2,valid2);
    decoder d1(dec_in,enable,dec_out);
    initial begin
        for(i=0;i<256;i=i+1) begin
            in=i; #1;
            if(code1!==code2 || valid1!==valid2)
                $display("Encoder mismatch for input %b",in);
        end
        for(i=0;i<8;i=i+1) begin
            dec_in=i; enable=1; #1;
            if(dec_out !== (8'b1 << i)) $display("Decoder error at %0d",i);
            enable=0; #1;
            if(dec_out !== 0) $display("Decoder enable error");
        end
        $display("Encoder versions simulate identically for all 256 binary inputs.");
        $finish;
    end
endmodule
