`timescale 1ns / 1ps

module counter(clk,reset,count,O);
    input wire clk,reset,count;
    output reg [2:0] O = 3'b0;

    always@(negedge clk)    
        begin
            if(reset)
                O <= 0;
            else if(count)
                O <= O + 1;
            else
                O <= O;
    end
endmodule

module decoder_3to8(enable,I,O);
    input wire enable;
    input wire [2:0] I;
    output reg [7:0] O;
    
    always @(*)
    begin
        if(enable) begin
        case(I)
            3'h0 : O = 8'h01;
            3'h1 : O = 8'h02;
            3'h2 : O = 8'h04;
            3'h3 : O = 8'h08;
            3'h4 : O = 8'h10;
            3'h5 : O = 8'h20;
            3'h6 : O = 8'h40;
            3'h7 : O = 8'h80;
            default : O = 0;
        endcase
        end
        else
        begin
            O = O;
        end
    end
endmodule

module decoder_6to36(enable,I,O);
    input wire enable;
    input wire [5:0] I;
    output reg [35:0] O;
    
    always @(I)
    begin
    
        if(enable) begin
  
        case(I)
            6'h00 : O = 36'h000000001;
            6'h01 : O = 36'h000000002;
            6'h02 : O = 36'h000000004;
            6'h03 : O = 36'h000000008;
            6'h04 : O = 36'h000000010;
            6'h05 : O = 36'h000000020;
            6'h06 : O = 36'h000000040;
            6'h07 : O = 36'h000000080;
            6'h08 : O = 36'h000000100;
            6'h09 : O = 36'h000000200;
            6'h0A : O = 36'h000000400;
            6'h0B : O = 36'h000000800;
            6'h0C : O = 36'h000001000;
            6'h0D : O = 36'h000002000;
            6'h0E : O = 36'h000004000;
            6'h0F : O = 36'h000008000;
            
            6'h10 : O = 36'h000010000;
            6'h11 : O = 36'h000020000;
            6'h12 : O = 36'h000040000;
            6'h13 : O = 36'h000080000;
            6'h14 : O = 36'h000100000;
            6'h15 : O = 36'h000200000;
            6'h16 : O = 36'h000400000;
            6'h17 : O = 36'h000800000;
            6'h18 : O = 36'h001000000;
            6'h19 : O = 36'h002000000;
            6'h1A : O = 36'h004000000;
            6'h1B : O = 36'h008000000;
            6'h1C : O = 36'h010000000;
            6'h1D : O = 36'h020000000;
            6'h1E : O = 36'h040000000;
            6'h1F : O = 36'h080000000;
            
            6'h20 : O = 36'h100000000;
            6'h21 : O = 36'h200000000;
            
            default : O = 0;
        endcase
        end
        else
        begin
            O = O;
        end
    end
endmodule


module instruction_decoder(T2,IR, D, SEL, address);         
    input wire [15:0] IR;
    input wire T2;
    output wire [35:0] D;
    output reg [1:0] SEL;
    output reg [7:0] address;
    
    decoder_6to36 operation_decode(T2,IR[15:10],D); 
            
        always @(*)
        begin
            if(T2)
            begin
            SEL <= IR[9:8];
            address <= IR[7:0];
            end
        end
endmodule

module control_unit(Clock, SC_Reset, T, IROut, ALU_FlagOut, ARF_FunSel, ARF_RegSel, ARF_OutCSel, ARF_OutDSel,
                    ALU_FunSel, ALU_WF, RF_OutASel, RF_OutBSel, RF_FunSel, RF_RegSel, RF_ScrSel,
                    MuxASel, MuxBSel, MuxCSel, Mem_CS, Mem_WR, IR_LH, IR_Write
                    );
        input wire Clock;
        input wire [15:0] IROut;
        input wire [3:0] ALU_FlagOut;
        input wire [7:0] T;
        
        output reg [2:0] ARF_FunSel;
        output reg [2:0] ARF_RegSel;
        output reg [1:0] ARF_OutCSel;
        output reg [1:0] ARF_OutDSel;
        
        output reg [4:0] ALU_FunSel;
        output reg ALU_WF;
        
        output reg [2:0] RF_OutASel;
        output reg [2:0] RF_OutBSel;
        output reg [2:0] RF_FunSel;
        output reg [3:0] RF_RegSel;
        output reg [3:0] RF_ScrSel;
        
        output reg [1:0] MuxASel;
        output reg [1:0] MuxBSel;
        output reg MuxCSel;
        
        output reg Mem_CS;
        output reg Mem_WR;
        
        output reg IR_LH;
        output reg IR_Write;
        output reg SC_Reset;
        
        
        wire [2:0] temp;
       
        //Setup the system
            initial begin
                Mem_WR <= 1'b0;
                Mem_CS <= 1'b1;
                
                ARF_FunSel <= 3'b011;
                RF_FunSel <= 3'b011;
                RF_RegSel <= 4'b1111;
                ARF_RegSel <= 3'b101;
                RF_ScrSel <= 4'b1111;
                SC_Reset <= 1;
                
                #50; //frequency ??????
                RF_RegSel <= 4'b0000;
                ARF_RegSel <= 3'b011;
                RF_ScrSel <= 4'b0000;
                SC_Reset <= 0;
                #40; //?????
                
            end
               
        counter SC(Clock, SC_Reset, 1'b1, temp);
        decoder_3to8 SC_decoder(1'b1, temp,T);
       
      
               
               // T or D or IROut[7:0] or RSEL or ALU_FlagOut
               always @(negedge Clock) begin

                   if(T[0] && SC_Reset == 0) //  && SC_Reset == 0
                   begin
                   
                       ARF_OutDSel <= 2'b00;
                       ARF_OutCSel <= 2'bZZ;
                       ARF_RegSel <= 3'b011;
                       ARF_FunSel <= 3'b001;
                       Mem_CS <= 1'b0;
                       Mem_WR <= 1'b0;
                       IR_Write <= 1'b1;
                       IR_LH <= 1'b0;
                   end
                   else begin
                        SC_Reset = 0;
                   end
                   end
                 always @(negedge Clock) begin
                   if(T[1])
                   begin
               
                       ARF_OutDSel <= 2'b00;
                       ARF_OutCSel <= 2'bZZ;
                       ARF_RegSel <= 3'b011;
                       ARF_FunSel <= 3'b001;
                       Mem_CS <= 1'b0;
                       Mem_WR <= 1'b0;
                       IR_Write <= 1'b1;
                       IR_LH <= 1'b1;
                   end
                   
                   end
                   
                   always@(posedge Clock) begin
                        if (T[1]) begin
                            IR_Write <= 1'b0;
                        end
                   end
                   
                    //decoding the instruction
                      wire [35:0] D;
                      wire [1:0] RSEL;
                      wire [7:0] address;
                      
                      
                      instruction_decoder step3(T[2], IROut, D, RSEL, address);
                      
                  always@ (negedge Clock) begin
                      if (T[2]) begin
                        ARF_RegSel <= 3'b111;
                        //IR_Write <= 1'b0;
                      end
                  end
                      
                      wire Z = ALU_FlagOut[3];
                      wire [2:0] DSTREG = {RSEL[0], IROut[7:6]};
                      wire [2:0] SREG1 = IROut[5:3];
                      wire [2:0] SREG2 = IROut[2:0];
                      
                      // Sources:
                         // 11 : RF, RF
                         // 10 : RF, ARF
                         // 01 : ARF, RF
                         // 00 : ARF, ARF
                         reg [1:0] sources = 2'b11; 
                always@(T or D or IROut[7:0] or RSEL) begin
                /*if(T[0])begin
                #40;
                    SC_Reset <= 0;
                    Mem_CS <= 1;
                    Mem_WR <= 0;
                
                end*/
                if(T[2])
                begin
                   case (D)
                       36'b0000_0000_0000_0000_0000_0000_0000_0000_0001 : ALU_FunSel <= 5'b10100; //BRA
                       36'b0000_0000_0000_0000_0000_0000_0000_0000_0010 : ALU_FunSel <= 5'b10100; //BNE
                       36'b0000_0000_0000_0000_0000_0000_0000_0000_0100 : ALU_FunSel <= 5'b10100; //BEQ
                   //  36'b0000_0000_0000_0000_0000_0000_0000_0000_1000 : --- ;                   //POP
                       36'b0000_0000_0000_0000_0000_0000_0000_0001_0000 : ALU_FunSel <= 5'b00000; //PSH
                               
                       36'b0000_0000_0000_0000_0000_0000_0000_0010_0000: ALU_FunSel <= 5'b10000; // INC using A operation
                       36'b0000_0000_0000_0000_0000_0000_0000_0100_0000: ALU_FunSel <= 5'b10000; // DEC using A operation
                       36'b0000_0000_0000_0000_0000_0000_0000_1000_0000: ALU_FunSel <= 5'b11011; // LSL
                       36'b0000_0000_0000_0000_0000_0000_0001_0000_0000: ALU_FunSel <= 5'b11100; // LSR
                       36'b0000_0000_0000_0000_0000_0000_0010_0000_0000: ALU_FunSel <= 5'b11101; // ASR
                       36'b0000_0000_0000_0000_0000_0000_0100_0000_0000: ALU_FunSel <= 5'b11110; // CSL
                       36'b0000_0000_0000_0000_0000_0000_1000_0000_0000: ALU_FunSel <= 5'b11111; // CSR
                       36'b0000_0000_0000_0000_0000_0001_0000_0000_0000: ALU_FunSel <= 5'b10111; // AND
                       36'b0000_0000_0000_0000_0000_0010_0000_0000_0000: ALU_FunSel <= 5'b11000; // ORR
                       36'b0000_0000_0000_0000_0000_0100_0000_0000_0000: ALU_FunSel <= 5'b10010; // NOT
                       36'b0000_0000_0000_0000_0000_1000_0000_0000_0000: ALU_FunSel <= 5'b11001; // XOR
                       36'b0000_0000_0000_0000_0001_0000_0000_0000_0000: ALU_FunSel <= 5'b11010; // NAND
                       
                  //   36'b0000_0000_0000_0000_0010_0000_0000_0000_0000 : --- ;                  // MOVH
                   //  36'b0000_0000_0000_0000_0100_0000_0000_0000_0000 : --- ;                  // LDR
                       36'b0000_0000_0000_0000_1000_0000_0000_0000_0000 : ALU_FunSel <= 5'b00000;// STR
                   //  36'b0000_0000_0000_0001_0000_0000_0000_0000_0000 : --- ;                  // MOVL
                       
                       36'b0000_0000_0000_0010_0000_0000_0000_0000_0000: ALU_FunSel <= 5'b10100; // ADD
                       36'b0000_0000_0000_0100_0000_0000_0000_0000_0000: ALU_FunSel <= 5'b10101; // ADC 
                       36'b0000_0000_0000_1000_0000_0000_0000_0000_0000: ALU_FunSel <= 5'b10110; // SUB
                       36'b0000_0000_0001_0000_0000_0000_0000_0000_0000: ALU_FunSel <= 5'b10000; // MOVS using A operation
                       
                       36'b0000_0000_0010_0000_0000_0000_0000_0000_0000: ALU_FunSel <= 5'b10100; // ADDS
                       36'b0000_0000_0100_0000_0000_0000_0000_0000_0000: ALU_FunSel <= 5'b10110; // SUBS 
                       36'b0000_0000_1000_0000_0000_0000_0000_0000_0000: ALU_FunSel <= 5'b10111; // ANDS
                       36'b0000_0001_0000_0000_0000_0000_0000_0000_0000: ALU_FunSel <= 5'b11000; // ORRS
                       36'b0000_0010_0000_0000_0000_0000_0000_0000_0000: ALU_FunSel <= 5'b11001; // XORS
                       
                       36'b0000_0100_0000_0000_0000_0000_0000_0000_0000 : ALU_FunSel <= 5'b00000; // BX
                   //  36'b0000_1000_0000_0000_0000_0000_0000_0000_0000 : --- ;                   // BL
                   //  36'b0001_0000_0000_0000_0000_0000_0000_0000_0000 : --- ;                   //LDRIM
                       36'b0010_0000_0000_0000_0000_0000_0000_0000_0000 : ALU_FunSel <= 5'b10100; //STRIM
                       default : ALU_FunSel <= 5'b00000;
                   endcase
             
                   end
                   
                    if (D[24] || D[25] || D[26] || D[27] || D[28] || D[29]) // For operations that allow changing of flags
                    begin 
                          ALU_WF <= 1'b1; 
                    end
                    else
                    begin
                          ALU_WF <= 1'b0; 
                    end
                              
                      //without address reference
                      
                      //Source register(s)
                      
                     // SREG1 from RF
                     if ((D[5] || D[6] || D[7] || D[8] || D[9] || D[10] || D[11] || D[12] || D[13] || D[14]
                       || D[15] || D[16] || D[21] || D[22] || D[23] || D[24] || D[25] || D[26] || D[27] || D[28] || D[29])
                         && T[3] && SREG1[2] == 1) begin
                         // ALU_A <- SREG1
                         RF_OutASel <= {1'b0, SREG1[1:0]};
                         sources <= {SREG1[2], sources[0]};    //1, sources[0]
                     end
                             
                     // SREG2 from RF 
                     if ((D[12] || D[13] || D[15] || D[16] || D[21] || D[22] || D[23]
                       || D[25] || D[26] || D[27] || D[28] || D[29]) 
                         && T[3] && SREG2[2] == 1) begin
                         // ALU_B <- SREG2
                         RF_OutBSel <= {1'b0, SREG2[1:0]};
                         sources <= {sources[1], SREG2[2]};   //sources[1], 1 
                     end
                             
                     // SREG1 from ARF
                     if ((D[5] || D[6] || D[7] || D[8] || D[9] || D[10] || D[11] || D[12] || D[13] || D[14]
                       || D[15] || D[16] || D[21] || D[22] || D[23] || D[24] || D[25] || D[26] || D[27] || D[28] || D[29])
                       && T[3] && SREG1[2] == 0) begin
                         // RF_S1 <- SREG1
                         case (SREG1[1:0])
                             2'b00: ARF_OutCSel <= 2'b00; // ARF Output is PC
                             2'b01: ARF_OutCSel <= 2'b01; // ARF Output is PC
                             2'b10: ARF_OutCSel <= 2'b11; // ARF Output is SP
                             2'b11: ARF_OutCSel <= 2'b10; // ARF Output is AR
                             default: ARF_OutCSel <= 2'b11;
                         endcase
                          MuxASel <= 2'b01;
                          RF_FunSel <= 3'b010; //Load
                          RF_ScrSel <= 4'b0111; //only S1 is enabled
                          RF_OutASel <= 3'b100; // ALU_A <- S1
                          sources = {SREG1[2], sources[0]}; // 0, sources[0]
                     end
             
                     // SREG2 from ARF
                     if ((D[12] || D[13] || D[15] || D[16] || D[21] || D[22] || D[23]
                       || D[25] || D[26] || D[27] || D[28] || D[29]) 
                       && T[3] && SREG2[2] == 0 && sources[1] == 1) begin //executed only if SREG1 is not taken from ARF
                         // RF_S2 <- SREG2
                         case (SREG2[1:0])
                             2'b00: ARF_OutCSel <= 2'b00; // ARF Output is PC
                             2'b01: ARF_OutCSel <= 2'b01; // ARF Output is PC
                             2'b10: ARF_OutCSel <= 2'b11; // ARF Output is SP
                             2'b11: ARF_OutCSel <= 2'b10; // ARF Output is AR
                             default: ARF_OutCSel <= 2'b11;
                         endcase 
                         MuxASel <= 2'b01;
                         RF_FunSel <= 3'b010; //Load
                         RF_ScrSel <= 4'b1011; //only S2 is enabled
                         RF_OutBSel <= 3'b101; // ALU_B <- S2
                         sources <= {sources[1], SREG2[2]}; // sources[1], 0
                       end
                    
                    if (T[4]) begin
                        if((sources[1] == 1 && sources[0] == 0)||(sources[1] == 0 && sources[0] == 1)) //SREG1 from RF and SREG2 from ARF OR SREG1 from ARF and SREG2 from RF
                        begin
                            RF_ScrSel <= 4'b1111; //no general purpose registers enabled
                            RF_FunSel <= 3'b011;  //clear 
                        end
                       else if(sources[1] == 0 && SREG2[2] == 0)
                       begin
                    // RF_S2 <- SREG2
                        case (SREG2[1:0])
                            2'b00: ARF_OutCSel <= 2'b00; // ARF Output is PC
                            2'b01: ARF_OutCSel <= 2'b01; // ARF Output is PC
                            2'b10: ARF_OutCSel <= 2'b11; // ARF Output is SP
                            2'b11: ARF_OutCSel <= 2'b10; // ARF Output is AR
                            default: ARF_OutCSel <= 2'b11;
                        endcase 
                        MuxASel <= 2'b01;
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1011; //only S2 is enabled
                        RF_OutBSel <= 3'b101; // ALU_B <- S2
                        sources <= {sources[1], SREG2[2]}; // sources[1], 0
                       end
                   end
                   
                   if(T[5] && sources[0] == 0) begin
                       RF_ScrSel <= 4'b1111; //no general purpose registers enabled
                       RF_FunSel <= 3'b011;  //clear 
                   end
                   
                    
                    //Destination register
            
                   // DSTREG is in RF
                   if (((T[3] && sources == 2'b11) || 
                       (T[4] && sources == 2'b01) || 
                       (T[4] && sources == 2'b10) ||
                       (T[5] && sources == 2'b00)) &&
                       DSTREG[2] == 1 && (D[5] || D[6] || D[7] || D[8] || D[9] || D[10] || D[11] || D[12] || D[13] || D[14]
                                  || D[15] || D[16] || D[21] || D[22] || D[23] || D[24] || D[25] || D[26] || D[27] || D[28] || D[29])) 
                   begin
                       // DSTREG <- ALU_Out
                       MuxASel <= 2'b00;
                       RF_FunSel = 3'b010; //Load
                       case (DSTREG[1:0])
                           2'b00 : RF_RegSel <= 4'b0111; // R1
                           2'b01 : RF_RegSel <= 4'b1011; // R2
                           2'b10 : RF_RegSel <= 4'b1101; // R3
                           2'b11 : RF_RegSel <= 4'b1110; // R4
                           default: RF_RegSel <= 4'bZZZZ;
                       endcase
                   end
            
                   // DSTREG is in ARF
                   if (((T[3] && sources == 2'b11) || 
                        (T[4] && sources == 2'b01) || 
                        (T[4] && sources == 2'b10) ||
                        (T[5] && sources == 2'b00)) &&
                        DSTREG[2] == 0 && (D[5] || D[6] || D[7] || D[8] || D[9] || D[10] || D[11] || D[12] || D[13] || D[14]
                                 || D[15] || D[16] || D[21] || D[22] || D[23] || D[24] || D[25] || D[26] || D[27] || D[28] || D[29])) 
                    begin
                       // DSTREG <- ALU_Out
                       MuxBSel <= 2'b00;
                       ARF_FunSel <= 3'b010; //Load
                       case (DSTREG[1:0])
                           2'b00: ARF_RegSel <= 3'b011; // PC
                           2'b01: ARF_RegSel <= 3'b011; // PC
                           2'b10: ARF_RegSel <= 3'b110; // SP
                           2'b11: ARF_RegSel <= 3'b101; // AR
                           default: ARF_RegSel <= 3'bZZZ;
                       endcase
                   end
                    
                    // Incrementing and decrementing operations
                    
                     // In case of increment, increment DSTREG, it's already swapped with SREG1
                          if (((T[4] && sources == 2'b11) || 
                              (T[5] && sources == 2'b01)) && D[5])   //(T[5] && sources == 2'b10)) ||
                                                                       //(T[6] && sources == 2'b00)
                              begin
                              if (DSTREG[2] == 0) begin // If DSTREG is in ARF
                                  ARF_FunSel <= 3'b001; // Increment
                              end else begin // If DSTREG is in RF
                                  RF_FunSel <= 3'b001; // Increment
                              end
                          end
                  
                      // In case of decrement, decrement DSTREG, it's already swapped with SREG1
                      if (((T[4] && sources == 2'b11) || 
                          (T[5] && sources == 2'b01)) && D[6]) //(T[5] && sources == 2'b10)) ||
                                                               //(T[6] && sources == 2'b00) &&
                          begin
                          if (DSTREG[2] == 0) begin // If DSTREG is in ARF
                              ARF_FunSel <= 3'b000; // Decrement
                          end else begin // If DSTREG is in RF
                              RF_FunSel <= 3'b000; // Decrement
                          end
                      end
                      
                   // with address reference
                                 
                              
                 if (D[0] || (D[1] && !Z) || (D[2] && Z)) begin
                              if (T[3]) begin
                              
                               
                              MuxASel <= 2'b11;     // IR[7:0]
                              RF_FunSel <= 3'b100;  // Only write low
                              RF_RegSel <= 4'b1111; // ALL R's disabled
                              RF_ScrSel <= 4'b0111; // S1
                              RF_OutASel <= 3'b100; // S1
                              
                              MuxBSel <= 2'b00;     // ALUOut
                              ALU_FunSel <= 5'b10100; // ALU output
                              ARF_OutCSel <= 2'b00; // PC
                              end
                              if (T[4]) begin
                                
                              // ARF_OutCSel <= 2'b01; // PC
                              MuxASel <= 2'b01;     // OutC
                              RF_FunSel <= 3'b100;  // Load
                              // RF_RegSel <= 4'b1111; // ALL R's disabled
                              RF_ScrSel <= 4'b1011; // S2
                              RF_OutBSel <= 3'b101; // S2

                              end
                              if (T[5]) begin
                              ARF_FunSel <= 3'b010; // Load
                              ARF_RegSel <= 3'b011; // PC                                
                              end
                          end
                          
                          if (D[3]) begin
                              if (T[3]) begin
                                  ARF_RegSel <= 3'b110; // SP
                                  ARF_FunSel <= 3'b001; // Increment
                                  ARF_OutDSel <= 2'b11; // SP
                                  Mem_WR <= 0;          // Read
                                  MuxASel <= 2'b10;     // MemOut
                                  RF_FunSel <= 3'b100;  // 15:8 Clear, Write Low
                              end
                              if (T[4]) begin
                                  case (RSEL)
                                      2'b00 : RF_RegSel <= 4'b0111; // R1
                                      2'b01 : RF_RegSel <= 4'b1011; // R2
                                      2'b10 : RF_RegSel <= 4'b1101; // R3
                                      2'b11 : RF_RegSel <= 4'b1110; // R4
                                  endcase
                              end
                          end
                          
                          if (D[4]) begin
                              if (T[3]) begin
                                  case (RSEL)
                                      2'b00 : RF_OutASel <= 3'b000; // R1
                                      2'b01 : RF_OutASel <= 3'b001; // R2
                                      2'b10 : RF_OutASel <= 3'b010; // R3
                                      2'b11 : RF_OutASel <= 3'b011; // R4
                                  endcase
                                  MuxCSel <= 0;         // ALUOut[7:0]
                                  ARF_OutDSel <= 2'b11; // SP
                                  Mem_WR <= 1;          // Write
                              end
                              if (T[4]) begin
                                  ARF_FunSel <= 3'b000; // Decrement
                                  ARF_RegSel <= 3'b110; // SP
                              end
                          end
                          
                          if (D[17] && T[3]) begin
                              MuxASel <= 2'b11; // IR[7:0]
                              case (RSEL)
                                  2'b00 : RF_RegSel <= 4'b0111; // R1
                                  2'b01 : RF_RegSel <= 4'b1011; // R2
                                  2'b10 : RF_RegSel <= 4'b1101; // R3
                                  2'b11 : RF_RegSel <= 4'b1110; // R4
                              endcase
                              RF_FunSel <= 3'b110; // Only write high
                          end
                          
                          if (D[18] && T[3]) begin
                              case (RSEL)
                                  2'b00 : RF_RegSel <= 4'b0111; // R1
                                  2'b01 : RF_RegSel <= 4'b1011; // R2
                                  2'b10 : RF_RegSel <= 4'b1101; // R3
                                  2'b11 : RF_RegSel <= 4'b1110; // R4
                              endcase
                              RF_FunSel <= 3'b010;  // Clear high, write low
                              ARF_OutDSel <= 2'b10; // AR
                              Mem_WR <= 0;          // Read
                              MuxASel <= 2'b10;     // MemOut
                          end
                          
                          if (D[19] && T[3]) begin
                              case (RSEL)
                                  2'b00 : RF_OutASel <= 3'b000; // R1
                                  2'b01 : RF_OutASel <= 3'b001; // R2
                                  2'b10 : RF_OutASel <= 3'b010; // R3
                                  2'b11 : RF_OutASel <= 3'b011; // R4
                              endcase
                              MuxCSel <= 0;         // ALUOut[7:0]
                              ARF_OutDSel <= 2'b10; // AR
                              Mem_WR <= 1;          // Write
                          end
                          
                          if (D[20] && T[3]) begin
                              MuxASel <= 2'b11; // IR[7:0]
                              case (RSEL)
                                  2'b00 : RF_RegSel <= 4'b0111; // R1
                                  2'b01 : RF_RegSel <= 4'b1011; // R2
                                  2'b10 : RF_RegSel <= 4'b1101; // R3
                                  2'b11 : RF_RegSel <= 4'b1110; // R4
                              endcase
                              RF_FunSel <= 3'b101; // Only write low
                          end
                          
                          if (D[30]) begin
                              if (T[3]) begin
                                  ARF_OutDSel <= 2'b11; // SP
                                  ARF_OutCSel <= 2'b00; // PC
                                  Mem_WR <= 1;          // Write
                                  MuxASel <= 2'b01;     // OutC
                                  RF_ScrSel <= 4'b0111; // S1
                                  RF_FunSel <= 3'b010;  // Load
                                  RF_OutASel <= 3'b100; // S1
                                  MuxCSel <= 0;         // ALUOut[7:0]
                              end
                              if (T[4]) begin
                                  ALU_FunSel <= 5'b10000;
                                  case (RSEL)
                                      2'b00 : RF_OutASel <= 3'b000; // R1
                                      2'b01 : RF_OutASel <= 3'b001; // R2
                                      2'b10 : RF_OutASel <= 3'b010; // R3
                                      2'b11 : RF_OutASel <= 3'b011; // R4
                                  endcase
                                  MuxBSel <= 2'b00;     // ALUOut
                                  ARF_FunSel <= 3'b010; // Load
                                  ARF_RegSel <= 3'b011; // PC
                              end
                          end
                          
                          if (D[31] && T[3]) begin
                              ARF_OutDSel <= 2'b11; // SP
                              Mem_WR <= 0;          // Read
                              MuxBSel <= 2'b10;     // MemOut
                              ARF_FunSel <= 3'b010; // Load
                              ARF_RegSel <= 3'b011; // PC
                          end
                          
                          if (D[32] && T[3]) begin
                              MuxASel <= 2'b11;     // IR[7:0]
                              RF_FunSel <= 3'b100;  // Clear high, write low
                              case (RSEL)
                                  2'b00 : RF_RegSel <= 4'b0111; // R1
                                  2'b01 : RF_RegSel <= 4'b1011; // R2
                                  2'b10 : RF_RegSel <= 4'b1101; // R3
                                  2'b11 : RF_RegSel <= 4'b1110; // R4
                              endcase
                          end
                          
                          if (D[33]) begin
                              if (T[3]) begin
                                  MuxASel <= 2'b11;     // IR[7:0]
                                  RF_ScrSel <= 4'b0111; // S1
                                  RF_FunSel <= 3'b010;  // Load
                              end
                              if (T[4]) begin
                                  ARF_OutCSel <= 2'b10;   // AR
                                  MuxASel <= 2'b01;       // OutC
                                  RF_ScrSel <= 4'b1011;   // S2
                                  RF_OutASel <= 3'b100;   // S1
                                  RF_OutBSel <= 3'b101;   // S2
                                  MuxBSel <= 2'b00;       // ALUOut
                                  ARF_FunSel <= 3'b010;   // Load
                                  ARF_RegSel <= 3'b101;   // AR
                                  ARF_OutDSel <= 2'b10;   // AR
                              end
                              if (T[5]) begin
                                  case (RSEL)
                                      2'b00 : RF_OutASel <= 3'b000; // R1
                                      2'b01 : RF_OutASel <= 3'b001; // R2
                                      2'b10 : RF_OutASel <= 3'b010; // R3
                                      2'b11 : RF_OutASel <= 3'b011; // R4
                                  endcase
                                  Mem_WR <= 1;            // Write
                                  ALU_FunSel <= 5'b10000; // 16-bit A
                                  MuxCSel <= 0;           // ALUOut[7:0]                                
                              end
                          end
                      
           if ((T[5] && (D[30] || D[3] || D[4])) || (T[6] && (D[0] || (D[1] && !Z) || (D[2] && Z))) || 
               (T[5] && (D[7] || D[8] || D[9] || D[10] || D[11] || D[17] || D[18] || D[19] || D[20] || D[31] || D[32])) || 
               (T[5] && D[33]) || 
               ((D[5] || D[6] || D[7] || D[8] || D[9] || D[10] || D[11] || D[14] || D[24]) && ((T[5] && sources[1]) || (T[6] && !sources[1]))) ||
               ((D[12] || D[13] || D[15] || D[16] || D[21] || D[22] || D[23] || D[25] || D[26] || D[27] || D[28] || D[29]) &&
               ((T[4] && sources[1] && sources[0]) || (T[5] && (sources[1] ^ sources[0])) || (T[6] && !sources[1] && !sources[0])))) 
                             
               begin
                   SC_Reset <= 1; // Reset the counter to zero
                   RF_RegSel <= 4'bZZZZ;
                   RF_ScrSel <= 4'bZZZZ;
                   ARF_RegSel <= 3'bZZZ; 
                   RF_FunSel <= 3'bZZZ;
                   ARF_FunSel <= 3'bZZZ;
                   Mem_CS <= 1;
                   Mem_WR <= 0;
                   MuxASel <= 2'bZZ;
                   MuxBSel <= 2'bZZ;
                   MuxCSel <= 1'bZ;
               end
          end
endmodule

module CPUSystem(input wire Clock, input wire Reset, input wire [7:0] T);

    
    
    wire [2:0] RF_OutASel;
    wire [2:0] RF_OutBSel;
    wire [2:0] RF_FunSel;
    wire [3:0] RF_RegSel;
    wire [3:0] RF_ScrSel;
    
    wire [4:0] ALU_FunSel;
    wire ALU_WF;
    wire [3:0] ALU_FlagOut;
    
    wire [1:0] ARF_OutCSel; 
    wire [1:0] ARF_OutDSel; 
    wire [2:0] ARF_FunSel; 
    wire [2:0] ARF_RegSel;
    
    wire IR_LH; 
    wire IR_Write;
    wire [15:0] IROut;
    
    wire Mem_WR;
    wire Mem_CS;
    
    wire [1:0] MuxASel;
    wire [1:0] MuxBSel;
    wire MuxCSel;
    

    
    ArithmeticLogicUnitSystem _ALUSystem(
        .RF_OutASel(RF_OutASel), 
        .RF_OutBSel(RF_OutBSel), 
        .RF_FunSel(RF_FunSel),
        .RF_RegSel(RF_RegSel),
        .RF_ScrSel(RF_ScrSel),
        .ALU_FunSel(ALU_FunSel),
        .ARF_OutCSel(ARF_OutCSel), 
        .ARF_OutDSel(ARF_OutDSel), 
        .ARF_FunSel(ARF_FunSel),
        .ARF_RegSel(ARF_RegSel),
        .IR_LH(IR_LH),
        .IR_Write(IR_Write),
        .IROut(IROut),
        .Mem_WR(Mem_WR),
        .Mem_CS(Mem_CS),
        .MuxASel(MuxASel),
        .MuxBSel(MuxBSel),
        .MuxCSel(MuxCSel),
        .FlagsOut(ALU_FlagOut),
        .ALU_WF(ALU_WF),
        .Clock(Clock)      );
    
    control_unit CU(
        .Clock(Clock),
        .SC_Reset(Reset),
        .T(T),
        .IROut(IROut),
        .ALU_FlagOut(ALU_FlagOut),
        .ARF_FunSel(ARF_FunSel), 
        .ARF_RegSel(ARF_RegSel),
        .ARF_OutCSel(ARF_OutCSel), 
        .ARF_OutDSel(ARF_OutDSel),
        .ALU_FunSel(ALU_FunSel),
        .ALU_WF(ALU_WF),
        .RF_OutASel(RF_OutASel),
        .RF_OutBSel(RF_OutBSel),
        .RF_FunSel(RF_FunSel),
        .RF_RegSel(RF_RegSel),
        .RF_ScrSel(RF_ScrSel),
        .Mem_WR(Mem_WR),
        .Mem_CS(Mem_CS),
        .MuxASel(MuxASel),
        .MuxBSel(MuxBSel),
        .MuxCSel(MuxCSel),
        .IR_LH(IR_LH),
        .IR_Write(IR_Write)
    );
    
endmodule