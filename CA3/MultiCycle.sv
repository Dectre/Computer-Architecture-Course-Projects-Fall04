module MultiCycle (clk, rst);
    input clk, rst;

    wire PCLoad, AdrSrc, MemWrite, IRWrite, WriteTo, RFWrite, WriteSrc, Zero, nop;
    wire [1:0] SrcA, SrcB, PCSrc;
    wire [2:0] AluOP;
    wire [3:0] op;
    wire [8:0] func;

    Datapath DP (
        .clk(clk), 
        .rst(rst), 
        .PCLoad(PCLoad), 
        .AdrSrc(AdrSrc), 
        .MemWrite(MemWrite), 
        .IRWrite(IRWrite), 
        .WriteTo(WriteTo), 
        .RFWrite(RFWrite), 
        .WriteSrc(WriteSrc), 
        .SrcA(SrcA), 
        .SrcB(SrcB), 
        .AluOP(AluOP), 
        .PCSrc(PCSrc), 
        .op(op), 
        .func(func), 
        .Zero(Zero), 
        .nop(nop)
    );

    ControlUnit CU (
        .clk(clk), 
        .rst(rst), 
        .op(op), 
        .func(func), 
        .Zero(Zero), 
        .nop(nop),
        .PCLoad(PCLoad), 
        .AdrSrc(AdrSrc), 
        .MemWrite(MemWrite), 
        .IRWrite(IRWrite), 
        .WriteTo(WriteTo), 
        .RFWrite(RFWrite), 
        .WriteSrc(WriteSrc), 
        .SrcA(SrcA), 
        .SrcB(SrcB), 
        .AluOP(AluOP), 
        .PCSrc(PCSrc)
    );

endmodule