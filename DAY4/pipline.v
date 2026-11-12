
`timescale 1ns/1ps

module day4_pipeline(
    input clk,
    input reset,
    output reg [31:0] pc,
    output reg halted
);

    // Instruction and data memories
    reg [31:0] imem [0:255];
    reg [31:0] dmem [0:255];

    // Register file
    reg [31:0] regs [0:31];

    // Pipeline registers: IF/ID
    reg [31:0] ifid_pc, ifid_instr;

    // Pipeline registers: ID/EX
    reg [31:0] idex_pc, idex_rs1, idex_rs2;
    reg [31:0] idex_imm;
    reg [4:0] idex_rd, idex_rs1_addr, idex_rs2_addr;
    reg [2:0] idex_funct3;
    reg [6:0] idex_opcode, idex_funct7;
    reg idex_regwrite, idex_memread;
    reg idex_memwrite, idex_memtoreg;
    reg idex_branch, idex_alusrc;

    // Pipeline registers: EX/MEM
    reg [31:0] exmem_alu, exmem_store;
    reg [31:0] exmem_branch_target;
    reg [4:0] exmem_rd;
    reg exmem_regwrite, exmem_memread;
    reg exmem_memwrite, exmem_memtoreg;
    reg exmem_branch_taken;

    // Pipeline registers: MEM/WB
    reg [31:0] memwb_data, memwb_alu;
    reg [4:0] memwb_rd;
    reg memwb_regwrite, memwb_memtoreg;

    // Temporary signals
    reg [31:0] imm;
    reg [31:0] alu_a, alu_b, alu_result;
    reg [31:0] mem_data;
    reg [31:0] branch_target;
    reg branch_taken;
    reg [31:0] forwarded_a, forwarded_b;
    reg stall;
    reg [31:0] writeback_data;

    integer i;

    wire [6:0] opcode = ifid_instr[6:0];
    wire [4:0] rs1 = ifid_instr[19:15];
    wire [4:0] rs2 = ifid_instr[24:20];
    wire [4:0] rd = ifid_instr[11:7];

    // Immediate generation
    always @(*) begin
        case (opcode)
            7'b0010011, 7'b0000011:
                imm = {{20{ifid_instr[31]}}, ifid_instr[31:20]};

            7'b0100011:
                imm = {{20{ifid_instr[31]}},
                       ifid_instr[31:25], ifid_instr[11:7]};

            7'b1100011:
                imm = {{19{ifid_instr[31]}},
                       ifid_instr[31], ifid_instr[7],
                       ifid_instr[30:25], ifid_instr[11:8], 1'b0};

            default:
                imm = 0;
        endcase
    end

    // Hazard detection
    always @(*) begin
        stall = 0;

        if (idex_memread && idex_rd != 0 &&
            ((idex_rd == rs1) || (idex_rd == rs2)))
            stall = 1;
    end

    // Writeback data selection
    always @(*) begin
        if (memwb_memtoreg)
            writeback_data = memwb_data;
        else
            writeback_data = memwb_alu;
    end

    // Main five-stage pipeline
    always @(posedge clk or posedge reset) begin

        if (reset) begin
            pc <= 0;
            halted <= 0;

            ifid_pc <= 0;
            ifid_instr <= 32'h00000013;

            idex_pc <= 0;
            idex_rs1 <= 0;
            idex_rs2 <= 0;
            idex_imm <= 0;
            idex_rd <= 0;
            idex_rs1_addr <= 0;
            idex_rs2_addr <= 0;
            idex_funct3 <= 0;
            idex_opcode <= 0;
            idex_funct7 <= 0;
            idex_regwrite <= 0;
            idex_memread <= 0;
            idex_memwrite <= 0;
            idex_memtoreg <= 0;
            idex_branch <= 0;
            idex_alusrc <= 0;

            exmem_alu <= 0;
            exmem_store <= 0;
            exmem_branch_target <= 0;
            exmem_rd <= 0;
            exmem_regwrite <= 0;
            exmem_memread <= 0;
            exmem_memwrite <= 0;
            exmem_memtoreg <= 0;
            exmem_branch_taken <= 0;

            memwb_data <= 0;
            memwb_alu <= 0;
            memwb_rd <= 0;
            memwb_regwrite <= 0;
            memwb_memtoreg <= 0;

            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 0;
        end

        else begin

            // WB stage
            if (memwb_regwrite && memwb_rd != 0)
                regs[memwb_rd] <= writeback_data;

            regs[0] <= 0;

            // MEM stage
            memwb_alu <= exmem_alu;
            memwb_rd <= exmem_rd;
            memwb_regwrite <= exmem_regwrite;
            memwb_memtoreg <= exmem_memtoreg;

            if (exmem_memread)
                memwb_data <= dmem[exmem_alu[9:2]];

            if (exmem_memwrite)
                dmem[exmem_alu[9:2]] <= exmem_store;

            // EX stage
            forwarded_a = idex_rs1;
            forwarded_b = idex_rs2;

            if (exmem_regwrite && exmem_rd != 0 &&
                exmem_rd == idex_rs1_addr)
                forwarded_a = exmem_alu;
            else if (memwb_regwrite && memwb_rd != 0 &&
                     memwb_rd == idex_rs1_addr)
                forwarded_a = writeback_data;

            if (exmem_regwrite && exmem_rd != 0 &&
                exmem_rd == idex_rs2_addr)
                forwarded_b = exmem_alu;
            else if (memwb_regwrite && memwb_rd != 0 &&
                     memwb_rd == idex_rs2_addr)
                forwarded_b = writeback_data;

            alu_a = forwarded_a;
            alu_b = idex_alusrc ? idex_imm : forwarded_b;

            alu_result = 0;
            branch_taken = 0;
            branch_target = idex_pc + idex_imm;

            case (idex_opcode)

                7'b0110011: begin
                    case (idex_funct3)
                        3'b000:
                            alu_result = (idex_funct7[5]) ?
                                         alu_a - alu_b : alu_a + alu_b;
                        3'b111: alu_result = alu_a & alu_b;
                        3'b110: alu_result = alu_a | alu_b;
                        3'b100: alu_result = alu_a ^ alu_b;
                        3'b010: alu_result =
                                         ($signed(alu_a) < $signed(alu_b));
                        default: alu_result = 0;
                    endcase
                end

                7'b0010011:
                    alu_result = alu_a + alu_b;

                7'b0000011, 7'b0100011:
                    alu_result = alu_a + idex_imm;

                7'b1100011: begin
                    case (idex_funct3)
                        3'b000: branch_taken = (alu_a == forwarded_b);
                        3'b001: branch_taken = (alu_a != forwarded_b);
                        3'b100: branch_taken =
                                      ($signed(alu_a) < $signed(forwarded_b));
                        3'b101: branch_taken =
                                      ($signed(alu_a) >= $signed(forwarded_b));
                        default: branch_taken = 0;
                    endcase
                end

                default: alu_result = 0;

            endcase

            exmem_alu <= alu_result;
            exmem_store <= forwarded_b;
            exmem_rd <= idex_rd;
            exmem_regwrite <= idex_regwrite;
            exmem_memread <= idex_memread;
            exmem_memwrite <= idex_memwrite;
            exmem_memtoreg <= idex_memtoreg;
            exmem_branch_taken <= branch_taken;
            exmem_branch_target <= branch_target;

            // ID stage and IF stage
            if (exmem_branch_taken) begin
                pc <= exmem_branch_target;
                ifid_instr <= 32'h00000013;
                idex_opcode <= 0;
                idex_regwrite <= 0;
                idex_memread <= 0;
                idex_memwrite <= 0;
                idex_branch <= 0;
            end

            else if (stall) begin
                pc <= pc;
                ifid_instr <= ifid_instr;

                idex_opcode <= 0;
                idex_regwrite <= 0;
                idex_memread <= 0;
                idex_memwrite <= 0;
            end

            else begin

                // Decode stage
                ifid_pc <= pc;
                ifid_instr <= imem[pc[9:2]];
                pc <= pc + 4;

                idex_pc <= ifid_pc;
                idex_rs1 <= regs[rs1];
                idex_rs2 <= regs[rs2];
                idex_imm <= imm;

                idex_rd <= rd;
                idex_rs1_addr <= rs1;
                idex_rs2_addr <= rs2;
                idex_funct3 <= ifid_instr[14:12];
                idex_opcode <= opcode;
                idex_funct7 <= ifid_instr[31:25];

                // Control generation
                idex_regwrite <= 0;
                idex_memread <= 0;
                idex_memwrite <= 0;
                idex_memtoreg <= 0;
                idex_branch <= 0;
                idex_alusrc <= 0;

                case (opcode)

                    7'b0110011: begin
                        idex_regwrite <= 1;
                    end

                    7'b0010011: begin
                        idex_regwrite <= 1;
                        idex_alusrc <= 1;
                    end

                    7'b0000011: begin
                        idex_regwrite <= 1;
                        idex_memread <= 1;
                        idex_memtoreg <= 1;
                        idex_alusrc <= 1;
                    end

                    7'b0100011: begin
                        idex_memwrite <= 1;
                        idex_alusrc <= 1;
                    end

                    7'b1100011: begin
                        idex_branch <= 1;
                    end

                    default: begin
                        idex_regwrite <= 0;
                    end

                endcase

            end

        end
    end

endmodule
