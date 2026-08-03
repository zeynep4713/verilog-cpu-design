`timescale 1ns / 1ps

module ArithmeticLogicUnitSystem( //check multiplexer modules????
    input Clock,
    input wire [2:0] RF_OutASel, RF_OutBSel, RF_FunSel,
    input wire [3:0] RF_RegSel, RF_ScrSel,
    input wire [4:0] ALU_FunSel,
    input wire ALU_WF,
    input wire [1:0] ARF_OutCSel, ARF_OutDSel,
    input wire [2:0] ARF_FunSel, ARF_RegSel,
    input wire  IR_LH, IR_Write, Mem_WR, Mem_CS,
    input wire [1:0] MuxASel, MuxBSel,
    input wire  MuxCSel,
    
    output reg [15:0] MuxAOut, MuxBOut,
    output reg [7:0] MuxCOut,
    wire [15:0] OutA,
    wire [15:0] OutB,
    wire [15:0] OutC,
    wire [15:0] OutD,
    wire [15:0] ALUOut,
    wire [15:0] IROut,
    wire [15:0] Address,
    wire [7:0] MemOut,
    wire [3:0] FlagsOut
    );
    
    assign Address = OutD;

    RegisterFile RF(
        .I(MuxAOut),                .OutASel(RF_OutASel),
        .OutBSel(RF_OutBSel),       .FunSel(RF_FunSel),
        .RegSel(RF_RegSel),         .ScrSel(RF_ScrSel),
        .Clock(Clock),              .OutA(OutA),    .OutB(OutB)
    );
    
    AddressRegisterFile ARF(
        .I(MuxBOut),                .OutCSel(ARF_OutCSel),
        .OutDSel(ARF_OutDSel),      .FunSel(ARF_FunSel),
        .RegSel(ARF_RegSel),        .Clock(Clock),   .OutC(OutC),    .OutD(OutD)
    );
    
    InstructionRegister IR(
        .I(MEM.MemOut),             .LH(IR_LH),
        .Write(IR_Write),           .Clock(Clock),  .IROut(IROut)
    );
    
    Memory MEM(
        .Address(OutD),         .Data(MuxCOut),
        .WR(Mem_WR),                .CS(Mem_CS),
        .Clock(Clock),              .MemOut(MemOut)
    );
    
    ArithmeticLogicUnit ALU(
        .A(OutA),                   .B(OutB),
        .FunSel(ALU_FunSel),        .WF(ALU_WF),
        .Clock(Clock),              .ALUOut(ALUOut),
        .FlagsOut(FlagsOut)
    );
    
   
    
    always @(*) begin
        
        //OutC <= ARF.OutC;
        //Address <= MEM.Address;
        
    //MUX A
        case(MuxASel)
            2'b00: MuxAOut <= ALUOut;
            2'b01: MuxAOut <= OutC;
            2'b10: MuxAOut <= {8'b0, MemOut};
            2'b11: MuxAOut <= {8'b0, IROut[7:0]};
        endcase
        
        //OutA <= RF.OutA;
        //OutB <= RF.OutB;
        //ALUOut <= ALU.ALUOut;
    end
    
    always @(*) begin
    //MUX B
        case(MuxBSel)
            2'b00: MuxBOut <= ALUOut;
            2'b01: MuxBOut <= OutC;
            2'b10: MuxBOut <= {8'b0, MemOut};
            2'b11: MuxBOut <= {8'b0, IROut[7:0]};
        endcase
    end
    
    always @(*) begin    
    //MUX C
        case(MuxCSel)
            1'b0: MuxCOut <= ALUOut[7:0];
            1'b1: MuxCOut <= ALUOut[15:8];
        endcase
                
        //MemOut <= MEM.MemOut;
        //IROut <= IR.IROut;
    
   end
endmodule