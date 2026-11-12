module arbiter(input clk, reset, input [3:0] req, output reg [3:0] grant);
    reg [1:0] priority_ptr;
    reg [1:0] chosen;
    reg found;
    integer k;
    reg [3:0] rotated_req;

    // A current grant is held until that request is deasserted.
    always @* begin
        chosen=priority_ptr;
        found=0;
        rotated_req=0;
        for(k=0;k<4;k=k+1) begin
            if(!found && req[(priority_ptr+k)%4]) begin
                chosen=(priority_ptr+k)%4;
                found=1;
            end
        end
    end

    always @(posedge clk) begin
        if(reset) begin grant<=0; priority_ptr<=0; end
        else if(grant!=0) begin
            if((grant & req)==0) begin
                grant<=0;
                priority_ptr<=chosen+1'b1;
            end
        end else if(found) begin
            grant<=4'b0001 << chosen;
        end
    end
endmodule
