`define IF 4'b0000
`define ID 4'b0001
`define Branch 4'b0010
`define CType 4'b0011
`define CWrite 4'b0100
`define Jump 4'b0101
`define Store 4'b0110
`define Load 4'b0111
`define LWrite 4'b1000
`define Addi 4'b1001
`define Subi 4'b1010
`define Andi 4'b1011
`define Ori 4'b1100
`define ImmWrite 4'b1101

module ControlUnit (clk, rst, op, func, Zero, nop, 
        PCLoad, AdrSrc, MemWrite, IRWrite, WriteTo, RFWrite, WriteSrc, SrcA, SrcB, AluOP, PCSrc);
    input clk, rst;
    input [3:0] op;
    input [8:0] func;
    input Zero, nop;
    output PCLoad, AdrSrc, MemWrite, IRWrite, WriteTo, RFWrite, WriteSrc, SrcA;
    output [1:0] SrcB, PCSrc;
    output [2:0] AluOP;

    logic [3:0] ps, ns;

    always @(posedge clk or posedge rst) begin
        if (rst) ps <= 4'd0;
        else ps <= ns;
    end

    always @(ps or opcode) begin
        case (ps)
            `IF: ns = `ID;
            `ID: begin
                case (opcode)
                    4'b0000: ns = `Load;
                    4'b0001: ns = `Store;
                    4'b0010: ns = `Jump;
                    4'b0100: ns = `Branch;
                    4'b1000: ns = `Ctype;
                    4'b1100: ns = `Addi;
                    4'b1101: ns = `Subi;
                    4'b1110: ns = `Andi;
                    4'b1111: ns = `Ori;
                endcase
            end
            `Branch:    ns = `IF;
            `Ctype:     ns = `CWrite;
            `CWrite:    ns = `IF;
            `Jump:      ns = `IF;
            `Store:     ns = `IF;
            `Load:      ns = `LoadWrite;
            `LoadWrite: ns = `IF;
            `Addi:      ns = `ImmWrite;
            `Subi:      ns = `ImmWrite;
            `Andi:      ns = `ImmWrite;
            `Ori:       ns = `ImmWrite;
            `ImmWrite:  ns = `IF;
            default: ns = `IF;
        endcase
    end

    always @(ps) begin
        {PCLoad, AdrSrc, MemWrite, IRWrite, WriteTo, RFWrite, WriteSrc, SrcA, SrcB, PCSrc, AluOP} = 15'd0;

        case (ps)
            `IF: begin 
                PCLoad = 1'b1;
                IRWrite = 1'b1;
                SrcA = 1'b1;
                SrcB = 2'b01;
            end
            `Branch: begin
                AluOP = 3'b001;
                PCSrc = 10;
                branch = 1'b1;
            end
            `Ctype: begin
                AluOP = 3'b100;
            end
            `CWrite: begin
                RFWrite = 1'b1;
                WriteSrc = 1'b0;
                AluOP = 3'b100;
            end
            `Jump: begin
                PCLoad = 1'b1;
                PCSrc = 2'b01;
            end
            `Store: begin
                AdrSrc = 1'b1;
                MemWrite = 1'b1;
            end
            `Load: begin
                AdrSrc = 1'b1;
            end
            `LoadWrite: begin
                RFWrite = 1'b1;
            end
            `Addi: begin
                SrcB = 2'b10;
                aluOp = 3'b000;
            end
            `Subi: begin
                SrcB = 2'b10;
                aluOp = 3'b001;
            end
            `Andi: begin
                SrcB = 2'b10;
                aluOp = 3'b010;
            end
            `Ori: begin
                SrcB = 2'b10;
                aluOp = 3'b011;
            end
            `ImmWrite: begin
                RFWrite = 1'b1;
                WriteSrc = 1'b1;
            end
            default:;
        endcase
    end
endmodule
