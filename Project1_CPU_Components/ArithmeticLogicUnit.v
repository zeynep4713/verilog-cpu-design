`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.04.2024 20:28:49
// Design Name: 
// Module Name: ArithmeticLogicUnit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ArithmeticLogicUnit(A,B,FunSel,ALUOut,FlagsOut,WF,Clock);
            input wire [15:0] A;
            input wire [15:0] B;
            input wire [4:0] FunSel;
            output reg [15:0] ALUOut;
            output reg [3:0] FlagsOut;
            input wire WF;
            input Clock;
            
            reg temp;
            reg temp_O;
            reg Z = 0;
            reg C = 0;
            reg N = 0;
            reg O = 0;
            

            always @(*)
            begin
            temp = 0;
            temp_O = 0;
               case(FunSel)
                  //-----------------8-bit-------------------//
                  5'b00000: ALUOut = {8'b0, A[7:0]};// A(8-bit)
                  5'b00001: ALUOut = {8'b0, B[7:0]};// B(8-bit)
                  
                  5'b00010: ALUOut = {8'b0, ~A[7:0]};// NOT A(8-bit)
                  5'b00011: ALUOut = {8'b0, ~B[7:0]};// NOT B(8-bit)

                  5'b00100:  // A + B
                  begin
                       {temp, ALUOut[7:0]} = {8'b0, (A[7:0]+B[7:0])};
                       ALUOut[15:8] = {7'b0, temp};
                       if((A[7] == B[7]) && (B[7] == 1))begin
                           temp_O = 1;
                       end
                  end

                  5'b00101:  // A + B + Carry
                  begin
                       {temp, ALUOut[7:0]} = {8'b0, (A[7:0]+B[7:0]+C)};
                       ALUOut[15:8] = {7'b0, temp};
                       if((A[7] == B[7]) && (B[7] == 1))begin
                          temp_O = 1;
                       end
                  end
                   
                  5'b00110: //A - B
                  begin
                        {temp, ALUOut[7:0]} = {8'b0, (A[7:0]+(~B[7:0])+1)};
                         ALUOut[15:8] = {7'b0, temp};
                         if((A[7] != B[7]) && (ALUOut[7] == B[7]))begin
                            temp_O = 1;
                         end
                  end
                  5'b00111: ALUOut = {8'b0, (A[7:0]&B[7:0])};
                  5'b01000: ALUOut = {8'b0, (A[7:0]|B[7:0])};
                  5'b01001: ALUOut = {8'b0, (A[7:0]^B[7:0])};
                  5'b01010: ALUOut = {8'b0, ~(A[7:0]&B[7:0])};
                  
                  5'b01011: //LSL A
                  begin
                       temp = A[7];                    
                       ALUOut = {8'b0,A[7:0]};
                       
                       ALUOut = ALUOut << 1;
                       ALUOut ={8'b0,ALUOut[7:0]};
                  end
                  
                  5'b01100: //LSR A
                  begin
                       temp = A[0];
                       ALUOut = {8'b0,A[7:0]};
                       
                       ALUOut = ALUOut >> 1;
                       ALUOut ={8'b0,ALUOut[7:0]};
                  end
                  
                  5'b01101: // ASR A
                  begin
                       ALUOut = {8'b0,A[7:0]};
                       ALUOut = ALUOut >> 1;
                       ALUOut[7] = ALUOut[6];
                  end
                  
                  5'b01110: // CSL A
                  begin
                       ALUOut = {8'b0, A[6:0], C};
                       temp = A[7];
                  end
                  
                  5'b01111: //CSR A
                  begin
                       ALUOut = {8'b0, C, A[7:1]};
                       temp = A[0];
                  end
              
                   //-----------------------------------------//
                   
                   //-----------------16-bit-------------------//
                   5'b10000: ALUOut = A;// A(16-bit)
                   5'b10001: ALUOut = B;// B(16-bit)
                   
                   5'b10010: ALUOut = ~A;// NOT A(16-bit)
                   5'b10011: ALUOut = ~B;// NOT B(16-bit)
                   
                   
                   5'b10100:  // A + B
                   begin
                        {temp, ALUOut} = A + B;
                        if((A[15] == B[15]) && (B[15] == 1))begin
                            temp_O = 1;
                        end
                   end

                   5'b10101:  // A + B + Carry
                   begin
                        {temp, ALUOut} = A + B + C;
                        if((A[15] == B[15]) && (B[15] == 1))begin
                            temp_O = 1;
                        end
                   end
                    
                   5'b10110: //A - B
                   begin
                        {temp, ALUOut} = A + (~B + 1);
                        if((A[15] != B[15]) && (ALUOut[15] == B[15]))begin
                            temp_O = 1;
                        end
                   end
                   5'b10111: ALUOut = A & B;
                   5'b11000: ALUOut = A | B;
                   5'b11001: ALUOut = A ^ B;
                   5'b11010: ALUOut = ~(A & B);
                   
                   5'b11011: //LSL A
                   begin
                        temp = A[15];
                        ALUOut = A;
                        ALUOut = ALUOut << 1;
                   end
                   
                   5'b11100: //LSR A
                   begin
                        temp = A[0];
                        ALUOut = A;
                        ALUOut = ALUOut >> 1;
                   end
                   
                   5'b11101: // ASR A ???
                   begin
                        ALUOut = A;
                        ALUOut = ALUOut >> 1;
                        ALUOut[15] = ALUOut[14];
                   end
                   
                   5'b11110: // CSL A
                   begin
                        ALUOut = {A[14:0], C};
                        temp = A[15];
                   end
                   
                   5'b11111: //CSR A
                   begin
                        ALUOut = {C, A[15:1]};
                        temp = A[0];
                   end
                   default:   ALUOut = 16'b0;
                   //------------------------------------------//
               endcase            
            end
            
            always @(posedge Clock) begin
                if(WF == 1)begin
                Z = (ALUOut == 17'b0);
                C = temp;
                N = (ALUOut[15] == 1);
                O = temp_O;
                end
             end
             always @(posedge Clock)begin
                if(WF == 1)begin
                FlagsOut = {Z, C, N, O};
                end
             end
             
endmodule
