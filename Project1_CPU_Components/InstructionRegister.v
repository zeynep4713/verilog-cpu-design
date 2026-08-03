`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.04.2024 15:24:28
// Design Name: 
// Module Name: InstructionRegister
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


module InstructionRegister(
        input wire [7:0] I,
        input wire LH,
        input wire Write,
        input Clock,
        output reg [15:0] IROut );
        
        always @(posedge Clock)
            begin
                if(Write)
                begin
                    case(LH)
                        1'b0 : IROut[7:0] <= I;
                        1'b1 : IROut[15:8] <= I;
                        default : IROut <= IROut;
                     endcase
                end
                else
                begin
                    IROut <= IROut;
                end
            end
        
        
endmodule
