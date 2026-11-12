
`timescale 1ns/1ps

module day3_single_cycle(
    input clk,
    input reset,
    output reg [31:0] pc,
    output [31:0] instruction,
    output reg [31:0] alu_result,
    output reg reg_write,
    output reg [4:0] rd,
    output reg [31:0] writeback_data
);

    reg [31:0] imem [0:255];
    reg [31:0] dmem [0:255];
    reg [31:0] regs [0:31];

    wire [6:0] opcode = instruction[6:0];
    wire [4:0] rs1 = instruction[19:15];
    wire [4:0] rs2 = instruction[24:20];
    wire [2:0] funct3 = instruction[14:12];
    wire [6:0] funct7 = instruction[31:25];

    wire [31:0] a = (rs1 == 0) ? 0 : regs[rs1];
    wire [31:0] breg = (rs2 == 0) ? 0 : regs[rs2];

    reg [31:0] imm, operand_b, next_pc, result;
    reg take_branch, mem_write, mem_read;
    reg [2:0] aluop;

    integer i;

    assign instruction = imem[pc[9:2]];

    initial begin
        pc = 0;
        for(i=0;i<32;i=i+1)
            regs[i] = 0;

        for(i=0;i<256;i=i+1) begin
            imem[i] = 32'h00000013;
            dmem[i] = 0;
        end
    end

    always @* begin
        imm = 0;
        operand_b = breg;
        aluop = 0;
        result = 0;
        next_pc = pc + 4;
        take_branch = 0;
        mem_write = 0;
        mem_read = 0;
        reg_write = 0;
        rd = instruction[11:7];
        writeback_data = 0;
        alu_result = 0;

        case(opcode)

        // R TYPE
        7'h33: begin
            case(funct3)
                3'b000: aluop = (funct7 == 7'h20) ? 1 : 0;
                3'b111: aluop = 2;
                3'b110: aluop = 3;
                3'b100: aluop = 4;
                3'b010: aluop = 5;
                3'b001: aluop = 6;
                3'b101: aluop = 7;
            endcase

            case(aluop)
                0: result = a + breg;
                1: result = a - breg;
                2: result = a & breg;
                3: result = a | breg;
                4: result = a ^ breg;
                5: result = ($signed(a) < $signed(breg));
                6: result = a << breg[4:0];
                7: result = a >> breg[4:0];
            endcase

            reg_write = 1;
            writeback_data = result;
            alu_result = result;
        end

        // I TYPE
        7'h13: begin
            imm = {{20{instruction[31]}},instruction[31:20]};
            operand_b = imm;

            case(funct3)
                3'b000: result = a + imm;
                3'b111: result = a & imm;
                3'b110: result = a | imm;
                3'b100: result = a ^ imm;
                3'b010: result = ($signed(a) < $signed(imm));
                3'b001: result = a << instruction[24:20];
                3'b101: result = a >> instruction[24:20];
                default: result = 0;
            endcase

            reg_write = 1;
            writeback_data = result;
            alu_result = result;
        end

        // LUI
        7'h37: begin
            result = {instruction[31:12],12'b0};
            reg_write = 1;
            writeback_data = result;
            alu_result = result;
        end

        // LOAD WORD
        7'h03: begin
            imm = {{20{instruction[31]}},instruction[31:20]};
            alu_result = a + imm;
            writeback_data = dmem[alu_result[9:2]];
            reg_write = 1;
        end

        // STORE WORD
        7'h23: begin
            imm = {{20{instruction[31]}},
                   instruction[31:25],instruction[11:7]};
            alu_result = a + imm;
            mem_write = 1;
        end

        // BRANCH
        7'h63: begin
            imm = {{19{instruction[31]}},instruction[31],
                   instruction[7],instruction[30:25],
                   instruction[11:8],1'b0};

            case(funct3)
                3'b000: take_branch = (a == breg);
                3'b001: take_branch = (a != breg);
                3'b100: take_branch = ($signed(a) < $signed(breg));
                3'b101: take_branch = ($signed(a) >= $signed(breg));
                default: take_branch = 0;
            endcase

            if(take_branch)
                next_pc = pc + imm;
        end

        // JAL
        7'h6f: begin
            imm = {{11{instruction[31]}},instruction[31],
                   instruction[19:12],instruction[20],
                   instruction[30:21],1'b0};

            reg_write = 1;
            writeback_data = pc + 4;
            next_pc = pc + imm;
        end

        // JALR
        7'h67: begin
            imm = {{20{instruction[31]}},instruction[31:20]};
            reg_write = 1;
            writeback_data = pc + 4;
            next_pc = (a + imm) & 32'hfffffffe;
        end

        default: begin
        end

        endcase
    end

    always @(posedge clk) begin
        if(reset) begin
            pc <= 0;
            for(i=0;i<32;i=i+1)
                regs[i] <= 0;
        end
        else begin
            if(mem_write)
                dmem[alu_result[9:2]] <= breg;

            if(reg_write && rd != 0)
                regs[rd] <= writeback_data;

            regs[0] <= 0;
            pc <= next_pc;
        end
    end

endmodule
