`timescale 1ns / 1ps

module Register(
        input wire [15:0] I,
        input wire [2:0] FunSel,
        input wire E,
        input Clock,
        output reg [15:0] Q );
        
        always @(posedge Clock)
            begin
            if(E)
            begin
                case(FunSel)
                 3'b000 : Q <= Q - {15'b0, 1'b1};
                3'b001 : Q <= Q + {15'b0, 1'b1};
                3'b010 : Q <= I[15:0];
                3'b011 : Q <= {16'b0};
                3'b100 : Q <= {8'b0, I[7:0]};
                3'b101 : Q <= {Q[15:8], I[7:0]};
                3'b110 : Q <= {I[7:0], Q[7:0]};   //!CHANGED: 3'b110 : Q <= {I[15:8], Q[7:0]};
                3'b111 : Q <= {{8{I[7]}}, I[7:0]};   
                 default:    Q <= Q;
                 endcase
            end
            else
            begin
            Q <= Q;
            end
            end     
endmodule
